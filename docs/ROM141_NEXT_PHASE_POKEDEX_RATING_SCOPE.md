# 图鉴评价文字双语接入：ROM-1.42A 用户验收记录

状态：本文件是 ROM-1.41 末期的阶段范围记录。图鉴评价的 19 个标签已在 ROM-1.42A 接入；当时列为下一阶段的名人堂 PLAY TIME／MONEY、Trainer Card 和 Continue／Save 固定信息标签，已在 ROM-1.42B 接入，并随正式清理成为 ROM-1.42。当前全项目状态与后续路线以 `docs/BILINGUAL_PROJECT_PLAN.md` 为准；玩家资料实现及用户反馈见 `docs/ROM142B_PLAYER_INFO_BILINGUAL.md`。

用户录像确认的图鉴评价场景仍作为历史验收证据保留；该反馈只覆盖录像展示的界面，不代表红／蓝及 DMG／CGB 全平台矩阵验收。ROM-1.41 的原始发现记录保留在本文后半部分。

## 本轮实际接入范围

- `DisplayDexRating` 的 1 段完成度统计 `_DexCompletionText`。
- 16 个拥有数量阈值评价 `_DexRatingText_Own0To9` 至 `_DexRatingText_Own150To151`。
- Hall of Fame 复用的 2 段统计文字 `_DexSeenOwnedText` 与 `_DexRatingText`。
- 总计 **19 个英文文本标签**，全部来自当前项目同代英文源码；没有为原版已有文字另写一份人工译文。

## 实现方式

1. `src/engine/events/pokedex_rating.asm` 中完成度与 16 档评价 wrapper 改用 `text_bilingual CHS, English_EN`。
2. `src/engine/movie/hall_of_fame.asm` 中 `DexSeenOwnedText` 与 `DexRatingText` 两个 wrapper 同样使用 `text_bilingual`。
3. 现有 `scripts/generate_bilingual_dialogue.py` 扩展为同时生成 `buildRB/data/english_text/generated_pokedex_ratings.asm`；不新建重复生成器，不改 CHS XLSX／源文本。
4. `src/main.asm` 在独立 ROMX Bank `$70` 收录生成的英文图鉴评价数据。ROM-1.41 MAP 显示 `$70` 空余 16,384 bytes；19 个英文标签估算 1,661 bytes。17 个评价 wrapper 在 Bank `$11` 增加 51 bytes，2 个名人堂 wrapper 在 Bank `$1C` 增加 6 bytes；ROM0 只因 9 字符版号增加 1 byte。上述均为旧 MAP 投影，不是 ROM-1.42A 最终 MAP 证明。
5. Hall of Fame 原逻辑把被选中的 rating wrapper 复制到 `wDexRatingText`，直到 `TX_END`。现在复制的是 8-byte `text_bilingual` wrapper（opcode＋6-byte 双 far pointer＋terminator）；`wDexRatingText` 位于现有 180-byte WRAM union 内，不增加 WRAM/SRAM／存档字段。

## 保留的运行行为

- `DisplayDexRating` 的 seen／owned bit 统计、`DexRatingsTable` 的 16 个阈值及分支顺序不变。
- `hDexRatingNumMonsSeen`、`hDexRatingNumMonsOwned`、`wDexRatingNumMonsSeen`、`wDexRatingNumMonsOwned` 的 `text_decimal` 动态数字命令原样保留。
- 英文文本字面量中的 `#MON`／`#DEX` 展开为普通 `POKéMON`／`POKéDEX`，避免英文分支调用 CHS 的 `PlacePOKe` 特殊扩展；只处理已验证的 `#` 字典行为。
- 语言选择沿用既有 `wOptions` bit 5；中文源文本与中文 XLSX 不改。
- 共用 YES／NO 菜单仍按用户决定暂时保持中文；图鉴列表、图鉴条目、地点、战斗、宝可梦／技能／道具名称和其它 UI 不在本轮范围。

## 静态验证与构建边界

- 19 个英文标签必须全部存在且无重复；未知 token／命令、缺失标签或超过 18 列时生成器 fail-closed。
- 当前英文数据估算约 **1.7 KB**，固定 Bank `$70`；19 个标签共检查 **66 行**可见文本，并把 3 位动态计数与相邻文字合并计算，最大宽度 **18/18**；`#` 共转换 **10 处**。
- 静态检查器核对 16 档阈值表不变、两组实时 seen／owned 数字命令保留、HOF wrapper copy 仍以 `TX_END` 终止、8-byte wrapper 位于现有 WRAM union。
- 本轮不运行 RGBDS／`rgblink`，不生成 ROM／MAP／SHA。维护者必须用 ROM-1.42A 分别构建红／蓝并检查 Bank `$70`、ROM0、总 ROM 容量；当前 ROM-1.41 MAP 不能替代新构建 MAP。

## 用户实机验收记录

- `1.42A.mp4`：用户录像显示 English 模式下 Oak's Lab 的图鉴评价文字正常显示英文。
- `名人堂评价.mp4`：用户录像显示 Hall of Fame 的 Seen／Owned／Rating 标签和评价正文均为英文，Seen／Owned 动态数量为 151／151；评价正文与 Oak's Lab 相同。
- 用户明确反馈没有在对话中途切换语言；中文模式全程中文且正常。
- 本轮未据此宣称红／蓝、DMG／CGB 全矩阵、所有 16 档评价分支或所有存档重启路径全部通过。

---

## ROM-1.41 原始发现记录


## 用户实测现象

用户提供 `1.41C，其他三位NPC测试.mp4`。在 English 模式下，与大木博士交谈时，地图脚本中的开场对白显示英文，例如 `OAK: Good to see you! How is your POKéDEX coming? Here, let me take a look!`；紧接着图鉴统计／评价部分又显示中文。用户明确说明同一次对话中没有手动切换语言；中文模式全程显示中文，没有同类问题。

这不是中英文设置自行跳回中文，而是同一段 NPC 交互先后调用了两个不同文本入口。

## 源码调用链

1. `src/scripts/OaksLab.asm` 的 `OaksLabText5` 先调用 `OaksLabText_1d31d`，其 `text_far _OaksLabText_1d31d` 属于 `src/scripts/` 地图脚本范围，因此由 ROM-1.41 地图对白生成器接入 `text_bilingual`。
2. 同一脚本随后执行 `predef DisplayDexRating`。
3. `src/engine/events/pokedex_rating.asm` 的 `DisplayDexRating` 独立统计已见／已捕获数量，并通过 `DexRatingsTable` 选择评价等级；它直接调用 `_DexCompletionText` 和 `_DexRatingText_Own0To9` 至 `_DexRatingText_Own150To151` 等引擎文本入口。
4. 这些评价文字定义在 `src/text/pokedex_ratings.asm`，并非由 `src/scripts/` 的 `text_far` 调用，因此当前地图脚本生成器不会改写它们。数量还包含 `text_decimal` 动态值。

## 结论与边界

- ROM-1.41 的地图对白切换在该场景已经生效；切回中文后地图对白仍为中文。
- 图鉴完成度统计、数量和博士评价由独立引擎流程输出，尚未接入 LANGUAGE。此项是后续图鉴系统双语工作，不应回头扩大本阶段地图对白生成器的匹配范围。
- 当前用户明确允许「是／否」等选择菜单暂时保持中文。选择菜单属于另一套共用 UI 文本，不纳入本次修复。

## 后续图鉴阶段建议测试范围

1. 图鉴数量统计：seen／owned 动态数字及中英文标签。
2. 16 个拥有数量阈值评价分支（0–9 至 150–151），逐档检查指针、分页和文字宽度。
3. `#MON`、`#DEX` 等特殊字典扩展，必须按运行时真实语义转换，不能机械替换。
4. English 与中文分别检查同一次完整交互：开场、数量、评价；确认语言不会在子流程间混杂。
5. 评价完成后回到地图、再与博士对话，检查重复进入和事件状态。

本阶段不新增图鉴代码，不改变现有 `DisplayDexRating` 统计逻辑、阈值、声音或事件行为。
