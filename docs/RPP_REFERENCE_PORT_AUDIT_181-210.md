# RPP 参考分支移植台账：第 07 批（181～210）

> **CHS 基线**：最新正式 `ROM-1.21.zip` 的 `CHS_Mod` 已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：`CHS_Mod_QOL-1.14_已提交版交接资料包_无嵌套.zip` 内的 RPP `individual/181～210` 原始提交补丁，共 30 笔、无缺号。
> **审查范围**：逐笔结合参考原始提交说明/改动路径、CHS 源码和前六批审核结论作静态评估。**未进行本轮新游戏运行测试，不能将“源码可能存在”写成已复现 Bug。** 本轮只更新文档，不修改游戏 ASM、数据、版本号或存档。

## 本批核心发现

1. **#195：优先检查 HM 道具存入 Player’s PC**。CHS `PlayerPCDeposit` 在列表选择后调用 `IsKeyItem` 以控制“数量”询问，再执行实际存入；虽然 `IsKeyItem_` 把 HM 视为 Key Item，当前流程**没有在入库前拒绝 HM**。这是与 RPP 修复不同的真实代码路径，推荐用备份存档验证 HM01～05 的可存取行为，再独立设计最小修复。
2. **#201～202：CHS 已实现**。CHS `QOL-1.17` 的 `damage_hp_animation.asm` 明确包含按有效伤害比例分档和特殊 tile-only VBlank HUD 刷新，参考的两笔不应重复移植。
3. **#207：值得复现的战斗规则 Bug**。CHS 仍是原始敌我 ThrashingAbout/AttackMissed 路径，未发现 RPP 失败后早解锁的统一处理。建议用低概率/免疫对照确认锁招与混乱行为，未复现前不能声称已有故障。
4. **#181～184、#190、#194、#203：参考新增系统专属**。MoveDex、英文 packed names、分类 TM/HM Pocket、扩展动画 wrapper 与压缩名称价格问题不属于 CHS 当前既有系统；尤其 #203 是 RPP #183 加入名称压缩后引起的 HRAM 覆盖，CHS 当前没有同一触发路径。
5. **#186～189、#191：真正可选的 UI/QoL**。图鉴第三页/进化种族值与会话内图鉴光标、START Party 独立光标是新增功能，不是修 Bug。前者依赖多页状态机和汉化排版，后者相对独立。
6. **#197～200：过场/返回性能与节奏**。CHS 已有 START、Party 部分快速恢复，但没有照搬参考的全套 Bag→Party 返回优化；`#199` 的 3px/帧被 `#200` 的约 1 秒方案替代。若用户选做，应评估 #200 的最终行为，避免叠加两个速度版本。
7. **#204～209：战斗规则链**。多段结果提示、Mimic 立即行动、Mirror Move 记忆/增伤均改变原行为，#206 是 #205 的安全补丁，#209 依赖 #208，暂不当作普通修 Bug 自动移植。
8. **#210：仅部分同目标**。CHS 已能按 Red/Blue 分别编译并有对应资源，参考把 Red++/Blue++ 身份、Hard 模式、配色等重构成另一套版本设计，不能覆盖 CHS。

## 状态统计

- **依赖暂缓：7**（#181、#187、#188、#192、#193、#206、#209）。
- **已实现：2**（#201、#202）。
- **当前不适用：7**（#182、#184、#185、#190、#194、#198、#203）。
- **待核验 Bug：2**（#195、#207）。
- **部分实现：2**（#197、#210）。
- **需评估：10**（#183、#186、#189、#191、#196、#199、#200、#204、#205、#208）。

## 181～210 原始提交逐笔对照

| 编号 / Hash | RPP 原始标题 | 改动主题 | CHS 状态 | CHS 证据 / 差异 | 处理建议 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#181** `60d5bd106b` | feat(movedex): 透明压缩 MoveDex 技能说明文本并保持源码可读性 | MoveDex 专用 token 压缩 | **依赖暂缓** | RPP 对 data/movedex_descriptions.asm 使用 64-token 递归压缩；CHS 没有 MoveDex 描述表或对应显示器，且使用中文 DFS。 | 这是参考新增系统的数据优化，当前不移植；中文文本压缩需单独设计和字形/编码核验。 | 高 / 高 |
| **#182** `a7681658de` | fix(movedex): 修复右侧菜单返回时跨 Bank DrawTileLine 调用导致的白屏 | MoveDex 侧菜单跨 Bank 调用白屏 | **当前不适用** | RPP 的右侧 MoveDex 菜单从 Bank $35 直接调用 Bank $10 DrawTileLine；CHS 没有 engine/menu/movedex.asm。 | 参考新功能引起的白屏修复，CHS 目前不存在同一调用链；不列入 CHS Bug。 | 低 / 高 |
| **#183** `7370737b21` | refactor(names): 共享压缩 Move、Item 与 Trainer 名称并保持 GetName ABI | 共享压缩 Move/Item/Trainer 名称 | **需评估** | RPP 在 named CHARMAP 与 DecodePackedName 下把三类英文名称打包；CHS 名称仍通过 home/names.asm、src/data/items/names.asm、src/data/moves/names.asm、src/data/trainers/names.asm 与汉化文本体系处理。 | 潜在其他 Bank 空间优化，但对中文 DFS/旧存档名/名字缓冲区与返回 ABI 有高风险，暂无必要不做。 | 极高 / 高 |
| **#184** `27b8e3717a` | fix(battle): 修复 Minimize 动画预处理破坏 DE 导致的死机 | Minimize 扩展动画预处理保存 DE | **当前不适用** | RPP 修其新增的 PrepareCurrentMoveAnimation wrapper 修改 DE 导致 Minimize 依赖寄存器错误；CHS 无该 MoveDex 扩展动画预处理路径。 | 不能把 RPP 新扩展动画的死机直接判为 CHS Bug；保留正常 Minimize 动画独立观察。 | 低 / 高 |
| **#185** `bd05600986` | fix(pokedex): 退出图鉴时重绘 overworld BG0 | 图鉴双 BG 页退出重绘 | **当前不适用** | 参考图鉴使用 vBGMap0 隐藏页，退出时 ReloadMapData 无法重建可见 BG ring；CHS src/engine/menus/pokedex.asm 仍为原式图鉴流程并在退出 CoverFullScreenWithWhiteDelay3 后 jp ReloadMapData。 | 参考双 BG 翻页机制引入的问题不宜套修；若 CHS 实际出现图鉴回地图残留，再按现有显示系统定位。 | 中 / 高 |
| **#186** `c709652080` | feat(pokedex): 新增第三页种族值信息 | 图鉴第三页种族值 | **需评估** | 参考为已抓宝可梦增加 TYPE/HP/ATK/DEF/SPD/SPC/TOTAL 信息页；CHS 当前图鉴没有这套新增第三页。 | 可选新功能；需先设计中文布局、数据来源、翻页控制与 ROM Bank 预算。 | 高 / 高 |
| **#187** `4b4ae23ca6` | refactor(pokedex): 重构详情页分类与子页导航 | 图鉴详情分类和子页导航 | **依赖暂缓** | 参考在 #186 的第三页基础上 LEFT/RIGHT 切 Details/Base Stats、A 切子页；CHS 没有相关页面状态机。 | 依赖 #186；不单独移植。 | 高 / 高 |
| **#188** `9719be906e` | feat(pokedex): 新增进化种族值变化子页 | 进化种族值差异页 | **依赖暂缓** | 参考依赖 #186～187，新增 data/pokedex_pre_evos.asm 与第二 Base Stats 子页；CHS 没有相同反向进化索引。 | 对中文页面、进化分支、跨 Bank 查表需专项设计，暂缓。 | 极高 / 高 |
| **#189** `a4a659d08d` | feat(pokedex): 记住会话内图鉴浏览位置 | 会话内图鉴列表位置记忆 | **需评估** | RPP 新增 wPokedexSavedSelection，会话内保存绝对图鉴编号；CHS ShowPokedexMenu 开始将 wCurrentMenuItem、wListScrollOffset 清零，退出还原外层共享滚动状态。 | 确有功能差异；可作为独立 QoL 设计，但需避开 CHS WRAM 与原 START/图鉴状态。 | 中 / 高 |
| **#190** `18eb692948` | feat(movedex): 记住会话内技能图鉴浏览位置 | 会话内 MoveDex 光标记忆 | **当前不适用** | 参考在独立 MoveDex 上保存 move ID；CHS 未实现 MoveDex 页面。 | 仅当引入 MoveDex 才连同 #190 一起考虑。 | 低 / 高 |
| **#191** `5bb96267d8` | feat(party): 独立记忆 START 队伍菜单光标 | START 队伍菜单独立光标记忆 | **需评估** | CHS start_sub_menus.asm 仍使用 wPartyAndBillsPCSavedMenuItem 共用 Party/Bill PC 状态；参考新增与战斗/PC 隔离的 START 专属会话光标。 | 独立小型 QoL 候选，但可能需要运行时 WRAM；先核对现有光标恢复的用户需求。 | 中 / 高 |
| **#192** `0d1d2e99aa` | fix(pc): 修复 Bill's PC 列表光标越过 Cancel | Bill PC 连续操作后 Cancel 越界 | **依赖暂缓** | RPP 在连续存取/放生后保留列表并需限制缩短后的可选行；CHS bills_pc.asm 仍是原有菜单流程，没有参考 NormalizeBillsPCListCursorAfterRemoval。 | 若移植参考 #073～076 连续 PC 改造，必须把本修复作为必需后续；当前不宣称 CHS 有此 Bug。 | 中 / 高 |
| **#193** `b201e7097d` | feat(pc): 统一 Bill's PC Pokémon 列表首尾跳转行为 | Bill PC Pokémon 列表首尾跳转 | **依赖暂缓** | 参考依赖 #192 边界规则，在 Cancel 与首只宝可梦间跳转；CHS 没有相同连续 PC 光标状态。 | 应与参考 #073～076、#192 成组评估，当前不孤立套用。 | 中 / 高 |
| **#194** `810de3bd1f` | feat(bag): TM/HM Pocket 支持 START 快捷跳转 HM01 | TM/HM Pocket START 跳转 HM01 | **当前不适用** | 参考要求 #078～082 的分类 Bag/Pocket Slot Map；CHS 使用原版背包/列表，没有 wBagPocketActive/BAG_POCKET_MODE_START。 | 当前不适用；若日后实现分类背包再列新需求。 | 低 / 高 |
| **#195** `80f36849f7` | fix(pc): 禁止 HM 道具存入 Player's PC | 禁止 HM 道具存入玩家电脑 | **待核验 Bug** | CHS src/engine/menus/players_pc.asm:PlayerPCDeposit 在 DisplayListMenuID 后仅 call IsKeyItem 决定询问数量，随后仍执行 AddItemToInventory/RemoveItemFromInventory；未见 IsItemHM 拦截；IsKeyItem_ 确实把 HM 当 Key Item，但不等于禁止存入。 | 较高优先级的真实路径差异：用备份存档验证 HM01～05 是否可存入/再取出；若确认，单独加存入前校验并测试一般 Key Item/TM。 | 低至中 / 高 |
| **#196** `9124e61a8c` | feat(hm): 允许普通技能替换 HM 技能并停用旧删除限制 | 允许 HM 技能被普通技能覆盖 | **需评估** | CHS src/engine/pokemon/learn_move.asm 中调用 IsMoveHM，仍显示 HMCantDeleteText；参考删除 HM 覆盖限制。 | 这是改变原版游戏规则而非修 Bug；可能影响卡关，未经用户决定不改。 | 中 / 高 |
| **#197** `049cc43002` | fix(bag): 优化道具使用后 Pokémon 菜单返回并统一快速恢复 | 道具选择 Pokémon 后的快速界面恢复 | **部分实现** | CHS 已有 START/Party 快速恢复（RestoreStartMenuFromPartyWhite 等），但 item_effects.asm 和 start_sub_menus.asm 仍保留多条 GBPalWhiteOutWithDelay3、RestoreScreenTilesAndReloadTilePatterns/ReloadMapData 路径；没有参考 Summary_RestoreStartBagFromParty。 | 优化目标部分重合但并不等价；有性能需求时按道具类型逐条计时/看闪烁，最小修改。 | 高 / 中 |
| **#198** `210e60f1b1` | fix(summary): 修复 Party 快速返回时按键音效被拉长 | 快速 Party LCD-off 后按键音被拉长 | **当前不适用** | RPP 的 #197 快速 Party/Bag LCD-off 调整引入按键音延长，#198 修其更新音效 VBlank 时序；CHS 未引入同一 #197 helper。 | 参考新增快速恢复的后续修复；CHS 若实测按键音延长则单独找原因，不能默认套补丁。 | 中 / 高 |
| **#199** `18ac734fb6` | perf(battle): 加快开战双方剪影平移速度 | 开战剪影 3 像素/帧快速滑入 | **需评估** | CHS core.asm:SlidePlayerAndEnemySilhouettesOnScreen 使用两次 inc b、两次 dec c 的 2 像素/帧；未使用参考 3 像素步长。 | 纯观感与时长变化，参考 #200 后来替代该固定速度，不建议移植中间态。 | 低至中 / 高 |
| **#200** `55955a7860` | perf(battle): 调整开战双方剪影平移至约 1 秒 | 开战剪影约 1 秒 2/3 像素节奏 | **需评估** | CHS core.asm 的 silhouette loop 仍固定 2 像素/帧；RPP #200 把 #199 调至 60 帧约一秒且使用相位累加器。 | 如用户想提速应仅评估最终 #200，不依次套 #199、#200；需测试玩家头部/OAM/背景滚动一致性和 DMG/CGB。 | 中 / 高 |
| **#201** `9dee10095f` | perf(battle): 按伤害比例分档调整战斗 HP 掉血速度 | 伤害百分比四档 HP 动画 | **已实现** | CHS src/engine/battle/damage_hp_animation.asm 明确记录 QOL-1.17 移植 BATTLE-5.19.9，0～25% 走原 UpdateHPBar2，25/50/75% 采用加速档。 | 同目标已完成，不重复移植；高 HP 流畅度额外实验仍按 TODO 保留暂停。 | 低 / 高 |
| **#202** `4699317302` | perf(battle): 平滑大伤害 HP 条刷新并强化超高速表现 | 加速掉血 Tile-only VBlank 刷新 | **已实现** | CHS src/engine/battle/damage_hp_animation.asm 已记载对 accelerated HP 临时关闭 AutoBG，专用 tile-only VBlank 按敌方一行/玩家两行刷新且避免 CGB palette 污染。 | 已实现核心刷新方案，不重复改动；注意不能据静态代码称所有高 HP 场景皆验收。 | 低 / 高 |
| **#203** `a5787d97e7` | fix(names): 修复压缩名称解码覆盖共享 HRAM 导致的商店价格异常 | 名称压缩导致商店价格异常 | **当前不适用** | 参考在 #183 DecodePackedName 后 FarCopyData2 覆写 hROMBankTemp/hItemPrice 导致 ¥200 显示 ¥340200；CHS 没有 DecodePackedName 或 packed_names。 | 是参考自己新增压缩后引入的错误，CHS 不存在对应诱因；若将来做 #183 必须将该修复视为前置保障。 | 低 / 高 |
| **#204** `c32244218f` | feat(battle): 延迟多段攻击的暴击与属性效果提示至实际最后一击 | 多段攻击暴击与属性提示放最后一击 | **需评估** | CHS battle/core.asm 对玩家/敌方多段攻击仍有各自 PrintCriticalOHKOText、DisplayEffectiveness 调用；参考新增统一 PrintAttackResultText 和击倒提前结算处理。 | 战斗提示 QoL 改变时序；不是已复现 Bug。需验证 2～5 连击、双针、提前击倒、敌我文本状态与 Link。 | 高 / 中 |
| **#205** `8a4350cdbd` | feat(battle): 模仿成功后立即使用复制的技能 | Mimic 成功后立即执行复制技能 | **需评估** | CHS engine/battle/effects.asm:MimicEffect 在 Copy move、GetMoveName 后 PlayCurrentMoveAnimation 并 jp PrintText，没有参考立即重入执行 copied move 的机制。 | 属于明显战斗玩法改变；默认保留原版。若决定做须连 #206 防递归校验及 PP/倒下/Link 回归。 | 极高 / 高 |
| **#206** `3d90324a46` | fix(battle): 限制Mimic复制目标避免立即行动导致的死循环 | Mimic 立即行动防死循环 | **依赖暂缓** | 参考为 #205 新规则禁止 MIMIC/TRANSFORM/STRUGGLE、自有技能；CHS 尚无 #205 的当回合直接执行。 | 是 #205 必要安全补丁而不是当前 CHS 独立 Bug；随 #205 一起评估。 | 高 / 高 |
| **#207** `49cb007161` | fix(battle): Thrash类技能失败时提前解除锁招 | Thrash/Petal Dance 失败时解除锁招 | **待核验 Bug** | CHS core.asm 玩家 handleIfPlayerMoveMissed 与敌方 handleIfEnemyMoveMissed 会直接跳过本击流程，但 ThrashingAbout 状态在 .ThrashingAboutCheck/ .checkIfThrashingAbout 的计数循环里清除；未见命中失败时的统一提前清锁招 helper。 | 值得真实复现：乱击/花瓣舞被免疫或未命中后，下一回合是否继续被锁以及是否错误混乱；确认后单独小修，保留敌我两路径。 | 中至高 / 中 |
| **#208** `f0c884ce8e` | feat(battle): 持久化Mirror Move目标并优化复制流程 | Mirror Move 最近有效选招记忆 | **需评估** | CHS battle/core.asm:MirrorMoveCopyMove 仍读取 wEnemyUsedMove/wPlayerUsedMove；参考新增独立 LastSelectedMove 记录并跨换人/异常状态保留。 | 独立玩法与可用性变化，涉及联机、续招和预留 WRAM；不作为当前 Bug 直接套。 | 极高 / 高 |
| **#209** `8533b7fbff` | feat(battle): 强化Mirror Move复制技能并修正目标记忆 | Mirror Move 复制技能 20% 增伤 | **依赖暂缓** | 参考以 #208 的目标记忆为前置，并在无 STAB 时对直接复制伤害招式加成 20%；CHS 未实现该特殊增伤。 | 属于刻意改战斗平衡，不建议默认移植。只有确认 #208 且明确要求新增规则才考虑。 | 极高 / 高 |
| **#210** `ace01974d6` | feat(version): 分离Red++与Blue++版本身份 | 红蓝版本身份和素材独立 | **部分实现** | CHS Makefile、src 仍有红蓝分别构建及 red/blue 资源和版本内容分支；参考 #210 同时把 RPP 的 Hard 模式和 Red++/Blue++ 独立身份、Color Hack 配色/SGB 逻辑绑定重构。 | 原始红蓝区分已有；RPP++ 内容/难度/音频/画面整套分离不适用，不能直接覆盖 CHS 的中文菜单和 SGB 配色。 | 极高 / 高 |

## 后续建议和依赖顺序

- **P1 验证，非直接移植：#195**。通过备份存档测试从 Player's PC Deposit 选择 HM01/HM05 能否存入及再取出；如确认影响玩法，最小修复拦截应放在实际写入物品数组之前，红蓝、DMG/CGB 冒烟测试普通道具、普通 Key Item、HM、TM。
- **P1 复现：#207**。保留一代规则先定义期望，再用 Thrash/Petal Dance 失手、属性无效以及自然最后一回合等案例核查；若是 RPP 特别加入的改规则，需要另外取得用户授权。
- **P2 低风险新功能候选：#189、#191**。只在有用户需求时评估独立 WRAM 记录，注意共享 Party/Bill's PC 光标状态与旧存档兼容，不修改 SRAM 格式。
- **P2 可选体验：#200、#197、#204**。先度量画面和声音时序，任何启动剪影加速只选参考最终的 #200，不套 #199 中间态；#197 如果实施，必须同时审查 #198 的按键音时序风险。
- **有高依赖的新功能：#186～188 的图鉴多页；#205～206 的 Mimic 立即执行；#208～209 的 Mirror Move 新规则**。不拆包套用、不混入普通 Bug 修复，不修改 CHS 原版对战规则直到明确授权。
- **已实现/无须重移植：#201～202**。参考名称压缩的后续商店 Bug #203 不适用于当前 CHS；但仍保留此前第六批 #173（BCD 输入指针）、#177（老虎机加载长度）和 #180（standing-only NPC）独立审计待办。

## 证据边界

- 上述判断为参考补丁与 CHS 源码的**静态对照**，在项目 `docs/` 中保留原始提交 Hash 及初步置信度；不等同于编译成功、图形测试或已发现运行缺陷。
- 参考源码的 `engine/menu/movedex.asm`、`engine/name_compression.asm`、`engine/menu/bag_pockets.asm`、`engine/menu/pokedex_info.asm` 与 CHS 的不同架构不得混同。
- CHS 对照位置：`src/engine/menus/players_pc.asm`、`src/engine/items/item_effects.asm`、`src/engine/pokemon/learn_move.asm`、`src/engine/menus/pokedex.asm`、`src/engine/menus/start_sub_menus.asm`、`src/engine/pokemon/bills_pc.asm`、`src/engine/battle/core.asm`、`src/engine/battle/effects.asm`、`src/engine/battle/damage_hp_animation.asm`、`src/home/names.asm`、`src/ram/wram.asm`、`Makefile` 等。
- **本轮没有修改**游戏功能、中文 DFS、CHR、ROM Bank 布局、版本号，也没有运行新 ROM 编译、模拟器测试或 Git Commit/Push。

下一批按约定仅评估 **211～240**，不得提前推断其状态。
