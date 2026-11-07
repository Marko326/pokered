#!/usr/bin/env python3
"""Generate bilingual far-text commands and isolated English map-dialogue data.

src/ is authoritative. The official root build pipeline runs this after the
XLSX importers, writing only into buildRB/. English source bodies are copied
from the same-generation English masters in src/text/ and src/data/text/;
project-authored translations for CHS-only text live in a separate JSON file.

This script performs static source generation only. It never invokes RGBDS,
links a ROM, or edits the authoritative source scripts.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
import shutil
import sys
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

# Reuse the existing language audit's JSON/tag and ASM-label parsers.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import audit_rom139_language as resource_audit  # noqa: E402

TEXT_FAR_RE = re.compile(
    r"^(?P<indent>\s*)text_far\s+(?P<label>[A-Za-z_][A-Za-z_0-9.]*)"
    r"(?P<tail>\s*(?:;.*)?)$"
)
TEXT_FAR_START_RE = re.compile(r"^\s*text_far\b")
STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"')
ANGLE_TOKEN_RE = re.compile(r"<[^>\n]+>")
DYNAMIC_TOKEN_RE = re.compile(r"<(?:PLAYER|RIVAL|TARGET|USER)>")
RUNTIME_COMMAND_RE = re.compile(r"(?m)^\s*(text_(?:ram|decimal|bcd))\b")
UNSAFE_COMMAND_RE = re.compile(r"(?m)^\s*(text_(?:asm|far|bilingual))\b")
LABEL_RE = re.compile(r"[A-Za-z_][A-Za-z_0-9.]*\Z")

# These two direct English references are the original ROM-1.41A/B pilot
# wrappers. They already select English explicitly and must not be wrapped a
# second time by the generated command.
EXISTING_ENGLISH_REFS = {
    "_Route1Text2English",
    "_ViridianCityText1English",
}

# Tokens which retain their existing dynamic/control semantics in English.
SUPPORTED_ANGLE_TOKENS = {
    "<PLAYER>", "<RIVAL>", "<TARGET>", "<USER>",
    "<CONT>", "<DONE>", "<PROMPT>", "<PAGE>", "<DEXEND>",
    "<NEXT>", "<LINE>", "<PARA>", "<NULL>", "<SCROLL>",
    "<_CONT>", "<……>", "<COLON>",
}

# This is the only shared special expansion verified in the ROM-1.41B user
# recording. Do not guess mappings for <PC>/<ROCKET>/<TM>/<TRAINER>/<PKMN>.
SPECIAL_EXPANSIONS = (("#", "POKé"),)
MAX_TEXT_LINE_WIDTH = 18  # PrintText starts at x=1 on a 20-column screen.
DYNAMIC_TOKEN_WIDTHS = {
    "<PLAYER>": 7,  # naming_screen.asm enforces a 7-character player name
    "<RIVAL>": 7,   # naming_screen.asm enforces a 7-character rival name
    "<TARGET>": 10, # Pokémon nicknames are limited to 10 characters
    "<USER>": 10,
}
ZERO_WIDTH_CONTROL_TOKENS = {
    "<CONT>", "<DONE>", "<PROMPT>", "<PAGE>", "<DEXEND>",
    "<NEXT>", "<LINE>", "<PARA>", "<NULL>", "<SCROLL>", "<_CONT>",
}
GLYPH_TOKEN_WIDTHS = {"<COLON>": 1, "<……>": 2}

# These are line-break-only corrections for three upstream English strings
# whose original line or the confirmed # -> POKé expansion exceeds the CHS
# text window's 18 visible columns. The words are unchanged.
TEXT_REFLOW_OVERRIDES = {
    "_LavenderHouse1Text_1d8d1": (
        '\ttext "That\'s odd,"\n'
        '\tline "MR.FUJI isn\'t"\n'
        '\tcont "here."\n'
        '\tcont "Where\'d he go?"\n'
        '\tdone\n'
    ),
    "_TM39ExplanationText": (
        '\ttext "TM39 is a move"\n'
        '\tline "called SWIFT."\n'
        '\tpara "It\'s very"\n'
        '\tline "accurate,"\n'
        '\tcont "so use it during"\n'
        '\tcont "battles you can\'t"\n'
        '\tcont "afford to lose."\n'
        '\tdone\n'
    ),
    "_Route12GateUpstairsText_495c4": (
        '\ttext "Looked into the"\n'
        '\tline "binoculars."\n'
        '\tpara "It\'s #MON"\n'
        '\tline "TOWER!"\n'
        '\tdone\n'
    ),
}
TEXT_REFLOW_SOURCE_SHA256 = {
    "_LavenderHouse1Text_1d8d1": "ced6d58e99c1516fdb8842b5a62ff90a5f220f26e90f83835bcf60f1e9a44c7a",
    "_TM39ExplanationText": "685a0074169461d8a3004befe38a1f50098f804ce622961de2e2e378da54ad90",
    "_Route12GateUpstairsText_495c4": "88cb11bcce98d37bfe32393245348bd1f611c79614ef89049954a49d16c6d503",
}
SECTION_BUDGET = 0x3000  # leave at least 4 KiB headroom in each 16 KiB ROMX bank
FIRST_ENGLISH_BANK = 0x62
LAST_ENGLISH_BANK = 0x7F


@dataclass(frozen=True)
class EnglishLabel:
    path: str
    body: str
    offset: int


def load_translation_tags(index_path: Path) -> tuple[set[str], Counter[str]]:
    raw = index_path.read_text(encoding="utf-8")
    # The existing RPP exporter leaves a trailing comma after the final row.
    raw = re.sub(r",\s*\]\s*$", "\n]", raw)
    rows = resource_audit.chs_tags(json.loads(raw))
    tags = [label for label, _book, _text in rows]
    return set(tags), Counter(tags)


def source_text_files(source_root: Path) -> list[Path]:
    files = sorted((source_root / "text").rglob("*.asm"))
    files.extend(sorted((source_root / "data" / "text").glob("text_[1-7].asm")))
    return files


def load_english_index(
    source_root: Path,
) -> tuple[dict[str, EnglishLabel], set[str]]:
    """Index same-generation English text and flag duplicate labels as unsafe."""
    result: dict[str, EnglishLabel] = {}
    duplicates: set[str] = set()
    for path in source_text_files(source_root):
        content = path.read_text(encoding="utf-8")
        labels = resource_audit.labels_in_asm(content)
        for i, (name, offset, end) in enumerate(labels):
            body_end = labels[i + 1][1] if i + 1 < len(labels) else len(content)
            entry = EnglishLabel(
                path.relative_to(source_root).as_posix(),
                content[end:body_end],
                offset,
            )
            if name in result:
                duplicates.add(name)
            else:
                result[name] = entry
    for name in duplicates:
        result.pop(name, None)
    return result, duplicates


def load_manual_overrides(source_root: Path) -> dict[str, EnglishLabel]:
    path = source_root / "data" / "english_text" / "manual_dialogue_overrides.json"
    if not path.is_file():
        return {}
    raw = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise ValueError("manual_dialogue_overrides.json must contain a JSON object")
    result: dict[str, EnglishLabel] = {}
    for label, body in raw.items():
        if not isinstance(label, str) or not LABEL_RE.fullmatch(label):
            raise ValueError(f"Invalid manual English override label: {label!r}")
        if not isinstance(body, str) or not body.strip():
            raise ValueError(f"Manual English override {label!r} must have a non-empty body")
        result[label] = EnglishLabel(
            path.relative_to(source_root).as_posix(), body, 0
        )
    return result


def find_script_refs(source_root: Path) -> list[tuple[str, int, str]]:
    refs: list[tuple[str, int, str]] = []
    for path in sorted((source_root / "scripts").rglob("*.asm")):
        for line_number, line in enumerate(
            path.read_text(encoding="utf-8").splitlines(), 1
        ):
            if not TEXT_FAR_START_RE.match(line):
                continue
            match = TEXT_FAR_RE.match(line)
            if match is None:
                raise ValueError(
                    f"Unsupported text_far syntax at {path.relative_to(source_root)}:{line_number}: {line}"
                )
            refs.append((
                path.relative_to(source_root).as_posix(),
                line_number,
                match.group("label"),
            ))
    return refs


def unsupported_tokens(body: str) -> set[str]:
    found: set[str] = set()
    for literal in STRING_RE.findall(body):
        found.update(ANGLE_TOKEN_RE.findall(literal[1:-1]))
    return found - SUPPORTED_ANGLE_TOKENS


def unsupported_commands(body: str) -> set[str]:
    found: set[str] = set()
    for raw_line in body.splitlines():
        code = raw_line.split(";", 1)[0].strip()
        if not code:
            continue
        match = re.match(r"^(text_(?:asm|far|bilingual))\b", code)
        if match:
            found.add(match.group(1))
    return found


def text_literal_sequence(body: str) -> str:
    return " ".join(literal[1:-1] for literal in STRING_RE.findall(body)).strip()


def effective_english_body(label: str, body: str) -> str:
    override = TEXT_REFLOW_OVERRIDES.get(label)
    if override is None:
        return body
    expected_hash = TEXT_REFLOW_SOURCE_SHA256[label]
    actual_hash = hashlib.sha256(body.encode("utf-8")).hexdigest()
    if actual_hash != expected_hash:
        raise ValueError(
            f"English source for {label} changed; review the stored line-reflow override"
        )
    if text_literal_sequence(body) != text_literal_sequence(override):
        raise ValueError(
            f"Line-reflow override for {label} changes literal wording; only line breaks are allowed"
        )
    return override


def visible_line_width(value: str) -> int:
    """Count displayed columns after known expansions and max-length names."""
    if value.endswith("@"):
        value = value[:-1]  # @ terminates PlaceString; it is not displayed.

    def expand(match: re.Match[str]) -> str:
        token = match.group(0)
        if token in DYNAMIC_TOKEN_WIDTHS:
            return "X" * DYNAMIC_TOKEN_WIDTHS[token]
        if token in ZERO_WIDTH_CONTROL_TOKENS:
            return ""
        if token in GLYPH_TOKEN_WIDTHS:
            return "X" * GLYPH_TOKEN_WIDTHS[token]
        return "X"  # unsupported tokens are separately blocked by the audit.

    return len(ANGLE_TOKEN_RE.sub(expand, value))


def line_width_violations(body: str) -> list[tuple[int, int, str]]:
    violations: list[tuple[int, int, str]] = []
    for line_number, raw_line in enumerate(body.splitlines(), 1):
        code = raw_line.split(";", 1)[0]
        if not re.match(r"^\s*(?:text|line|cont|para|next)\s+", code):
            continue
        for literal in STRING_RE.findall(code):
            value = literal[1:-1]
            for token, english in SPECIAL_EXPANSIONS:
                value = value.replace(token, english)
            width = visible_line_width(value)
            if width > MAX_TEXT_LINE_WIDTH:
                violations.append((line_number, width, value))
    return violations


def line_width_metrics(body: str) -> tuple[int, int]:
    checked = 0
    maximum = 0
    for raw_line in body.splitlines():
        code = raw_line.split(";", 1)[0]
        if not re.match(r"^\s*(?:text|line|cont|para|next)\s+", code):
            continue
        for literal in STRING_RE.findall(code):
            value = literal[1:-1]
            for token, english in SPECIAL_EXPANSIONS:
                value = value.replace(token, english)
            checked += 1
            maximum = max(maximum, visible_line_width(value))
    return checked, maximum


def normalize_english_body(body: str) -> tuple[str, Counter[str]]:
    """Convert only confirmed shared dictionary expansions inside literals."""
    replacements: Counter[str] = Counter()

    def replace_literal(match: re.Match[str]) -> str:
        literal = match.group(0)
        value = literal[1:-1]
        for token, english in SPECIAL_EXPANSIONS:
            count = value.count(token)
            if count:
                replacements[token] += count
                value = value.replace(token, english)
        return '"' + value + '"'

    return STRING_RE.sub(replace_literal, body), replacements


def estimate_body_size(body: str) -> int:
    """Conservative source-size estimate for splitting data into ROMX banks."""
    literal_bytes = sum(
        len(literal[1:-1]) for literal in STRING_RE.findall(body)
    )
    command_bytes = 0
    for raw_line in body.splitlines():
        code = raw_line.split(";", 1)[0].strip()
        if not code:
            continue
        command = code.split(None, 1)[0]
        if command in {"text", "line", "cont", "para", "next"}:
            command_bytes += 1
        elif command == "text_ram":
            command_bytes += 3
        elif command == "text_bcd":
            command_bytes += 4
        elif command == "text_decimal":
            command_bytes += 5
        elif command == "text_dots":
            command_bytes += 2
        elif command in {
            "text_start", "text_end", "text_pause", "text_waitbutton",
            "text_promptbutton", "text_scroll", "text_low", "done",
            "prompt", "page", "dex", "sound_get_item_1",
            "sound_get_item_1_duplicate", "sound_get_item_2",
            "sound_get_key_item", "sound_caught_mon", "sound_pokedex_rating",
            "sound_dex_page_added", "sound_cry_nidorina", "sound_cry_pidgeot",
            "sound_cry_dewgong",
        }:
            command_bytes += 1
        elif command == "db":
            # Raw byte directives are uncommon in English text; count their
            # comma-separated operands as a safe upper bound.
            command_bytes += max(1, code.count(",") + 1)
        elif command == "dw":
            command_bytes += 2 * max(1, code.count(",") + 1)
        else:
            command_bytes += 4
    return max(16, math.ceil((literal_bytes + command_bytes + 16) * 1.25))


def generated_english_data(
    labels: list[str], english_index: dict[str, EnglishLabel]
) -> tuple[str, Counter[str], int, list[int]]:
    chunks: list[list[tuple[str, str]]] = []
    current: list[tuple[str, str]] = []
    current_size = 0
    total_estimate = 0
    replacements: Counter[str] = Counter()

    for label in labels:
        entry = english_index[label]
        source_body = effective_english_body(label, entry.body)
        body, body_replacements = normalize_english_body(source_body)
        violations = line_width_violations(body)
        if violations:
            line_number, width, value = violations[0]
            raise ValueError(
                f"English text {label} line {line_number} is {width} columns "
                f"(maximum {MAX_TEXT_LINE_WIDTH}): {value!r}; add a safe line reflow"
            )
        estimate = estimate_body_size(body)
        if estimate > SECTION_BUDGET:
            raise ValueError(
                f"English text {label} estimates to {estimate} bytes; "
                f"exceeds the {SECTION_BUDGET:#x}-byte section budget"
            )
        if current and current_size + estimate > SECTION_BUDGET:
            chunks.append(current)
            current = []
            current_size = 0
        current.append((label, body))
        current_size += estimate
        total_estimate += estimate
        replacements.update(body_replacements)
    if current:
        chunks.append(current)

    bank_numbers = [FIRST_ENGLISH_BANK + i for i in range(len(chunks))]
    if bank_numbers and bank_numbers[-1] > LAST_ENGLISH_BANK:
        raise ValueError(
            f"Generated English data needs {len(chunks)} banks, but only "
            f"${FIRST_ENGLISH_BANK:02X}-${LAST_ENGLISH_BANK:02X} are reserved"
        )

    output = [
        "; AUTO-GENERATED by scripts/generate_bilingual_dialogue.py.",
        "; Do not edit this file directly; edit src/text or manual_dialogue_overrides.json.",
        "; Fixed ROMX banks keep the English data away from tight low-numbered banks.",
        "",
    ]
    for index, chunk in enumerate(chunks):
        bank = bank_numbers[index]
        output.append(
            f'SECTION "English Dialogue {index + 1:02d}", ROMX, BANK[${bank:02X}]'
        )
        output.append("")
        for label, body in chunk:
            output.append(f"{label}_EN::")
            output.append(body.lstrip("\n").rstrip())
            output.append("")
    return "\n".join(output).rstrip() + "\n", replacements, total_estimate, bank_numbers


def transform_build_scripts(
    source_root: Path, build_root: Path, routed_labels: set[str]
) -> tuple[int, list[str]]:
    routed_refs = 0
    generated_script_paths: list[str] = []
    for source_path in sorted((source_root / "scripts").rglob("*.asm")):
        rel = source_path.relative_to(source_root)
        build_path = build_root / rel
        original_lines = source_path.read_text(encoding="utf-8").splitlines()
        output_lines: list[str] = []
        file_replacements = 0
        for line in original_lines:
            match = TEXT_FAR_RE.match(line)
            if match and match.group("label") in routed_labels:
                label = match.group("label")
                tail = match.group("tail") or ""
                output_lines.append(
                    f'{match.group("indent")}text_bilingual {label}, {label}_EN{tail}'
                )
                file_replacements += 1
            else:
                output_lines.append(line)
        output = "\n".join(output_lines) + "\n"
        build_path.parent.mkdir(parents=True, exist_ok=True)
        # Write only when bytes differ, so an unchanged build keeps make's
        # timestamps and compiled objects reusable.
        if not build_path.is_file() or build_path.read_text(encoding="utf-8") != output:
            build_path.write_text(output, encoding="utf-8")
            shutil.copymode(source_path, build_path)
        if file_replacements:
            routed_refs += file_replacements
            generated_script_paths.append(rel.as_posix())
    return routed_refs, generated_script_paths


def make_manifest_rows(
    tags: set[str],
    english_index: dict[str, EnglishLabel],
    refs: list[tuple[str, int, str]],
    routed_labels: set[str],
    unsafe_labels: set[str],
) -> list[dict[str, str]]:
    ref_counts = Counter(label for _path, _line, label in refs)
    rows: list[dict[str, str]] = []
    for label in sorted(tags):
        entry = english_index.get(label)
        body = effective_english_body(label, entry.body) if entry else ""
        dynamic = ",".join(sorted(set(DYNAMIC_TOKEN_RE.findall(body))))
        runtime = ",".join(sorted(set(RUNTIME_COMMAND_RE.findall(body))))
        special = ",".join(
            token for token, _english in SPECIAL_EXPANSIONS if token in body
        )
        unsupported = ",".join(sorted(unsupported_tokens(body)))
        commands = ",".join(sorted(unsupported_commands(body)))
        if label in unsafe_labels:
            status = "manual_review"
        elif label in routed_labels and entry and entry.path.endswith("manual_dialogue_overrides.json"):
            status = "manual_english_override"
        elif label in routed_labels:
            status = "auto_routed"
        elif ref_counts[label] and not entry:
            status = "missing_english_source"
        elif ref_counts[label]:
            status = "not_routed"
        elif entry:
            status = "outside_map_script_scope"
        else:
            status = "missing_english_source"
        rows.append({
            "label": label,
            "english_source": entry.path if entry else "",
            "map_script_refs": str(ref_counts[label]),
            "dynamic_tokens": dynamic,
            "runtime_data_commands": runtime,
            "special_expansions": special,
            "unsupported_tokens": unsupported,
            "unsupported_commands": commands,
            "line_reflow": "yes" if label in TEXT_REFLOW_OVERRIDES else "no",
            "status": status,
        })
    return rows


def write_report(
    report_path: Path,
    summary: dict,
    missing_translation_labels: list[str],
    custom_manual_labels: list[str],
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    missing_text = ", ".join(f"`{name}`" for name in missing_translation_labels) or "无"
    custom_text = ", ".join(f"`{name}`" for name in custom_manual_labels) or "无"
    bank_range = (
        f'${summary["english_banks"][0]:02X}-${summary["english_banks"][-1]:02X}'
        if summary["english_banks"] else "无"
    )
    report_path.write_text(f"""# ROM-1.41 地图脚本对白批量双语接入审计

状态：正式源码清理候选；生成器与静态回归通过。热修后红／蓝构建 MAP 与完整实机回归仍由维护者完成。

## 覆盖结果

- `_G1RB.json` 原始翻译记录：**{summary['translation_rows']}**；唯一翻译标签：**{summary['translated_tags']}**。
- 同代英文源码标签数：**{summary['english_source_labels']}**；翻译标签中可直接匹配：**{summary['english_source_tags']}**；缺少同代英文原文：**{summary['missing_source_tags']}**。
- 手工英文补充：**{summary['manual_override_tags']}** 条，其中 CHS 新增且不在翻译索引中的文本 **{summary['custom_manual_tags']}** 条。
- `src/scripts/` 中 `text_far` 引用：**{summary['script_far_refs']}** 条；批量接入：**{summary['routed_refs']}** 条、**{summary['routed_labels']}** 个唯一文本标签。
- 两条既有 ROM-1.41A/B English pilot wrapper 引用保留原样：**{summary['ignored_existing_english_refs']}** 条；未分类引用：**{summary['unclassified_script_refs']}** 条；应接入但未路由：**{summary['unrouted_script_refs']}** 条。
- 双指针命令相对原 `text_far` 每条增加 3 bytes；本轮总增量：**{summary['pointer_overhead_bytes']:,} bytes**。
- 英文文本数据估算：约 **{summary['estimated_english_bytes']:,} bytes**，拆为 **{summary['english_sections']} 个 ROMX 段**，固定放在 **{bank_range}**。估算只用于分段，不是最终 MAP 占用。
- 未被地图脚本 `text_far` 调用的翻译标签：**{summary['outside_map_scope']}**；本轮不把它们误报为已完成。

## 运行时处理与特殊文字

- 新增 `TX_BILINGUAL`（`$18`），载荷包含 CHS 与 English 两个三字节 far pointer；运行时按 `wOptions` bit 5 选择指针，再复用原 `TextCommand_FAR` 读取流程。
- ROM0 新增双语命令分派与双指针选择代码；早期 18-byte 估算属于 HF1 之前的候选，不作为正式版实际占用。随包 `MAP_20261107_080844.zip` 是 HF1 之前的 ROM-1.41C MAP，不能用于本正式源码的 ROM0 余量结论。
- 不增加 WRAM、SRAM 或存档字段。生成器将英文数据固定分配到 ROMX `$62-$6F` 共 **{summary['english_sections']}** 个 section；Bank 余量必须以 HF1 与正式版号调整后的红／蓝新 MAP 为准。
- 已确认的 `#` 特殊字典扩展只在英文字符串字面量中改为普通 `POKé` 字符；本轮共处理 **{summary['special_replacements'].get('#', 0)}** 处。该修正依据 ROM-1.41B 用户录像确认的 `PlacePOKe` 行为。
- `<PLAYER>`、`<RIVAL>` 等动态占位符以及 `text_ram`、`text_decimal`、`text_bcd` 命令原样保留。玩家／劲敌命名界面限制为 7 字符，静态行宽检查按该上限计算；运行时变量指向的名称表／内容不因此自动变成英文。
- 为满足标准对话框 18 列宽度，生成器检查 **{summary['checked_text_lines']:,}** 行可见文本；展开后的最大行宽为 **{summary['max_text_line_width']}/18**。另对 **{len(summary['line_reflow_labels'])}** 条原版英文对白仅调整换行、不改词句：{", ".join(f'`{label}`' for label in summary['line_reflow_labels']) or "无"}。超宽未处理时拒绝生成。
- `<COLON>` 是 charmap 中定义的小型冒号字形，按普通字符保留。未知特殊 token（如 `<PC>`、`<ROCKET>`、`<TM>`、`<TRAINER>`、`<PKMN>`）不会猜测替换；含未知 token、`text_asm` 或嵌套 `text_far` 的文本会被 fail-closed 留待人工复核。
- 当前全量翻译索引中仍有 1 个 `<PKMN>` 特殊字典 token，但它不属于本轮 `src/scripts/` 地图脚本调用范围；本轮地图范围内被阻止自动接入的未知 token 文本数：**{summary['unsafe_token_labels_in_map_scope']}**。
- 本轮地图脚本对白包含脚本直接调用的 NPC、地图提示、道具／教学及训练家对战前后对白；这不等于已接入战斗引擎、菜单、图鉴、名称表或全部 UI 的独立文本入口。

## 人工补充与未覆盖项

- 翻译索引中有、但同代英文源码缺少的地图脚本标签：{missing_text}。该项由 `manual_dialogue_overrides.json` 补充，不标为原版英文原文。
- 另外 7 条 CHS 分支新增硬编码文本：{custom_text}。它们的英文稿是项目人工补充，不是上游原文，需维护者／用户检查措辞与行宽。
- `text_ram` 等动态变量指向的物品、技能、宝可梦名称仍取决于现有名称系统；本轮不改名称表语言兼容逻辑。
- 其余 511 个未被地图脚本 `text_far` 调用的翻译标签，以及战斗引擎、菜单、图鉴、名称和其他 UI 的独立入口，留给后续阶段。

## 构建与验证边界

- `scripts/prepare_build.py` 在 XLSX 导入后生成 `buildRB/data/english_text/generated_dialogue.asm`，并在 `buildRB/scripts/` 中重写可路由的 `text_far`。`src/scripts/` 和 XLSX 不被生成器改写。
- 单元测试、静态源检查与构建前置生成检查不等于 RGBDS 编译／链接或手机实机验收。
- 本轮未运行 RGBDS／`rgblink`，未生成正式 ROM、HF1 后 MAP 或 ROM SHA-256；未执行 Git Commit／Push。用户已提供 HF1 后的 NPC 实测视频，但没有提供 HF1 后红／蓝 MAP 与 ROM SHA。最终 Bank 余量及完整红蓝构建仍待维护者确认。
""", encoding="utf-8")


def write_tsv(tsv_path: Path, rows: list[dict[str, str]]) -> None:
    tsv_path.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "label", "english_source", "map_script_refs", "dynamic_tokens",
        "runtime_data_commands", "special_expansions", "unsupported_tokens",
        "unsupported_commands", "line_reflow", "status",
    ]
    with tsv_path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(
            stream, fieldnames=fields, delimiter="\t", lineterminator="\n"
        )
        writer.writeheader()
        writer.writerows(rows)


def generate(
    source_root: Path,
    build_root: Path,
    report_path: Path | None = None,
    tsv_path: Path | None = None,
) -> dict:
    source_root = source_root.resolve()
    build_root = build_root.resolve()
    translation_tags, tag_counts = load_translation_tags(source_root / "_G1RB.json")
    original_english_index, duplicate_english_labels = load_english_index(source_root)
    manual_overrides = load_manual_overrides(source_root)
    for label in manual_overrides:
        if label in original_english_index or label in duplicate_english_labels:
            raise ValueError(f"Manual override duplicates an English source label: {label}")

    tags = set(translation_tags) | set(manual_overrides)
    english_index = dict(original_english_index)
    english_index.update(manual_overrides)
    refs = find_script_refs(source_root)
    ref_counts = Counter(label for _path, _line, label in refs)

    unclassified_refs = sorted({
        label for _path, _line, label in refs
        if label not in tags and label not in EXISTING_ENGLISH_REFS
    })
    if unclassified_refs:
        raise ValueError(
            "Unclassified src/scripts text_far labels; add a translation tag, "
            f"manual English override, or explicit existing-English allowlist: {unclassified_refs}"
        )

    duplicate_refs = sorted(set(ref_counts) & duplicate_english_labels)
    unsafe_labels = {
        label for label in tags
        if label in english_index and (
            unsupported_tokens(english_index[label].body)
            or unsupported_commands(english_index[label].body)
        )
    }
    unsafe_labels.update(duplicate_refs)
    routed_labels = {
        label for label in tags
        if ref_counts[label] > 0 and label in english_index and label not in unsafe_labels
    }
    missing_original_labels = sorted(
        label for label in translation_tags
        if ref_counts[label] > 0 and label not in original_english_index
    )
    custom_manual_labels = sorted(set(manual_overrides) - set(translation_tags))
    missing_script_labels = sorted(
        label for label in tags if ref_counts[label] > 0 and label not in english_index
    )

    ordered_labels = sorted(
        routed_labels,
        key=lambda label: (
            english_index[label].path,
            english_index[label].offset,
            label,
        ),
    )
    checked_text_lines = 0
    max_text_line_width = 0
    for label in ordered_labels:
        normalized, _ = normalize_english_body(
            effective_english_body(label, english_index[label].body)
        )
        checked, maximum = line_width_metrics(normalized)
        checked_text_lines += checked
        max_text_line_width = max(max_text_line_width, maximum)
    english_asm, special_replacements, estimated_bytes, bank_numbers = (
        generated_english_data(ordered_labels, english_index)
    )
    generated_path = build_root / "data" / "english_text" / "generated_dialogue.asm"
    generated_path.parent.mkdir(parents=True, exist_ok=True)
    if not generated_path.is_file() or generated_path.read_text(encoding="utf-8") != english_asm:
        generated_path.write_text(english_asm, encoding="utf-8")

    routed_refs, changed_scripts = transform_build_scripts(
        source_root, build_root, routed_labels
    )
    expected_routed_refs = sum(ref_counts[label] for label in routed_labels)
    if routed_refs != expected_routed_refs:
        raise RuntimeError(
            f"Generated {routed_refs} bilingual references but expected {expected_routed_refs}"
        )

    manifest_rows = make_manifest_rows(
        tags, english_index, refs, routed_labels, unsafe_labels
    )
    dynamic_labels = sum(
        bool(DYNAMIC_TOKEN_RE.search(effective_english_body(label, english_index[label].body)))
        for label in routed_labels
    )
    runtime_labels = sum(
        bool(RUNTIME_COMMAND_RE.search(effective_english_body(label, english_index[label].body)))
        for label in routed_labels
    )
    ignored_refs = sum(ref_counts[label] for label in EXISTING_ENGLISH_REFS)
    summary = {
        "translation_rows": sum(tag_counts.values()),
        "translated_tags": len(translation_tags),
        "effective_tags": len(tags),
        "english_source_labels": len(original_english_index),
        "duplicate_english_labels": sorted(duplicate_english_labels),
        "english_source_tags": sum(label in original_english_index for label in translation_tags),
        "missing_source_tags": sum(label not in original_english_index for label in translation_tags),
        "manual_override_tags": len(manual_overrides),
        "custom_manual_tags": len(custom_manual_labels),
        "script_far_refs": len(refs),
        "routed_refs": routed_refs,
        "ignored_existing_english_refs": ignored_refs,
        "unclassified_script_refs": len(unclassified_refs),
        "unrouted_script_refs": sum(
            ref_counts[label] for label in tags if ref_counts[label] and label not in routed_labels
        ),
        "pointer_overhead_bytes": routed_refs * 3,
        "routed_labels": len(routed_labels),
        "outside_map_scope": sum(
            label in original_english_index and ref_counts[label] == 0
            for label in translation_tags
        ),
        "dynamic_labels": dynamic_labels,
        "runtime_labels": runtime_labels,
        "line_reflow_labels": sorted(label for label in routed_labels if label in TEXT_REFLOW_OVERRIDES),
        "checked_text_lines": checked_text_lines,
        "max_text_line_width": max_text_line_width,
        "estimated_english_bytes": estimated_bytes,
        "english_sections": len(bank_numbers),
        "english_banks": bank_numbers,
        "special_replacements": dict(special_replacements),
        "changed_scripts": len(changed_scripts),
        "generated_files": sorted(changed_scripts + [
            "data/english_text/generated_dialogue.asm"
        ]),
        "unsafe_token_labels_in_map_scope": sum(
            bool(unsupported_tokens(english_index[label].body))
            for label in unsafe_labels if label in ref_counts and label in english_index
        ),
        "unsafe_tokens_in_map_scope": sorted({
            token for label in unsafe_labels if label in ref_counts and label in english_index
            for token in unsupported_tokens(english_index[label].body)
        }),
        "unsafe_tokens_outside_map_scope": sorted({
            token for label in unsafe_labels if label not in ref_counts and label in english_index
            for token in unsupported_tokens(english_index[label].body)
        }),
        "unsafe_commands": sorted({
            command for label in unsafe_labels if label in english_index
            for command in unsupported_commands(english_index[label].body)
        }),
        "missing_script_labels": missing_script_labels,
        "missing_translation_labels": missing_original_labels,
        "custom_manual_labels": custom_manual_labels,
        "duplicate_translation_tags": {
            label: count for label, count in tag_counts.items() if count > 1
        },
    }
    if report_path:
        write_report(report_path, summary, missing_original_labels, custom_manual_labels)
    if tsv_path:
        write_tsv(tsv_path, manifest_rows)
    return summary


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--build-root", type=Path, required=True)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--tsv", type=Path)
    args = parser.parse_args()
    summary = generate(args.source_root, args.build_root, args.report, args.tsv)
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
