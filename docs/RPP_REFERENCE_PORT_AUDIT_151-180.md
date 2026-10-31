# RPP 参考分支移植台账：第 06 批（151～180）

> **CHS 基线**：用户提供的最新正式 `ROM-1.21.zip`，`CHS_Mod` 已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`；此批不是对真实用户工作区的写入。
> **参考**：第 2 个交接包 `CHS_Mod_QOL-1.14_已提交版交接资料包_无嵌套.zip` → RPP `individual/151～180` 共 30 份原始提交补丁（无缺号）。
> **审查口径**：对照原始 diff、CHS 源码和现有台账；以下是静态移植评估，**不代表编译或游戏运行验证**。不因参考分支自身扩展系统产生的缺陷而断言 CHS 有相同 Bug。**本批只增加项目文档，不修改 ASM 或版本号**。

## 本批重点结论与依赖关系

1. **#151～159：扩展招式动画链**。前置是参考 #134 的 MoveDex/`extended_move_animations.asm`，包括十拳、Meteor Mash、Slash 新动画、三爪、空气砍及其 ROM0 优化。CHS 有原版招式动画但**没有这些新扩展配方和 HOME 跳板**，整体暂缓；不要把 RPP 新动画错误标记成 CHS 旧版 Bug。
2. **#161～168：战斗 Bank `$0F` 空间优化和规则扩展**。CHS 红 MAP Bank `$0F` 约 615 B 可用，确有空间压力；但这些补丁联动伤害公式、AI、联机、特效、蓄力和 TypeEffects 结构。#168 的 Bone Club 对 Flying 变普通伤害属于**改变玩法规则**，不能默认作为 Bug 修复。
3. **#169/#170：Bank `$03` 空间与野外遭遇稀疏表**。CHS 红 MAP Bank `$03` 约 648 B 可用；仍保留线性 `WildDataPointers`，但若改为稀疏表必须同时检查野外遭遇、地图索引及图鉴定位，不能只看节省数据字节。
4. **#171～173：与既有 CHS ROM0 优化直接相关**。#172 列表/数量菜单已在 CHS 迁出 HOME；#171 仅部分同目的，CHS 已有 `High Home`/`Home`，更细分 Section 不应无 MAP 就做；#173 十进制 PrintNumber 输入读取在 HOME 已有，但 BCD 依旧于 ROMX 解引用 `[de]`，须专项审核 caller-bank 输入指针风险。
5. **#177：已确认源码与素材长度不一致，建议优先独立修复**。CHS 红蓝第二老虎机素材尺寸都是 32×48＝24 tiles＝`$180 B`；加载程序的两条路径仍按 `$1c`＝28 tiles 复制，**每次超出 4 tiles＝64 B**。这是一项实在的静态证据，不必为此移植 RPP 整套 Bank `$1E` 动画压缩。是否造成用户可见问题仍未复现。
6. **#180：存在同类 NPC 图块边界风险，须先核实资源**。RPP 识别了 16 种仅站立图块精灵，并按 metadata 复用；CHS 仍有 walking 源地址加 `$c0` 的通用路径，但不能只靠源码就判定 16 种在 CHS 均越界。建议程序化核实 sprite pointer 长度与图像大小，再做最小修复。
7. **#174/#175/#176/#178：依赖差异**。Snowy 调色、分类背包、参考双页 Options、两字节 subanimation 均依赖 CHS 没有的参考新增体系，直接移植会引入不必要的重构。

## 状态汇总

- **依赖暂缓：11**（#151、#152、#153、#154、#155、#156、#157、#158、#159、#162、#178）。
- **已实现：1**（#172）。
- **当前不适用：4**（#160、#163、#174、#175）。
- **待核验：2**（#177、#180）。
- **部分实现：3**（#171、#173、#176）。
- **需评估：9**（#161、#164、#165、#166、#167、#168、#169、#170、#179）。

## 逐笔审查（原始参考 Hash 与 CHS 证据）

| 编号 / Hash | 参考提交原始标题 | 内容 | CHS 状态 | 实际代码/历史依据 | 移植建议 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#151** `b73e37e9e3` | 十拳大补汤V1 | 扩展拳击连招动画 V1 | **依赖暂缓** | 参考改 `data/extended_move_animations.asm`、`gfx/punch_anim.png` 和扩展动画常量；CHS 无同一 MoveDex/extended animation interpreter。 | 参考新增视觉效果，先不引入；不要把它当成 CHS 原有拳系动画 Bug。 | 高 / 高 |
| **#152** `124f7cb15e` | 十拳大补汤V2 | 扩展拳击连招动画 V2 | **依赖暂缓** | 基于 #151 调整拳击效果的命令与动作序列；CHS 不存在该扩展 recipe。 | 与 #151 绑定；未计划移植 MoveDex 时不单独实施。 | 高 / 高 |
| **#153** `3af2a2b596` | 修复彗星拳举起时变成岩石的缺陷 | Meteor Mash 抬手星形误显示岩石 | **依赖暂缓** | 参考修 `Meteor Mash` 自定义扩展动画素材和 `gfx/meteor_mash_lift_star.png`；CHS 原版招式表无该扩展动画路径。 | 参考扩展功能引起的显示错误，不作为 CHS 当前已存在的 Bug；若计划新增技能再评估。 | 中 / 高 |
| **#154** `9948f11c9b` | 彗星拳增加举起星星后的延迟 | Meteor Mash 抬星后节奏延迟 | **依赖暂缓** | 仅调整参考扩展动画脚本等待帧；CHS 不使用对应扩展脚本。 | 纯观感调整，依赖 #153 和扩展动画引擎。 | 低 / 高 |
| **#155** `d776b31936` | 修复双斩后头部形状缺失 | 双斩扩展动画头部图块残缺 | **依赖暂缓** | 参考修改 `data/animations.asm`、`data/extended_move_animations.asm` 的扩展双斩资源指针；CHS 无其扩展 recipe。 | 不要将参考自定义动画的素材缺陷认定为 CHS 现有招式图形缺陷。 | 中 / 高 |
| **#156** `9edad1119e` | 增加SLASH双斩动画 | Slash 双斩的新配方 | **依赖暂缓** | 参考追加 `SLASH` 自定义扩展动画；CHS 有原版 SLASH 招式/原版动画，但没有参考的扩展配方。 | 原版 Slash 已有不等于参考新视觉已实现；属可选动画重设计，暂缓。 | 高 / 高 |
| **#157** `ecbd361c24` | 三爪动画更新 | 三爪动画横震与回缩 | **依赖暂缓** | 参考只改 `extended_move_animations.asm` 的爪击序列；CHS 依旧运行原版动画表。 | 需要新扩展动画系统，暂不移植。 | 中 / 高 |
| **#158** `62431d0c03` | 新增空气砍和空气切割动画 | 空气砍、空气切割新动画 | **依赖暂缓** | 参考增加扩展 Gust/Cut 组合配方；CHS 未增加对应新招式及解释器。 | 非当前 CHS Bug；计划扩展招式时和 #134～158 一起评估。 | 高 / 高 |
| **#159** `7a8113a2b3` | fix(rom0): 将 movedex v1.2.7 起新增的 HOME 动画代码迁出 ROM0 | MoveDex 新增 HOME 动画代码外迁 | **依赖暂缓** | 参考将 #134 之后新增的 `PrepareCurrentMoveAnimation`、`PlayCurrentMoveAnimation...` 搬到 Bank `$3A`；CHS 无这些新 HOME 符号。 | 它释放的是参考扩展功能引入的 ROM0 占用；CHS 不可照搬，现有 ROM0 整理独立维护。 | 中 / 高 |
| **#160** `cc4f9bb250` | fix(rom0): 将 Bill's PC 辅助代码迁出 HOME 并精简动画跨 Bank 跳板 | Bill’s PC 专属新 Helper 外迁 | **当前不适用** | 参考移动 `PrepareBillsPCActionMenu`、`RestoreBillsPCActionMenuAndCancel`、`RestoreBillsPCActionMenuAfterStats`；CHS `src/engine/menus/pc.asm` 与 `src/engine/menus/bills_pc.asm` 未发现这些新增 HOME Helper。 | 只迁参考分支自己新增的例程，CHS 没有这组可搬代码；不列成待修 Bug。 | 低 / 高 |
| **#161** `9b75a828b5` | refactor(battle): 合并重复战斗计算逻辑并释放 Bank F 空间 | 战斗计算去重复并释放 Bank `$0F` | **需评估** | 参考合并 Super Fang、固定伤害与麻痹/烧伤、能力等级加减计算；CHS `engine/battle/core.asm` 仍区分敌我 Psywave/固定伤害、`effects.asm` 有原函数。 | Bank `$0F` 当前红 MAP 仅约 615 B 空闲，可列空间候选，但战斗公式有敌我差异；不得把参考合并方法直接等价照搬。 | 极高 / 高 |
| **#162** `6e0b1fe135` | refactor(battle): 迁移类型克制逻辑并精简 Bank F 战斗判断 | 类型克制与 STAB 逻辑迁出 Bank `$0F` | **依赖暂缓** | 参考新增 `type_effectiveness.asm`、重构 `AdjustDamageForMoveType` / AI，并伴随 Hex/Electro Ball 处理；CHS 的原版类型克制仍在 `src/engine/battle/core.asm`，无参考新增招式分支。 | 有其他 Bank 空间潜在收益但牵涉伤害、STAB、AI 和独立招式；只能依据当前 CHS 独立重构，暂缓直接移植。 | 极高 / 高 |
| **#163** `5bacbc8c9c` | refactor(battle): 迁移战斗 HUD helper 并合并能力提升副作用逻辑 | RPP 扩展威力、性别闪光 HUD Helper | **当前不适用** | 参考移动 Hex/Electro Ball 可变威力与敌我性别、闪光标志 HUD 到 Bank `$34`；CHS 当前未实现对应扩展属性/性别与闪光 HUD Helper。 | RPP 扩展系统资源迁移不适用于现有 CHS，若未来新增这些系统再整体评估。 | 高 / 高 |
| **#164** `296e0b9875` | refactor(battle): 清理 Link Battle 死代码并合并状态副效果概率逻辑 | Link Battle 代码去重与异常状态副作用 | **需评估** | 参考删除联机换怪无法到达的 Metronome/Mirror Move 分支，合并 Burn/Freeze/Paralyze 机率；CHS `engine/battle/core.asm`、`effects.asm` 仍有联机随机数和状态副效果路径。 | 涉及真实联机与状态概率，优先做可达性静态证明和概率对照；空间优化不应无证据删除 CHS Link Battle 路径。 | 高 / 中 |
| **#165** `3dc5f9d0c2` | refactor(battle): 迁移大型 Move Effect 并修复 Disable/Mimic 随机槽读取 | Disable/Mimic/Teleport 效果迁移并修跨 Bank 随机值 | **需评估** | RPP 将三个效果从 Bank `$0F` 搬 Bank `$34`，再用 `BattleRandomFar` 保证返回随机值；CHS `src/engine/battle/effects.asm` 仍本地实现 `MimicEffect`、`DisableEffect`、`SwitchAndTeleportEffect` 且调用 `BattleRandom`。 | CHS 无新跨 Bank 随机调用便没有该“迁移后的”随机值 Bug；仅在 Bank `$0F` 压力下先测技能再设计 ABI。 | 极高 / 高 |
| **#166** `0fa6ac95ba` | refactor(battle): 迁移睡眠与蓄力招式效果至 Bank $34 | 睡眠/蓄力招式效果迁 Bank `$34` | **需评估** | 参考把 SleepEffect / ChargeEffect 迁到 `$34`，涉及 `MoveHitTest` 调用和目标状态指针；CHS `src/engine/battle/effects.asm` 保持原相关效果结构。 | 对 ROM0 无直接收益，Bank `$0F` 紧张时可独立评估；必须保留睡眠计数、蓄力两回合与传参行为。 | 高 / 高 |
| **#167** `670de53cfb` | refactor(battle): 重构 TypeEffects 压缩表并提升可读性 | 类型效果压缩表的语义宏 | **需评估** | 参考用 `type_effect_group` 和克制宏重写紧凑 TypeEffects，配合 #162 的新解析器；CHS `src/data/types/type_matchups.asm` 是三元组 `db attacker, defender, multiplier` 与 `-1` 结束。 | 不是可直接套用的省空间补丁，需同时改解析与 AI；只有明确需求才做行为等价/表覆盖测试。 | 高 / 高 |
| **#168** `10537a2933` | feat(battle): 添加技能专属属性克制覆盖机制 | 招式专属类型相性覆盖 | **需评估** | 参考新增 MoveTypeEffectOverrides，允许指定招式忽略常规属性免疫，并调整 Bone Club 对 Flying 判定；CHS `src/data/types/type_matchups.asm` 仍 `GROUND, FLYING, NO_EFFECT`，`BONE_CLUB` 存在。 | 这是改变战斗规则的新功能，并非已知 CHS Bug；由用户决定，默认不修改一代原规则。 | 高 / 高 |
| **#169** `705e487485` | refactor(bank03): 重排可重定位 helper 以释放固定 Bank 3 空间 | 固定 Bank `$03` Helper 重排 | **需评估** | 参考将 DrawBadges、BCD Math、NPC Pathfinding 等由固定 Bank `$03` 改浮动 section；CHS `src/main.asm` 有 Bank3 固定 section 且红 MAP 显示该 Bank 仅约 648 B 余量。 | 有实在的 Bank `$03` 维护价值但不是 ROM0 清理；未来需核对跨 Bank 调用、WRAM 和汉化菜单后单独处理。 | 中 / 高 |
| **#170** `76e3240bd0` | refactor(bank03): 压缩普通野外遭遇地图索引表 | 稀疏野外遭遇地图索引 | **需评估** | 参考将 `WildDataPointers` 线性表改 `wild_data` 稀疏索引；CHS 仍使用 `src/data/wild/grass_water.asm:WildDataPointers` 与 `src/engine/overworld/wild_mons.asm` 线性查表。 | 是真实结构差异，但会影响遭遇与图鉴地点查询；需要红蓝遭遇表一致性与保存读档回归，不作为 ROM0 直接收益。 | 高 / 高 |
| **#171** `f9577a3a98` | refactor(rom0): 拆分 HOME 辅助函数 section 并改善 ROM0 连续空间利用 | ROM0 HOME Section 布局拆分 | **部分实现** | 参考把 DisableLCD/EnableLCD、CopyData/FarCopyData 等拆独立 ROM0 section 以填充碎片；CHS `src/home.asm` 已有单独 `High Home` 和 `Home`，但未细分相同 helpers；现红 MAP ROM0 总余量 1088 B。 | 有同目标布局基础，但不等于参考分拆全部完成；需新 MAP 分析连续空区及 RST 向量，空间没有压力时先不动。 | 中 / 高 |
| **#172** `e36e1af9e7` | refactor(rom0): 将列表菜单辅助逻辑迁出 HOME | 列表数量菜单辅助逻辑迁出 HOME | **已实现** | 参考移动 `DisplayChooseQuantityMenu` 与 `PrintListMenuEntries` 主体并保留 ROM0 入口；CHS `src/engine/menus/quantity_menu_helpers.asm`、`list_menu_helpers.asm` 已有 ROMX 实现，`src/home/list_menu.asm` 有跳板。 | 已有同目标迁移，不重复移植，且不使用参考 RPP Bank 分配。 | 低 / 高 |
| **#173** `52e1d7e672` | fix(rom0): 修复 PrintNumber 跨 Bank 输入指针并保留安全迁移结构 | 跨 Bank 数字打印的输入指针安全 | **部分实现** | 参考将 `PrintBCDNumber` 撤回 HOME，并在 `PrintNumber` 切 Bank 前读完 DE 指向的数据；CHS `src/home/print_num.asm` 已在切 Bank 前读入 `hNumToPrint`，但 `src/home/print_bcd.asm` 的 BCD 入口仍跨 Bank 到 `$2D`，主体直接 `[de]`。 | 十进制路径已防护；BCD 需检查是否有 ROMX caller-bank 指针，不能因商店 RAM 金额测试正常就认定全部安全，也不必在无证据下立即回退迁移。 | 高 / 高 |
| **#174** `6c10fdacd3` | refactor(snowy): 用稀疏差分压缩雪景 tileset 调色板分配 | Snowy 雪景调色板稀疏压缩 | **当前不适用** | 参考改 `data/snowy_runtime.asm` 与四类雪景调色表；CHS 没有对应 `snowy_runtime.asm` / Snowy 地图调色运行模块。 | 参考专属天气美术功能，不移植，不算 CHS 未修的 Bug。 | 低 / 高 |
| **#175** `065954df25` | refactor(bag): 合并 START Bag 与 Battle Bag 的公共菜单逻辑 | 双口袋 START Bag / Battle Bag 共用例程 | **当前不适用** | 参考合并 `engine/menu/bag_pockets.asm` 内两个 pocket 光标、计数和描述刷新；CHS 没有 RPP 新分类背包 / `bag_pockets.asm`，仍运行原一代袋子菜单。 | #078～082 新系统后续去重，CHS 当前没有可合并的相同 pocket 两套代码。 | 低 / 高 |
| **#176** `d830a8a55a` | refactor(options): 合并 Options 菜单重复光标与页面绘制逻辑 | Options 菜单光标与绘制共用 | **部分实现** | 参考合并新 Options Page1/Page2 的 `storeOptionMenuCursorX`、Battle Effects/Music 二值切换；CHS `src/engine/menus/main_menu.asm:DisplayOptionMenu` 已有 Options，但无参考双页、Music 开关系统。 | 现有 Options 功能部分对应，参考优化依赖新两页/音频设置；只有实测 CHS 重复代码或布局问题才另做小整理。 | 中 / 高 |
| **#177** `ab612092bc` | refactor(animation): 压缩 Battle Animation Bank 并修复老虎机图块跨 section 越界读取 | 老虎机第二组素材固定复制长度越界 | **待核验** | 参考将 `SlotMachineTiles2` 移出 Bank `$1E` 并修两处复制 `$1c tiles` 为真实 `$18 tiles`；CHS `src/engine/slots/slot_machine.asm` 两处仍复制 `$1c`，`src/gfx/slots/red_slots_2.png` 与 `blue_slots_2.png` 均是 32×48＝24 图块（384 B），已定义 `SlotMachineTiles2End`。 | **已确认源码长度不匹配**（两次各多读 4 图块／64 B），运行可见问题尚未证实；推荐独立低风险修复，改为 `End - Start` 并做红蓝老虎机测试；动画 Bank 大重构另评估。 | 低至中 / 高 |
| **#178** `6fed3387ce` | refactor(animation): 重构 subanimation 紧凑编码并恢复可维护的语义化数据定义 | subanimation 两字节编码和维护宏 | **依赖暂缓** | 参考依赖已在 RPP 先压缩成两字节的 subanimation entry，再加 `subentry` 语义宏；CHS 仍使用 `src/data/moves/animations.asm` 的旧格式和独立 `engine/battle/animations.asm`。 | 改变大型数据格式、FrameBlock 与解释器索引，需整链复核；只有对应 Bank 空间严重不足时才评估。 | 极高 / 高 |
| **#179** `acbc0c5a66` | refactor(animation): 迁移 Battle Animation 图块资源并显式化跨 Bank 维护约束 | 战斗动画图块资源跨 Bank 迁移 | **需评估** | 参考将 Battle Animation 图块从 Bank `$1E` 搬到其他 Bank 并保持新的 subanimation 约束；CHS `src/engine/battle/animations.asm` 仍含 `MoveAnimationTiles`、老虎机图块并以 BANK(symbol) 取资源。 | 可以独立评估搬原始资源，但必须先从 CHS MAP 证实 Bank `$1E` 压力、确认 VRAM 与加载时序；不迁参考已压缩格式。 | 高 / 中 |
| **#180** `be5a2f1851` | fix(overworld): 修复 standing-only NPC walking 图块跨资源越界读取 | 仅站立 NPC walking 图块跨资源读取 | **待核验** | 参考对 16 种仅含 `$C0` 站立块 NPC 增加 byte-count bit0 元数据，行走加载复用站立块；CHS `src/engine/overworld/map_sprites.asm` 仍在 walking 第二次拷贝路径无条件把源 `de` 加 `$c0`，`src/data/sprites/sprites.asm` 与站立-only 资源需继续逐项对表。 | **存在同类源代码风险**，但尚未逐项确认 CHS 资源边界或实际乱码；先程序化对 16 类精灵数据及指针长度，再独立修复，检验护士/妈妈/商店角色与动态 NPC/进出房门。 | 中 / 中 |

## 后续建议（先小修，后评估大重构）

- **P1 候选：#177（老虎机图块复制）**。独立改为使用已存在的 `SlotMachineTiles2End - SlotMachineTiles2`，在红、蓝版核查 BG 与转轮、中奖符号；该建议是未来编码任务，**本批没有进行修复**。
- **P1 待专项数据审查：#180（站立-only NPC）**。按 CHS 自身 SpriteSheetPointerTable 和 PNG/2bpp 资源逐项比对，而不是照抄 RPP 的 16 个名单；确定真正越界才制作最小修复。
- **P2 预防性 Bank 审计：#173（BCD 指针）**。遍历 `PrintBCDNumber` 调用方，检查 DE 是否可能为 ROMX 指针；普通十进制前端在 Bank 切换之前读取完成，是已有的保护。保留用户此前商店测试通过的事实，但不把它等价成全部输入已验证。
- **有条件的优化：#169/#170 的 Bank `$03`、#161～166 的 Bank `$0F`、#171 的 ROM0 布局**。先看新 MAP 和真实持续需求，明确优化目标/ROM Bank/可回归的关键场景，再独立设计。尤其禁止直接复制 RPP 的 `jpab`、新类型表、性别/闪光 HUD 和 Crystal Audio 结构。
- **功能规则须维护者决定：#168**。Bone Club 对 Flying 的属性覆写属于玩法扩展，不是自动 Bug 修复。
- **暂不进行：#151～159、#174～176、#178** 的参考专有扩展动画、雪景、分类背包和两页 Options 重构。#179 只有在动画资源 Bank 压力下才另立专题。

## 来源与边界

- RPP 原始补丁：`individual/151～180` 共 30 份，标题和 Hash 原样列于逐笔表。
- CHS 源码：`src/home.asm`、`src/home/print_num.asm`、`src/home/print_bcd.asm`、`src/engine/menus/print_bcd_helpers.asm`、`src/engine/menus/quantity_menu_helpers.asm`、`src/engine/menus/list_menu_helpers.asm`、`src/engine/slots/slot_machine.asm`、`src/engine/overworld/map_sprites.asm`、`src/data/sprites/sprites.asm`、`src/data/wild/grass_water.asm`、`src/data/types/type_matchups.asm`、`src/engine/battle/core.asm`、`src/engine/battle/effects.asm`、`src/engine/battle/animations.asm`、`src/main.asm` 与随包红版 `buildRB/pokered.map`。
- PNG 尺寸由 CHS `src/gfx/slots/red_slots_2.png` 和 `blue_slots_2.png` 检查得到；24 tiles × 16 bytes = 384 bytes。
- 本轮**未做**：任何新 ROM 编译、实机或模拟器功能验证、正式版本修改、Git 提交/Push。下一批 `181～210` 继续分批，不对其他历史提交提前下结论。
