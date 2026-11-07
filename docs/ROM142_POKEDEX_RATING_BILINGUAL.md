# ROM-1.42 图鉴统计与博士评价双语接入（ROM-1.42A 开发记录）

> 全游戏双语化当前路线与范围以 `docs/BILINGUAL_PROJECT_PLAN.md` 为准；本文件只记录本模块的实现、审计和历史验收。

状态：已纳入正式版本 ROM-1.42；源码接入和静态验证完成。用户录像确认 Oak's Lab 与 Hall of Fame 所展示场景的英文标签正常，中文模式正常；红／蓝新构建、全阈值和全平台矩阵仍待维护者验收。

## 基线与版本

- 输入文件：用户最新 `ROM-1.41.zip`。
- 分支：`CHS_Mod`。
- 导出 HEAD：`608a85501b97174401367f544427aaac60639e54`。
- 导出状态：干净 HEAD，无未提交 Worktree Patch。
- 补丁路径：由于导出状态干净，增量补丁与 HEAD 全量补丁内容相同，是二选一的替代文件，不得叠加；ZIP 不包含 `.git` 对象。
- 正式起点：ROM-1.41；开发候选 ROM-1.42A 的图鉴评价功能后续与 ROM-1.42B 玩家资料功能合并清理，最终正式版本为 ROM-1.42。

## 问题与根因

用户录像显示，English 模式下 Oak's Lab 地图开场对白已显示英文，但紧接着 `predef DisplayDexRating` 的 Seen／Owned 数量标签及博士评价又显示中文。中文模式同一交互全程中文。

原因不是 LANGUAGE 位自行变化，而是地图脚本对白和图鉴评价走两个独立入口：地图对白生成器只改 `src/scripts/` 的可匹配 `text_far`；`DisplayDexRating` 在 `src/engine/events/pokedex_rating.asm` 中通过 `DexRatingsTable` 选择引擎文本 wrapper，文本定义位于 `src/text/pokedex_ratings.asm`。Hall of Fame 还会复用 `src/data/text/text_2.asm` 中的 Seen／Owned 标签。

## 接入内容

| 分类 | 英文标签数 | 来源 |
|---|---:|---|
| 完成度／Seen／Owned／博士评价标题 | 1 | `src/text/pokedex_ratings.asm` |
| 拥有数量评价阈值 | 16 | `src/text/pokedex_ratings.asm` |
| Hall of Fame Seen／Owned 与 Rating 标题 | 2 | `src/data/text/text_2.asm` |
| **合计** | **19** | 同代英文源 |

16 个阈值分支保留原顺序：0–9、10–19、20–29、30–39、40–49、50–59、60–69、70–79、80–89、90–99、100–109、110–119、120–129、130–139、140–149、150–151。

## 技术实现

- 所有 19 个 wrapper 复用现有 `text_bilingual`（`TX_BILINGUAL=$18`），由 `wOptions` bit 5 选择 CHS／English。
- 现有 `scripts/generate_bilingual_dialogue.py` 扩展一个专用 Pokedex 数据输出，不创建第二个重复生成器；构建前置生成 `buildRB/data/english_text/generated_pokedex_ratings.asm`。
- 英文副本固定放入 ROMX `$70`，不占 ROM0；数据估算 1,661 bytes。
- 英文 `#MON`／`#DEX` 字面量展开为 `POKéMON`／`POKéDEX`，不触发 CHS `PlacePOKe`；本轮 10 处扩展。
- Seen／Owned 动态数值仍通过原 `text_decimal` 读取：Oak's Lab 使用 `hDexRatingNumMonsSeen`／`hDexRatingNumMonsOwned`；Hall of Fame 使用 `wDexRatingNumMonsSeen`／`wDexRatingNumMonsOwned`。
- Hall of Fame 的 `.hallOfFame` 路径仍把所选 wrapper 复制到 `wDexRatingText`，直到 `TX_END`。`text_bilingual` wrapper 总长 8 bytes；缓冲区位于现有 180-byte WRAM union 内，不新增 WRAM／SRAM／存档字段。
- 不改变 `DisplayDexRating` 的统计、16 档阈值、声音、事件标志和剧情流程；不改变 YES／NO 选项菜单。

## 空间规划

随包 RPP 报告所附 ROM-1.41 MAP 将 ROMX `$70` 标记为完整空物理 Bank（16,384 bytes）；本轮英文数据估算 1,661 bytes；地图对白生成器上限同步收紧为 `$6F`，将 `$70` 明确保留给图鉴数据，防止未来文本扩容产生 Bank 重叠。17 个 `Pokédex Rating` wrapper 位于 Bank `$11`，增加 51 bytes（旧 MAP 空余 3,397，投影剩余 3,346）；2 个 Hall of Fame wrapper 位于 Bank `$1C`，增加 6 bytes（旧 MAP 空余 271，投影剩余 265）。ROM0 不新增运行代码，只有 9 字符测试版号字符串增加 1 byte（旧 MAP 空余 431，投影剩余 430）。这些都是 ROM-1.41 MAP 的静态投影，不是 ROM-1.42 链接结果；最终空间必须由维护者重新构建红／蓝并检查新 MAP。

## 静态检查

- ROM-1.42A 开发阶段单元测试 **17/17 PASS**；ROM-1.42 正式清理复测时，全套单元测试 **22/22 PASS**。`prepare_build.py` 成功生成 1,942 条地图引用／1,941 个地图英文标签，并生成 19 个图鉴英文标签。
- 19 个标签全部存在且无重复；生成器对缺失／重复标签、错误来源文件、未审查命令、未知 token 和超宽文本 fail-closed。
- 66 行可见文本通过 18 列宽度检查；另将 3 位动态计数与相邻文字合并计算，最大 18/18。
- 动态 `text_decimal` 命令保留。
- 16 档阈值与顺序通过静态核对。
- Hall of Fame 8-byte wrapper copy 与现有 WRAM union 通过静态核对。
- ROM-1.42 正式清理时，项目全部 17 个 `verify_*.py` 均已运行：5 PASS／12 FAIL；11 个旧版脚本被历史版号白名单拦截，`verify_qol116_static.py` 的 11 项功能结构断言通过，但旧正式版号／Options 对齐断言不识别 ROM-1.42。没有修改或弱化这些历史守卫。
- 单元测试、`prepare_build.py`、地图双语静态检查、Pokedex 专用静态检查及 `git diff --check` 结果以本轮实际运行记录为准。

## 用户验收计划

1. English 模式在 Oak's Lab 触发图鉴评价：开场、Seen 数字、Owned 数字、博士评价必须同一语言，不得中途跳回中文。
2. 中文模式重新触发：整段全中文，数字与 English 模式一致。
3. English／中文反复切换并重新进入评价，不死机、不丢数字、不残留上一语言文本。
4. 可到达 Hall of Fame 时，检查 Seen／Owned 标签和评价文字也跟随 LANGUAGE。
5. 保存、重启后重复检查。
6. 共用 YES／NO 继续显示中文；图鉴列表／条目、图鉴地点、战斗、名称表和其它 UI 仍未接入。

## 构建边界

本轮不运行 RGBDS／`rgblink`，不生成 ROM／MAP／SHA，不执行 Git Commit／Push。源码和静态检查通过不代表红／蓝 ROM 已成功链接，也不代表手机实测通过。
