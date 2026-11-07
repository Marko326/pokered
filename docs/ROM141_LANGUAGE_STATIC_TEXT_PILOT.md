# ROM-1.41A 双语静态 NPC 文本读取原型

状态：开发候选，等待维护者构建与用户手机验收
分支：`CHS_Mod`
本轮 Git 基线：`bd091a28bf2e1f87de59c44be694b35d7d8b4405`
正式基线版本：`ROM-1.40`
测试候选版本：`ROM-1.41A`

## 目标与边界

本轮把 ROM-1.39/1.40 的 LANGUAGE 试点从一位 Route 1 NPC 扩展为可复用的静态文本读取模式，并在 Viridian City 增加第二个纯静态 NPC 样本。它验证的是“同一条地图文本入口按 `wOptions` bit 5 选择 CHS/English 远程文本”的基本路径，不是全游戏英文覆盖。

A 版原本意图选择无动态插值的静态 NPC 文本，但后来实机录像证明 Viridian City 样本中的 `#` 会触发 `PlacePOKe` 特殊扩展；因此 A 版对该样本的静态分类是错误的，详见后文 ROM-1.41B 修正记录。动态对白、战斗、图鉴、菜单、路牌、道具说明及其它特殊脚本不在本轮范围内。

## 实现

1. 在 `src/macros/scripts/text.asm` 新增 `bilingual_text` 宏。它读取已持久化的 `wOptions` bit 5：0 选择 CHS far-text wrapper，1 选择 English far-text wrapper；最终仍由原 `PrintText` 和 `TextScriptEnd` 处理。
2. 将已有 `Route1Text2` 选择代码改为调用该宏，CHS 指针 `_Route1Text2` 不变。
3. 将第二个纯静态 NPC 样本 `ViridianCityText1` 接入同一宏。CHS 仍指向 `_ViridianCityText1`，English 指向新增的 `_ViridianCityText1English`。
4. 把两个英文副本统一放入 `src/data/english_text/english_pilot.asm`，由 `src/main.asm` 的 ROMX Bank `$46` 独立收录。该文件路径不在任何 XLSX 工作表的输出路径清单中，CHS Excel 导入不会覆盖英文副本。
5. 原 Route 1 英文样本从 Options Bank `$45` 移到专用 English data Bank `$46`；Options 页面逻辑和 LANGUAGE bit 的存档行为不变。

## 空间与兼容性

ROM-1.40 随包 MAP 是本轮可用的旧版空间参考，不是本轮构建结果：

- ROM0 当时剩余 464 bytes；本轮没有新增 ROM0 执行代码。测试版号从 8 字符 `ROM-1.40` 增为 9 字符 `ROM-1.41A`，版本字符串本身在 ROM0 只增加 1 byte。
- 脚本所在 Bank `$06`、`$07` 在 ROM-1.40 MAP 中分别有 0x15D4（5588）和 0x0B9D（2973）bytes 空闲；本轮宏会在这两个地图脚本 Bank 中展开少量选择代码。
- Options Bank `$45` 在参考 MAP 中有 0x3A50（14928）bytes 空闲；原 Route 1 英文样本已从该 Bank 移出。
- English data Bank `$46` 在 ROM-1.40 参考 MAP 中为空，本轮只向其中增加两段静态文本。最终占用及剩余空间必须以维护者本地新 MAP 为准。

不新增 WRAM/SRAM 字节，不修改 `wOptions` bit 5 的含义，不修改存档结构、翻译 XLSX、文本导入工具或 ROM 构建脚本。以上空间数字只来自 ROM-1.40 随包 MAP，不能冒充 ROM-1.41A 新 MAP。

## 静态核对

本轮可在不编译 ROM 的前提下检查：

- 两个地图脚本均使用同一 `bilingual_text` 宏。
- CHS wrapper 仍指向原汉化标签；English wrapper 指向独立 Bank `$46` 标签。
- 两段 English 文本与同代 `src/text/*.asm` 原始英文内容逐行一致。
- 新英文数据文件不位于 XLSX 导入覆盖目录。
- 不改 `src/ram/`、SRAM、翻译工作簿、转换器或审计脚本。
- 不新增 ROM0 执行代码；不运行 RGBDS、不链接 ROM、不生成新 ROM/MAP/SHA。

这些是源码静态核对，不等于 RGBDS 编译通过或手机实机 PASS。

## 最小手机验收

1. LANGUAGE=中文：Route 1 第二位 NPC 和 Viridian City 第一位 NPC 均显示原有中文。
2. LANGUAGE=English：上述两位 NPC 分别显示对应英文原文，换行、分页、符号均正常。
3. 切回中文后，两处立即恢复中文；保存、退出并重启后设置仍按原有存档行为保留。
4. 确认未接入的 Route 1 第一位赠药 NPC、Route 1 路牌及 Viridian City 其它 NPC 仍保持当前 CHS 行为，不把未覆盖内容误认为英文已实现。
5. A 版实测已发现 `#MON`／`# BALL` 会调用 CHS 扩展；B 版改用普通英文 `POKéMON`／`POKé BALLs`，重新构建后按维护者矩阵检查字宽、分页和语言切换。

## 下一步

两个静态样本通过手机验收后，再从盘点 TSV 中挑选更多 `complex_control_or_placeholder=no` 的 NPC 标签，按 Bank 容量分批接入。动态文本必须单独分析，不能直接套用本宏。

## 补丁交付修正记录（2026-11-07）

首次交付的 ROM-1.41A 补丁把“增量补丁”和“基线全量补丁”都错误地从干净 HEAD `bd091a28...` 生成，没有把用户已应用的 `ROM-1.40.patch`（Git 历史审计文档变更）纳入增量补丁的前置状态。

用户提供的 `ROM-1.40.patch` 对应当前已应用状态，包含：
- `TODO.md` 中的 Git 历史与 Bundle 核查记录；
- 新增 `docs/ROM140_GIT_HISTORY_AUDIT.md`。

因此，旧 ROM-1.41A 补丁若直接应用到该状态，会因 `TODO.md` 上下文已变化，以及 `docs/ROM140_GIT_HISTORY_AUDIT.md` 已存在而失败。这是补丁基线制作错误，不是用户操作错误。

本修正版交付明确区分：
- **增量补丁**：以上述 `ROM-1.40.patch` 已应用状态为前置，更新到 ROM-1.41A；
- **全量补丁**：从干净 `CHS_Mod` HEAD `bd091a28...` 一次性重建 ROM-1.41A 全部累计改动。

两份补丁是替代应用方式，不能叠加。已分别在临时 Git 克隆中验证正向应用、`git diff --check`、反向恢复；增量补丁反向恢复后与 `ROM-1.40.patch` 状态逐文件 SHA-256 一致，全量补丁反向恢复后工作区干净。此修正未修改游戏运行逻辑，也未执行 Commit/Push。


## ROM-1.41A 用户录像问题与 ROM-1.41B 修正

用户于 2026-11-07 提供实机录像 `66426.mp4`。录像确认 LANGUAGE=English 时，Viridian City 英文样本中的 `#` 仍触发 CHS 特殊文字扩展，实际显示“宝可梦 BALLs / 宝可梦 MON”。因此 A 版“纯静态、无动态占位符”的描述不准确，A 版未通过实机验收。

根因：`src/home/text.asm` 的字典把 `#` 分派到 `PlacePOKe`，而 CHS 构建的共享 `PlacePOKeText` 扩展已本地化；`src/tools/_importText.py` 也保留了 `#MON`／`#`／“宝可梦”的替换规则。英文副本沿用原版 `#MON`，因此调用了中文扩展。

ROM-1.41B 仅将英文副本中的 `#MON` 和 `# BALLs` 改为普通字符 `POKéMON` 与 `POKé BALLs`，避免触发 `#` 特殊命令。最长行 17 字符，必须由维护者构建并复测实际字宽、换行和分页。中文文本、共享 `PlacePOKe` 扩展和存档结构不改。

这次暴露出一个通用原则：英文文本不能只按原版 ASM 字面内容复制。`#`、`<PKMN>`、`<PC>`、`<ROCKET>`、`<TM>`、`<TRAINER>` 等特殊文字扩展需要逐项确认其运行时输出是否已被 CHS 本地化；`<PLAYER>`、`<RIVAL>`、`<USER>`、`<TARGET>` 等动态内容及 `<CONT>`、`<PAGE>` 等控制命令则必须保留原语义。完整清单与当前边界见 `docs/ROM141B_SPECIAL_TOKEN_AUDIT.md`。

ROM-1.41B 仍是开发候选。未编译／链接 ROM，未生成新 MAP/SHA；不得将源码静态检查记作实机 PASS。


## ROM-1.41C — 地图脚本对白批量接入（2026-11-07）

ROM-1.41C 在 A/B 两个单点样本和 `#` 特殊扩展修正基础上，增加 `TX_BILINGUAL` 双指针文本命令。它不是逐个复制 wrapper，而是每个脚本引用保留原 CHS far pointer，再附加同代英文 far pointer；运行时按 `wOptions` bit 5 选择并复用原 far-text 处理器。

- 自动接入 `src/scripts/` 中 1,942 条 `text_far` 引用（1,941 个唯一标签）；两个已有英文 pilot wrapper 仍保留原样。
- 英文数据从 `src/text/` 与 `src/data/text/text_1..7.asm` 复制到 ROMX `$62-$6F`；CHS 分支新增文本通过 8 条独立人工补充处理。
- `#` 只在英文字符串字面量中转为 `POKé`；动态姓名、运行时数据命令和控制语义保留。未知特殊 token 或不安全命令不自动路由。
- 通过 18 列静态行宽检查；对 `_LavenderHouse1Text_1d8d1`、`_TM39ExplanationText`、`_Route12GateUpstairsText_495c4` 仅调整换行，不改原词句。
- 生成器集成于 `scripts/prepare_build.py`，只写 `buildRB/`；8 项单元测试、构建前置生成和专用静态验证均通过。详见 `docs/ROM141_MAP_DIALOGUE_BILINGUAL.md`、`docs/ROM141_MAP_DIALOGUE_MANIFEST.tsv` 与 `docs/ROM141C_MAP_SPACE_PROJECTION.md`。

本轮仍是 `ROM-1.41C` 开发候选。没有 RGBDS 编译／链接、没有新 ROM/MAP/SHA、没有手机实机验收。源码侧地图脚本对白已批量接入，但不能据此宣称全游戏英文完成或第一阶段已获最终用户验收。
