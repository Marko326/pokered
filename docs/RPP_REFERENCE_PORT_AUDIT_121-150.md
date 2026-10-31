# RPP 参考分支移植台账：第 05 批（121～150）

> **CHS 唯一源码基线**：用户上传 `ROM-1.21.zip`，`CHS_Mod` 已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：`CHS_Mod_QOL-1.14_已提交版交接资料包_无嵌套.zip` → RPP `individual/121～150`；本段 **30 笔提交、30 份原始补丁均存在**。
> **范围**：逐条核对原始补丁实际改动与 CHS 源码、验收记录。所有状态是**移植评估结论**，不是新 ROM 测试结果。**本次纯文档，不改运行代码、RGBDS、音频引擎或游戏版本。**

## 本批依赖结构与关键审计发现

1. **#121～127：RPP 实时 Summary 及 Battle Party 快返回链**。前提是第 4 批 #104～120 的双页面/实时换宠、BG0 缓存、战斗快返回 helper。CHS 仍使用独立 `StatusScreen`/`StatusScreen2` 和自身 QOL-1.16/FLH-1.20 恢复路径；尽管用户可见症状相似，绝不能整套拷入。#124 的命令框已有 CHS 同目标修复，标为“部分实现”；#130 则可直接确认已实现。
2. **#128/#129：真实但可选的玩法差异**。卧室 PC 目前是 `script_players_pc`；参考改为取得图鉴后可用完整 PC。CHS 宝可梦笛野外无卡比兽时打印无效果，而参考增加唤醒队伍。这些是需要用户决定的新行为，不是默认修 Bug。
3. **#131/#132：有公共代码路径的显示修复**。CHS 已有离屏重绘，但未完全具备 RPP 同名 Buffer1 辅助函数；`AnimationWavyScreen` 仍缺参考的 `hSCX` 更新/结束清零，**#132 是本批最有依据的待核验 Bug**，建议在 Psychic/Psywave 动画后观察横向偏移，确认才修。
4. **#133：构建工具链不能混用**。CHS 已在 `src/Makefile` 支持 `RGBDS`/4 工具可配置，官方要求 RGBDS 1.0.4；参考补丁 `.rgbds-version=0.5.2` 不适用。
5. **#134～150：MoveDex / 扩展动画 / 属性配色的连续功能链**。多数不是原版 CHS 的故障：扩展动画、Dark/Fairy/18 属性颜色、X 道具旧动画回放、交易 Poof 受染色等问题依赖引入的新系统。**#142 的 crysaudio 音效代码明确不适用 CHS**；它的 Shadow Ball 新动画可作独立新功能规划，但不能直接带入 Crystal Audio。#143 是 RPP Bank `$1E` 优化，不是 ROM0 收益。
6. **判断约束**：没有对应 RPP 私有函数不等于同等效果不存在；反过来同名原版函数存在也不代表对应 RPP Bug 必然发生。仅将有直接源码证据的问题列“待核验”，未运行模拟器或建立实际复现。

## 本批状态统计

- **依赖暂缓：22**（#121、#122、#123、#125、#126、#127、#134、#135、#136、#137、#138、#139、#140、#141、#142、#143、#144、#145、#146、#148、#149、#150）。
- **已实现：2**（#130、#133）。
- **待核验：1**（#132）。
- **部分实现：2**（#124、#131）。
- **需评估：3**（#128、#129、#147）。

## 逐笔对照（RPP 原始编号与 Hash）

| 编号 / Commit | 参考提交原始标题 | 改动类型 | CHS 状态 | 源码证据（对应路径） | 建议 | 复杂度 / 判断置信度 |
|---|---|---|---|---|---|---|
| **#121** `9603ed02b6` | perf(summary): 缩短 Party 返回 START 加载时间 | 实时 Summary 返回 START 加速 | **依赖暂缓** | 参考新增 `Summary_RestoreStartMenuFromParty`、缓存 BG0 与 `wStatusScreenCommonTilesReady`，依赖 #104～120 的 Summary 切页/实时换宠链；CHS `src/engine/menus/start_sub_menus.asm` 已有 QOL-1.16 的 `RestoreStartMenuFromPartyWhite`，但没有同一缓存状态机。 | 不直接移植；如需更快返回，应测 CHS 当前 START→Party→Stats→返回耗时，再在汉化 DFS 和现有恢复路径上独立优化。 | 高 / 高 |
| **#122** `2b73220f2f` | perf(summary): 进一步缩短 Party 返回 START 加载时间 | 参考 Summary 返回时 LCD-off 图形拷贝 | **依赖暂缓** | 参考省去 LCD-on `CopyVideoData` 等待，新增 LCD-off 角色图形直写，属于 #121 缓存恢复实现的后续提速；CHS 没有该 Helper，已有 DMG/CGB START 字库、窗口提速保护。 | 不照搬 LCD-off Copy；需要先证明 CHS 存在多余 VBlank 等待，并核对双速、OAM、DFS 图块占用。 | 高 / 高 |
| **#123** `44e5cd2995` | fix(summary): 修复战斗 Summary 返回后横向震屏的框体异常 | 新增 Summary 缓存战斗 BG0 防震屏错框 | **依赖暂缓** | 参考修复 #121 缓存 BG0 只保存野外背景，战斗中横向震屏暴露错误框体；CHS 无该缓存 Helper，战斗 `core.asm` 走自己的 HUD/命令菜单恢复路径。 | 参考新快路径产生的缺陷；当前不作为 CHS 现有 Bug，除非选择重做相同缓存模式。 | 中 / 高 |
| **#124** `1261f7ece9` | fix(summary): 修复 Party 返回战斗菜单时命令框闪烁 | Battle Party 返回命令框显示 | **部分实现** | 参考由 `DisplayBattleMenu` 重绘改为直接回到 `.handleBattleMenuInput`，修命令框重建期间一帧闪；CHS `src/engine/battle/core.asm` 与 FLH-1.20 历史已有白屏下重建 HUD/命令框、等待 BGMap 传输的返回保护，但非同一快速返回入口。 | 相同用户可见问题已有 CHS 专门修复；不复制参考跳转。将“具体入口不同”保留，若出现新闪帧再复现。 | 中 / 高 |
| **#125** `c065cd9f6f` | perf(summary): 统一 Party/Summary 快速路径并优化 Battle Party 首次进入 | 统一 START/Battle 的实时 Summary 资源复用 | **依赖暂缓** | 参考新增 `battle_party_summary_fast_path.asm`，复用 #104/#105 信息页共享资源及 `wBattlePartySummaryEnemyPicDirty`；CHS 的 `StatusScreen`/`StatusScreen2` 仍是分开的流程。 | 高依赖的 UI/WRAM/战斗图片缓存重构，当前不移植；不能拿其性能数字替代 CHS 测试。 | 极高 / 高 |
| **#126** `4e831043d0` | fix(summary): 清除 Battle Party 快速返回时的父菜单箭头残影 | 快速 Battle Party 返回父箭头残影修复 | **依赖暂缓** | 只在 #125 缓存的 `wTileMapBackup2` 指定坐标清掉 `$EC` 父菜单箭头；CHS 未引入 #125 快速路径，已有自己的 Party 菜单绘制与 BG 传输。 | 不作为 CHS 现有残影；仅在未来复用类似快路径时检查父菜单光标。 | 中 / 高 |
| **#127** `8bb23a7348` | fix(summary): 恢复 Battle Party Summary 的上下切换宝可梦 | 恢复 Battle Summary 上下切换 | **依赖暂缓** | 参考修 #125 快速 Summary 入口未授予 `STATUS_SCREEN_MON_SWITCH_F` 权限、方向键未释放；CHS 当前没有 #104/#105 实时换宠状态机。 | 与 #125 一起评估；不要把“尚无新功能”误记成当前 Bug。 | 中 / 高 |
| **#128** `8272e87727` | fix(pc): 统一卧室电脑与宝可梦中心的完整 PC 功能 | 卧室 PC 与宝可梦中心 PC 权限统一 | **需评估** | 参考把红主角卧室 `TX_PLAYERS_PC` 改为独立 `TX_RED_BEDROOM_PC`，取得图鉴后开放完整 `ActivatePC`（Bill/Player/Oak/League），未取得前禁止使用；CHS `src/engine/events/hidden_objects/reds_room.asm` 仍为 `script_players_pc` 物品存储，与中心 `ActivatePC` 不同。 | 真实功能差异但会改变开场权限/游戏流程；用户决定是否需要。需审计中文脚本导入、文本宏、事件旗标与当前存档行为。 | 高 / 高 |
| **#129** `5526c7168f` | fix(pokeflute): 恢复战斗中的宝可梦笛音效并追踪敌方睡眠状态 | 宝可梦笛在野外唤醒队伍及战斗流程整理 | **需评估** | 参考把队伍唤醒抽成 `WakeSleepingPlayerPartyWithPokeflute`，野外无卡比兽时也唤醒队伍，并整理战斗笛声/睡眠标志；CHS `src/engine/items/item_effects.asm` 的 `.noSnorlaxToWakeUp` 仍直接打印“无效果”，`WakeUpEntireParty` 只在战斗路径使用。 | 新玩法差异，可选，需核实原版设计、中文“无效果”文字、卡比兽交互、战斗双方睡眠位；不能直接照搬参考 `callba` 参数 ABI。 | 中 / 高 |
| **#130** `19f3b60ab7` | fix(party): 修复队伍菜单返回时的窗口闪烁 | Party 操作菜单内部重绘闪烁 | **已实现** | 参考重绘 Party 时停用 AutoBG 传输；CHS `src/engine/menus/party_menu.asm:RedrawPartyMenu_` 已在入口 `xor a; ldh [hAutoBGTransferEnabled],a`，FLH-1.20 还区分内部重绘和首次揭屏。 | CHS 已有更完整的同目的修复，用户曾在 DMG/CGB 验收；无需重复移植。 | 低 / 高 |
| **#131** `3aa60942c8` | fix(ui): 优化菜单离屏重建并修复窗口中间帧闪烁 | 菜单离屏重建与多路径防闪 | **部分实现** | 参考扩展 `LoadScreenTilesFromBuffer1DisableBGTransfer` 并在战斗/Player PC/商店相关返回时延迟揭屏；CHS `src/home/tilemap.asm` 已有 `LoadScreenTilesFromBuffer2DisableBGTransfer`，START 及 FLH 走局部禁用/恢复，但尚未发现参考 `Buffer1Disable...` 统一助手。 | 原理部分覆盖；逐场景存在异常才考虑补齐，不能全局替换以免破坏 CHS Window/DFS 与现有 DOR/FLH 修复。 | 中 / 高 |
| **#132** `ef8a6e79fb` | fix(battle): 修复 PSYCHIC类 动画横向滚动寄存器残留 | Psychic/Psywave 波浪动画 SCX 残留 | **待核验** | 参考 `AnimationWavyScreen` 循环开始从当前 Offset 写 `hSCX` 并在结束同时清 `hSCX` 和 `hWY`；CHS `src/engine/battle/animations.asm:AnimationWavyScreen` 仍使用 `WavyScreen_SetSCX` 写硬件 `rSCX`，结束仅清 `hWY`，未见参考这两次 `hSCX` 操作。 | 此项与 CHS 现有代码确有相交风险。优先一次 Psychic/Psywave 后查看画面横向错位及后续画面；若复现，再做单点修复，独立验收 DMG/CGB。 | 中 / 高 |
| **#133** `841f964c80` | 改进跨环境构建配置 | 跨环境 RGBDS 工具链配置 | **已实现** | 参考加入 `RGBDS` 前缀和 `.rgbds-version=0.5.2`；CHS `src/Makefile` 已使用可配置 `RGBDS`/`RGBASM`/`RGBLINK`/`RGBFIX`/`RGBGFX`，根 `Makefile` 和 `MAINTAINER_BUILD.md` 也说明从 src 增量构建。CHS 要求官方 RGBDS **1.0.4**。 | 目标已覆盖；绝对不能移植 RPP 的 `0.5.2` 版本锁定或覆盖 CHS 构建封装。 | 低 / 高 |
| **#134** `3f450abe8e` | movedex_v1.2.7 | MoveDex 1.2.7 扩展招式动画表 | **依赖暂缓** | 参考加入 `LoadExtendedMoveAnimation`、真实 Move ID 到 recipe 映射、Bank/WRAM 缓存、回退至旧动画；CHS `src/data/moves/moves.asm` 和 `src/engine/battle/animations.asm` 没有对应 `ExtendedMoveAnimationTable`/`wMoveAnimScriptLoaded` 体系。 | 完整新引擎而非普通 Bug；改动招式数据库、WRAM、动画脚本/中文显示依赖，暂无新增招式需求时暂缓。 | 极高 / 高 |
| **#135** `5783b30774` | 修复妖精和恶系的射线显示以及部分Lowkick类技能显示问题 | 恶/妖精属性动画色表与扩展解释器边界 | **依赖暂缓** | 参考在已有 DARK/FAIRY + 新扩展动画解释器下补 TypeColorTable 和非法特效命令边界；CHS 一代战斗类型表中无 RPP 同一扩展属性机制。 | 仅在考虑 #134/扩展属性后成组评估；不能把 RPP 的错误命令跳表问题视为 CHS 当前必然存在。 | 高 / 高 |
| **#136** `d8cdb7e378` | 技能优化高音和妖精粉色射线1.2.9 | 高音与妖精射线定制动画 | **依赖暂缓** | 参考依赖 Fairy/Dark 新属性、扩展 recipe、Battle Palettes 与新特效指令；CHS 没有对应 MoveDex 动画表。 | 新增内容，若未来移植扩展招式再连同 #134/#135 检查。 | 高 / 高 |
| **#137** `b64e73a2c5` | 新技能动画龙之波动恶之波动 | 龙之波动、恶之波动等扩展 recipe | **依赖暂缓** | 参考新增大量 `ExtendedMoveAnimationTable` 条目及招式配方；CHS 仍使用一代招式与 legacy 动画表，缺这些扩展 Move ID。 | 依赖 #134 的真正招式数据库和动画解释器，不能按单个视觉修复套用。 | 高 / 高 |
| **#138** `8498c9f991` | 新技能冰牙，杂耍技能动画 | 冰牙、杂耍与其他第二批扩展动画 | **依赖暂缓** | 参考继续补全 B9–D7 段扩展招式动画配方；CHS 无对应连续扩展 Move ID。 | 必须在决定扩展战斗技能后统筹，单独移植没有对应调用目标。 | 高 / 高 |
| **#139** `8cb0e1da45` | 修复最后一批动画 | 扩展招式动画最终批次与表结构 | **依赖暂缓** | 参考重排扩展查表结构、补齐从 Metal Claw 到 Mind Blast 的 recipe；CHS 无 `LoadExtendedMoveAnimation` 路径。 | 需要完整状态/银行/动画脚本契约，不能孤立复制。 | 极高 / 高 |
| **#140** `7b171a76b8` | 修复使用提升能力道具时可能会重复播放动画的问题 | X 能力道具触发前一个扩展招式动画 | **依赖暂缓** | 参考在 `PrepareCurrentMoveAnimation` 识别 `XSTATITEM_ANIM` 时避免使用陈旧 `SelectedMove` 查扩展动画，另修扩展 `MoveSoundTable` 下标；CHS 也有 X 道具但没有同一扩展动画 staging 机制。 | 这是 #134 之后才出现的故障机制；CHS 当前不等同存在“重播 Moonblast”，如将来加扩展解释器须合并此护栏。 | 中 / 高 |
| **#141** `389d07af2b` | 修复使用道具可能会残留配色的问题 | X 能力道具残留参考动态属性配色 | **依赖暂缓** | 参考修 #134～140 新动态动画后，敌我 X 能力道具会继承上一招式属性颜色；CHS 虽有 `XSTATITEM_ANIM`，但没有 Fairy/Dark 动态属性动画调色流程。 | 不直接移植 RPP 的 wEnemyMoveType/wPlayerMoveType 临时覆盖；只有 CHS 独立出现道具 palette 异常才重新审查。 | 中 / 高 |
| **#142** `b3d4061b8b` | 影子球第一版 | 影子球新动画与 Crystal Audio 音效 | **依赖暂缓** | 参考新增 Shadow Ball projectile 和扩展动画命令，修改 `crysaudio/rbsfx.asm` 的 Gen2 声效引用；CHS 未采用 Crystal Audio，且无配套扩展动画 recipe。 | 不是 CHS 的现有音频 Bug；若未来单独想增加 Shadow Ball，必须先设计可兼容本项目音效引擎的替代方案，禁止直接混入 crysaudio。 | 极高 / 高 |
| **#143** `529469c18c` | 优化BANK1E空间 | Bank `$1E` 动画脚本节省 | **依赖暂缓** | 参考合并 Disable/Metronome 动画脚本并改战斗解释入口释放 Bank `$1E`；前提是 RPP 已加入 #134 等扩展动画，脚本内容/调用表与 CHS legacy `src/data/moves/animations.asm` 不同。 | 并非直接节省 ROM0；空间不足时需在 CHS MAP 确认该 Bank 压力及两个脚本是否语义一致后独立设计。 | 高 / 中 |
| **#144** `9d8de3205f` | 增加流星群特效 | 流星群新粒子特效 | **依赖暂缓** | 参考增加 `EXT_FRAMEBLOCK_OVERRIDE` 等新命令和 Draco Meteor 扩展 recipe；CHS 没有该扩展招式和解释器。 | 特效新功能、依赖 #134；若新招式无开发计划，跳过。 | 高 / 高 |
| **#145** `4a72da9405` | 增加NightSlash黑色双线切割 | Night Slash 黑色双线与 Dark 配色 | **依赖暂缓** | 参考依赖 DARK 动态着色、扩展帧/调色机制新增 Night Slash，CHS 没有对应扩展系统。 | 不作为 CHS 当前动画 Bug，整个属性配色系统选择后再评估。 | 高 / 高 |
| **#146** `c0826f31a9` | fix: 完善 Night Slash V2.1 动画评审修复 | Night Slash 后续非战斗交易动画色彩防护 | **依赖暂缓** | 参考修 Night Slash 调色时交易 Poof 误继承过期战斗属性状态；CHS 未采用 #145 动态配色，不能直接推断交易动画受影响。 | 典型新特性引发的回归修复，仅当移植 #145 时一并纳入。 | 中 / 高 |
| **#147** `6808f76b6f` | 新增战斗动画18属性动态配色系统 | 18 属性动态战斗动画配色系统 | **需评估** | 参考新增 18-type 动态 palette、临时 OBJ palette slot、选择式着色和状态复位；CHS CGB 有自身 battle palette，但不具备 RPP 的 18 属性扩展体系。 | 独立美术/战斗引擎大型功能，只有维护者明确要改扩展属性时才排期；必须分析 CGB/DMG、色表、WRAM、Bank 和汉化显示。 | 极高 / 高 |
| **#148** `f89756a0e4` | 重构切割类技能并加入属性配色与 X-Scissor 交叉斩 | 切割类技能共享动画和 X-Scissor | **依赖暂缓** | 参考在 #147 动态配色与 #134 recipe 下重构 Blade-family，包括 X-Scissor；CHS 不存在该连续扩展技能表。 | 依赖新动作解释器与扩展属性，不可单独把其修复视为原版 Cut 错误。 | 极高 / 高 |
| **#149** `49528aac41` | 重构咬击类技能并加入属性配色 | 咬击类技能共享动态着色 | **依赖暂缓** | 参考在 #147 上让旧 Bite 与新增元素 Fang 共享动画及 Dark palette；CHS 有 Bite，但无新动态 18-type 配色和新 Fang 配方。 | 并非 CHS Bite 现有 Bug；若未来移植扩展着色要回归捕捉/交易/招式。 | 高 / 高 |
| **#150** `1169a60561` | 爆裂拳V1 | 爆裂拳 V1 自定义动画素材 | **依赖暂缓** | 参考扩展 `PunchFrameBlock`、自定义拳头图像与 DynamicPunch recipe，还改 `gfx/punch_anim.png`；CHS 缺配套 MoveDex 动画 Bank/解释器。 | 新增动画内容，不直接替换 CHS 已验收战斗素材；如未来扩展招式，先评估图像格式、VRAM 和版权资产来源。 | 高 / 高 |

## 移植决策建议与最小验证

- **优先小范围复现，不直接写修复**：#132（PSYCHIC/PSYWAVE 波浪动画），具体检查战斗中后续对话、战斗结束返回地图时水平滚动；若没异常则保持原样。相关源码 `src/engine/battle/animations.asm:AnimationWavyScreen`。
- **无需重复移植**：#130 Party redraw 自动 BG 隐藏 + 首帧揭屏保护，CHS FLH-1.20 已覆盖。#133 工具链前缀配置 CHS 已有，且 RGBDS 版本不同，不应引入 RPP 构建规则。
- **操作/玩法差异（只在你选择后开发）**：#128 卧室 PC 在取得图鉴后开放全部 PC 功能；#129 无卡比兽时的宝可梦笛唤醒队伍。这两项都涉及原版行为、中文文本和存档/事件，暂不主动修改。
- **需测实际性能才能决定**：#121/#122/#131 的 START/Party/Summary 开关及返回速度。CHS QOL-1.13～1.16 已专门优化过同场景；不因参考更快就推翻已经测试的 DFS/地图恢复流程。
- **长期大型依赖链**：#134～150 包括全部扩展招式动画/18 属性动态调色与错误修复，暂缓移植。只有计划新增技能/属性才考虑完整设计与测试，尤其不能导入 Crystal Audio 的 `crysaudio/rbsfx.asm`。

## 依据与限制

- **原始参考补丁**：`individual/121～150`，30 份原始 `diff --git` 与其说明；完整 Hash/标题逐项列于上表。
- **CHS 源码**：`src/engine/menus/start_sub_menus.asm`、`src/engine/battle/core.asm`、`src/engine/menus/party_menu.asm`、`src/engine/battle/animations.asm`、`src/engine/items/item_effects.asm`、`src/engine/events/hidden_objects/reds_room.asm`、`src/engine/menus/pc.asm`、`src/home/tilemap.asm`、`src/data/moves/moves.asm`、`src/data/moves/animations.asm`、`src/Makefile`，以及 `docs/CHS_ACCEPTANCE_HISTORY.md` 中 QOL-1.13～1.16、DOR-1.19、FLH-1.20 记录。
- **没有执行**：参考提交实机逐笔复放、CHS 运行复现、红蓝 ROM 重新编译、MAP 比较；无法断言所有“待核验”均为实际故障。
- **没有修改**：`src/`、`scripts/`、WRAM/SRAM、翻译表、Makefile、`GameVersionText` 或任何实机可运行内容。下一步只有用户选定功能才另做测试补丁。

**下一批：151～180，仍按 30 笔逐项评估。**
