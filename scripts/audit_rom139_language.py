#!/usr/bin/env python3
"""Read-only bilingual resource inventory for the CHS_Mod source tree.

English in src/text is the same-generation CHS fork source. The optional
pokered-master archive is a *different* upstream revision; direct label match
alone must not be used to overwrite the Chinese script or imported text.

Usage from the repository root:
  python3 scripts/audit_rom139_language.py --report docs/ROM139_LANGUAGE_TEXT_AUDIT.md \
      --tsv docs/ROM139_LANGUAGE_TEXT_MATCHES.tsv
  python3 scripts/audit_rom139_language.py --english-master-zip ../pokered-master.zip \
      --report docs/ROM139_LANGUAGE_TEXT_AUDIT.md --tsv docs/ROM139_LANGUAGE_TEXT_MATCHES.tsv
No make/assembler/linker, ROMs, or Git commands are invoked.
"""
from __future__ import annotations
import argparse
import csv
import json
import re
import zipfile
from collections import Counter
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SRC = REPO / "src"
LABEL = re.compile(r"(?m)^([A-Za-z_][A-Za-z_0-9.]*)::?\s*$")
TAG = re.compile(r"^([A-Za-z_][A-Za-z_0-9.]*)::?\s*$")
CMD = re.compile(r'(?m)^\s*(?:text|line|cont|para|next)\s+"((?:[^"\\]|\\.)*)"')
COMPLEX = re.compile(r"\b(?:text_(?:ram|bcd|decimal|asm|far|number|digit|link|player|rival)|text_sound|text_wait|text_prompt)\b|<(?:PLAYER|RIVAL|RAM|BATTLE|TARGET|USER|ENEMY)>|\\b(?:sound_|start_asm)")


def load_chs_index():
    # The source-export helper emits a trailing comma on the final JSON row.
    raw = (SRC / "_G1RB.json").read_text(encoding="utf-8")
    raw = re.sub(r",\s*\]\s*$", "\n]", raw)
    return json.loads(raw)


def labels_in_asm(content: str):
    return [(m.group(1), m.start(), m.end()) for m in LABEL.finditer(content)]


def english_index():
    idx = {}
    for path in sorted((SRC / "text").rglob("*.asm")):
        data = path.read_text(encoding="utf-8")
        labels = labels_in_asm(data)
        for i, (name, _start, end) in enumerate(labels):
            if name not in idx:
                body = data[end:labels[i + 1][1] if i + 1 < len(labels) else len(data)]
                idx[name] = (path.relative_to(REPO).as_posix(), body)
    return idx


def upstream_labels(archive: Path | None):
    if archive is None:
        return None
    names = set()
    with zipfile.ZipFile(archive) as zf:
        for f in zf.namelist():
            if f.startswith("text/") and f.endswith(".asm"):
                text = zf.read(f).decode("utf-8")
                names.update(m[0] for m in labels_in_asm(text))
    return names


def chs_tags(entries):
    rows = []
    for x in entries:
        e = x.get("Sentence", {})
        if not isinstance(e, dict):
            continue
        tag_parts = str(e.get("tag", "")).strip().splitlines()
        if not tag_parts:
            continue
        m = TAG.fullmatch(tag_parts[0].strip())
        if m is None:
            continue
        rows.append((m.group(1), tag_parts[1].strip() if len(tag_parts) > 1 else "", str(e.get("text", ""))))
    return rows


def create_audit(report: Path, tsv: Path, master_zip: Path | None):
    entries = load_chs_index()
    rows = chs_tags(entries)
    local = english_index()
    upstream = upstream_labels(master_zip)
    names = [r[0] for r in rows]
    duplicates = {k: n for k, n in Counter(names).items() if n > 1}
    match = sum(name in local for name, _book, _zh in rows)
    dynamic = sum(bool(COMPLEX.search(zh) or COMPLEX.search(local[name][1] if name in local else "")) for name, _book, zh in rows)
    english_printable = sum(sum(len(m.group(1)) for m in CMD.finditer(body)) for _file, body in local.values())
    master_same = len(set(local) & upstream) if upstream is not None else None

    tsv.parent.mkdir(parents=True, exist_ok=True)
    with tsv.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f, delimiter="\t", lineterminator="\n")
        writer.writerow(["label", "chs_xlsx", "english_in_src_text", "english_source", "complex_control_or_placeholder", "also_in_upstream_master"])
        for label, book, zh in rows:
            en = local.get(label)
            complicated = bool(COMPLEX.search(zh) or COMPLEX.search(en[1] if en else ""))
            writer.writerow([label, book, "yes" if en else "no", en[0] if en else "", "yes" if complicated else "no", ("yes" if label in upstream else "no") if upstream is not None else "not checked"])

    report.parent.mkdir(parents=True, exist_ok=True)
    master_lines = (f"- 独立 `pokered-master.zip` 的 `text/*.asm` 标签数：{len(upstream)}；与中文版 `src/text/` **仅 {master_same} 个标签名直接相同**，不能无检查地复制原版文件。\n" if upstream is not None else "- 未提供英文原版 ZIP 进行逐标签交叉比对；需要时用 `--english-master-zip` 补测。\n")
    report.write_text(f"""# ROM-1.39 LANGUAGE 资源盘点（只读静态扫描）

> 统计来自当前提供的完整源码，不是 ROM 编译结果，也不是已实现的全游戏英语覆盖率。本阶段仅 OPTIONS 和 Route 1 一位 NPC 会随语言切换。

## 1. 可复用资源

- 汉化导出 `src/_G1RB.json` 原始记录：**{len(entries)}**，含尾逗号（盘点脚本读取时兼容，不修改原文件）。
- 可解析的汉化条目：**{len(rows)}**；唯一文本标签：**{len(set(names))}**；重复标签：**{len(duplicates)}**。
- 中文版内保留的英文 `src/text/*.asm` 标签：**{len(local)}**。
- 以同一代中文版英文源码标签直接匹配：**{match}/{len(rows)} 条汉化记录**；这是**标签存在性**，不是语义、动态参数和页面布局一致性的保证。
- 初步标记需人工审阅的动态文本／控制符记录：**{dynamic} 条**。具体见同目录 TSV 的标识列。扫描仅作候选分类，可能遗漏复杂脚本。
- 英文 `src/text/` 的引号内可见字面字符计数：**{english_printable:,}**（不等于 ROM 字节占用，未计控制符、Bank 指针、重定位、填充、压缩等）。
{master_lines}
## 2. 为什么不能一次把所有英文直接切进去

- `scripts/prepare_build.py` 按 `src/xlsx/*.xlsx` 和 `src/tools/_importText.py` 生成汉化编译树 `buildRB/`，默认并不保留两套文本数据于同一 ROM。
- 原生 `src/text/` 和 Excel 导入有大量可直接按原标签关联的文本，但不能单纯按 `text_far` 路径把所有不同类型字符串替换到一处：UI 菜单、战斗、图鉴、物品说明各有独立系统。
- 需要完整处理动态插值（玩家名、对手名、物品、数值）、`text_asm`、文本页面分隔和 Bank 位置。
- 不能靠输入源码字符数确定空间；**Bank 剩余空间必须由维护者编译后的 MAP 复核**。本次没有编译 ROM。

## 3. 后续批量扩展建议

1. 先从纯静态 NPC 文本出发，利用 TSV 中标签与源码路径生成另一 Bank 的英文文本和运行时指针映射，保留原中文入口不变。
2. 对被标记为复杂的记录进行差异核对；英文原版项目与 CHS 分支标签差异要按具体文本内容审查。
3. 用维护者脚本验证 Bank 预算；随后分区推进剧情、路牌、菜单、战斗、图鉴和特殊事件。
4. 最终目标的 English 模式需覆盖全局，但**当前试点的 English 模式仍有中文内容**；不要将试点误当成完整双语版。

运行：`python3 scripts/audit_rom139_language.py --report docs/ROM139_LANGUAGE_TEXT_AUDIT.md --tsv docs/ROM139_LANGUAGE_TEXT_MATCHES.tsv`。如有独立原版 `pokered-master.zip`，另外传 `--english-master-zip <path>`。
""", encoding="utf-8")
    return {"raw": len(entries), "tags": len(rows), "unique": len(set(names)), "duplicates": duplicates, "english": len(local), "paired_rows": match, "complex": dynamic, "english_chars": english_printable, "upstream": len(upstream) if upstream else None, "same_upstream": master_same}


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--report", type=Path, default=REPO / "docs/ROM139_LANGUAGE_TEXT_AUDIT.md")
    p.add_argument("--tsv", type=Path, default=REPO / "docs/ROM139_LANGUAGE_TEXT_MATCHES.tsv")
    p.add_argument("--english-master-zip", type=Path)
    a = p.parse_args()
    print(json.dumps(create_audit(a.report, a.tsv, a.english_master_zip), ensure_ascii=False, indent=2))
