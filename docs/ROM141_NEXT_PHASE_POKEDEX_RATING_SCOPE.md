# 下一阶段范围记录：图鉴评价文字双语接入

状态：已由用户录像复现；明确属于地图脚本对白批量接入范围之外，本阶段只登记，不修改。

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
