# RPP 参考分支移植台账：第 12 批（331～360）

> **CHS 对照基线**：已提交 `ROM-1.21.zip` / `CHS_Mod` HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **RPP 来源**：参考交接包 `individual/331～360`，本批 **30 笔实际提交，均有原始 patch**。
> **证据边界**：静态检查 RPP 原始提交描述/补丁和 CHS 当前 ASM、验收历史；未编译或运行新 ROM。分类仅表达当前证据，不将参考 Bug 自动认作 CHS 已复现问题。

## 本批主要判断

1. **#336 有明确的 CHS 源码寄存器覆盖问题，值得最高优先级专项核验**：`transform.asm` 开头 `ld a,[wEnemyBattleStatus1]` 紧接 `ldh a,[hWhoseTurn]`，玩家回合直接拿第二个值做 `INVULNERABLE` 测试。这可能导致目标 Fly/Dig 隐藏状态未被正确检查。此证据不依赖 RPP 地区形态系统，应单独最小修复、实测双方 Transform，不把 RPP 的 50 帧停顿和地区形态代码一起导入。
2. **#334 CHS 已实现**：`item_effects.asm` 留有 `PKMNRB_Fix 10` 注释，强制把变身后捕获物种识别为 Ditto 的旧逻辑已关闭。它是独立的修复，不因邻近 #333 地区形态提交就误判为不适用。
3. **#331～332 名人堂 PC**：CHS 具备名人堂 PC；目前的 `PCMainMenu` 仍靠 `ReloadMapData` 返回，轮播每只都整屏清屏。#331 需要先确认退出画面是否真的污染地图，#332 属可选提速/去闪，不应直接套用 RPP 的菜单资源恢复假设。
4. **#346～347 连续消耗道具及 PP/TM 菜单**：CHS 已做部分 Party 防闪，但没有完整的“同堆道具持续选目标”状态机；#346 是真实新 QoL 需求，#347 的功能需保护已稳定的 AutoBG/DFS 绘制路径。
5. **#354 和 #355 必须拆开看**：#354 中吐丝、瞬间失忆和缩小的规则变化确实与 CHS 现有动作不同，应用户选择；#355 中原版 STRUGGLE 1/2 反伤在 CHS 已有，其他 Flare Blitz / Volt Tackle 属扩展招式，不能说整笔尚未移植。
6. **#358～360 图标链**：#358 可选黄版/金银队伍图标；#359 引入动态 VRAM 装载和修复由此造成的换位白闪；#360 是新第二世代物种图标。宜成组评估，不宜为添加少量图标直接改动 Party VRAM 框架。
7. **#333、#337～343 地区形态及 #348～353、#357 扩展技能链**缺少前置条件。不应称为 CHS 当前 Bug，更不能无目标地复制 Crystal Audio/扩展战斗引擎。

## 分类统计

- **依赖暂缓：7**（#348、#349、#350、#353、#357、#359、#360）。
- **已实现：1**（#334）。
- **当前不适用：9**（#333、#337、#338、#339、#340、#341、#342、#343、#344）。
- **待核验 Bug：3**（#331、#336、#356）。
- **部分实现：2**（#347、#355）。
- **需评估：8**（#332、#335、#345、#346、#351、#352、#354、#358）。

## 331～360 逐笔移植评估

| 编号 / RPP Hash | RPP 原始标题 | 参考修改 | CHS 判断 | CHS 实际源码证据 | 移植建议与前置依赖 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#331** `972de8d6dc` | fix(pc): 修复名人堂电脑退出后的地图花屏 | 名人堂 PC 返回后重建 tile 图形以防前图污染地图 | **待核验 Bug** | CHS `src/engine/menus/league_pc.asm` 退出会整屏 WhiteOut/ClearScreen，`src/engine/menus/pc.asm:ReloadMainMenu` 统一调用 `ReloadMapData/UpdateSprites`；未见参考的 LeaguePC 专用 `ReloadTilesetTilePatterns` 退出保护。 | 存在对应路径但不等于已证实花屏。先完成名人堂 PC 进入/退出/再次进入和地图显示的最小实测，再评估是否只恢复 tileset，保护现有中文版 PC 菜单缓存。 | 中高 / 高 |
| **#332** `29f17bdf82` | fix(pc): 优化名人堂电脑轮播切换显示 | 名人堂轮播第二只起只清 7×7 前图，减少整屏白闪 | **需评估** | CHS `src/engine/menus/league_pc.asm:LeaguePCShowMon` 每只都调用 `GBPalWhiteOutWithDelay3` + `ClearScreen`，与 RPP 局部更新不同。 | 可选独立视觉优化；和 #331 的退出资源恢复兼容性联测，不因 RPP 显示更快而认定 CHS 有 Bug。 | 中 / 高 |
| **#333** `c69bca0727` | fix(forms): 补全 Transform 地区形态继承 | Transform 继承地区形态实例 Species/Form 并匹配纹理 | **当前不适用** | CHS `src/engine/battle/move_effects/transform.asm` 仅使用普通 Species/Type/DVs；无 RPP `RegionalFormGetBattleSlotFormIdentity`。 | 地区形态专属修复；没有实例 form marker 时无需移植。 | 高 / 高 |
| **#334** `39aba8363f` | fix(capture): 修复变身后捕获物种识别错误 | 变身后捕获保留敌方原始物种，避免误认为 Ditto | **已实现** | CHS `src/engine/items/item_effects.asm` 第 544～553 行保留 `PKMNRB_Fix 10`，已注释掉强制将 `wEnemyMonSpecies2` 改成 DITTO 的旧语句，随后按原种类装载。 | 同目标修复已有，禁止重复移植；其他变身捕获边界仍可按需测试。 | 低 / 高 |
| **#335** `23c9867a02` | fix(transform): 阻止重复及同身份变身并稳定 Transform 配色 | 重复/同身份 Transform 限制及完整 palette 保持 | **需评估** | CHS 原版 `transform.asm` 在初始 Invulnerable 判断后直接复制目标数据，不检查自身此前已变身、双方 Species/Form 相同；但没有 RPP 地区 form/palette-cache 系统。 | 可独立讨论重复 Transform 的原版规则是否需要改变；地区色板、双向缓存不可整笔移植，涉及 WRAM/Bank 和旧规则兼容。 | 高 / 高 |
| **#336** `a92186be32` | fix(battle): 统一失败文字节奏并补充技能说明 | Transform/Mist/Conversion 失败提示节奏与 Transform Fly/Dig 判定修复 | **待核验 Bug** | CHS `src/engine/battle/move_effects/transform.asm` 开头先 `ld a,[wEnemyBattleStatus1]` 后立刻 `ldh a,[hWhoseTurn]` 覆盖 A，玩家分支 `.hitTest` 直接 `bit INVULNERABLE,a`；会检查到回合编号而非敌方隐藏状态。`mist.asm` 失败也未加参考 50 帧节奏。 | 优先核实**玩家对处于 Fly/Dig 半无敌目标使用 Transform** 的行为：有明确源码寄存器覆盖缺陷，建议单独最小修复并测试双方路径；参考的 MoveDex 和地区形态失败条件不套用。 | 中 / 高 |
| **#337** `5b55c92267` | feat(forms): 补全训练家、礼物、NPC交换与地区进化形态生产链 | 训练家、礼物、NPC 交换与地区进化 form marker 生产链 | **当前不适用** | CHS 训练家队伍/礼物/NPC 交换数据没有 RPP TRAINER_FORM_MON、15-byte trade row 或持久地区 form marker。 | 大型地区形态系统新增，非现有 Bug；牵涉存档、交易及中文名称，暂缓。 | 极高 / 高 |
| **#338** `aa9af3ca30` | feat(forms): 固化随机野生遭遇的地区形态实例身份 | 随机野怪地区形态身份固定 | **当前不适用** | CHS 没有 RPP `wEnemyMonForm`/region persistent marker 选择流程。 | 只在引入地区形态后作为伴随组件考虑，当前不移植。 | 高 / 高 |
| **#339** `e9bcb3f871` | feat(forms): 固化初始宝可梦的显式地区形态身份 | 御三家显式地区形态实例标记 | **当前不适用** | CHS 御三家使用普通物种路径，未设地区形态状态位。 | 参考新 form 系统的生产者修复，不作为 CHS 缺陷。 | 中高 / 高 |
| **#340** `37d0c72beb` | feat(forms): 固化钓鱼与撞树遭遇的地区形态实例身份 | 钓鱼/撞树遭遇携带显式地区形态 | **当前不适用** | CHS 没有地区形态 marker；此前审查也指出撞树系统是 RPP 可选新功能。 | 缺少双重前置，不应独立移植。 | 高 / 高 |
| **#341** `c7822e33ca` | feat(forms): 固化固定野怪遭遇的地区形态实例身份 | 固定野怪遭遇的地区形态身份 | **当前不适用** | CHS 固定遭遇使用原版 Species，不支持地域 Form 编码。 | 新系统专属；仅未来做地区形态时成组研究。 | 高 / 高 |
| **#342** `1fcc440106` | feat(forms): 增加地区形态持久标记的编译期防撞检查 | 地区形态持久标记编译期防撞断言 | **当前不适用** | CHS 不存在 RPP RegionalForm 的 marker/别名分配规则。 | 没有对应 marker，断言无检查对象；暂不引入。 | 低 / 高 |
| **#343** `00fb1931c5` | feat(forms): 固化培育产生宝可梦的地区形态实例身份 | 培育/孵蛋地区形态实例身份 | **当前不适用** | CHS 无地区形态系统，且没有 RPP 区域形态培育逻辑。 | 依赖地区形态与培育链，当前不适用。 | 高 / 高 |
| **#344** `5d542adde1` | docs(todo): 建立当前路线图并校正 TM 状态说明 | RPP 自有 TODO 与 TM 状态说明整理 | **当前不适用** | 提交仅修改 RPP `TODO.md`，记录其自身功能路线；不是游戏源码修复。 | 不要将参考项目路线图直接覆盖 CHS 的 TODO；用本台账记录关联即可。 | 低 / 高 |
| **#345** `e4e12c03ef` | feat(evolution): 增加冰之石并完善进化石等级门槛流程 | 新增冰之石，商店供应和进化石最低等级 UI | **需评估** | CHS `src/constants/item_constants.asm` 没有 ICE_STONE，原版进化石与 TM 结构仍沿用自己的设计；RPP 目的包含 Alolan Vulpix 等地区进化。 | 如单独想新增冰之石，需要先确定适用宝可梦、物品 ID、中文道具名称、商店库存和存档兼容；否则当前不做。 | 高 / 高 |
| **#346** `15e52a9d8a` | feat(items): 完善队伍消耗道具连续使用流程 | 治疗药、糖果、PP 和维生素对队伍连续使用 | **需评估** | CHS `src/engine/items/item_effects.asm:ItemUseMedicine` 每次先 `DisplayPartyMenu`，典型成功分支用 `RemoveUsedItem` 返回，缺少统一的堆叠剩余持续选目标机制。 | 实用可选 QoL。建议独立评估同种道具续用、无效目标、使用完归零、战斗中/进化石例外；不能直接套 RPP 的 WRAM 和 Item 流程。 | 高 / 高 |
| **#347** `5dda2fb671` | feat(menu): 收口队伍PP道具与TM教学的菜单显示和返回流程 | PP 单技能道具取消返回 Party；TM 教学失败轻量回 Party 防闪 | **部分实现** | CHS 先前 FLH/QOL 修复了 Party 返回 AutoBG/白闪，`item_effects.asm:ItemUsePPRestore/ItemUseTMHM` 仍走原版 `DisplayPartyMenu` 和返回入口；没有 RPP 的连续道具流程。 | 显示闪烁方面部分同目标已实现，PP/TM 流程还有实际差异；若做应连同 #346 审视，避免复活已修复闪烁。 | 中高 / 高 |
| **#348** `4ec23173ca` | feat(animation): 移植 Polished Crystal Hurricane 暴风动画并收口运行验证 | Hurricane 暴风的 Polished Crystal 扩展动画 | **依赖暂缓** | CHS `src/constants/move_constants.asm` 无 HURRICANE；缺 RPP `extended_move_animations` 和对应音画。 | 新技能+扩展特效，非既有 Bug；不移植。 | 高 / 高 |
| **#349** `01031fd728` | feat(animation): 重制 Sucker Punch 突袭动画并使用 Dark 命中配色 | Sucker Punch 突袭暗系配色与专用动画 | **依赖暂缓** | CHS 无 SUCKER_PUNCH、暗系及 RPP 扩展动画路径。 | 与 #350 成组，不能先移植动画。 | 高 / 高 |
| **#350** `495c8557e0` | feat(battle): 补全 Sucker Punch 突袭的现代失败判定 | 突袭技能的现代失败判定 | **依赖暂缓** | CHS 没有 Sucker Punch 招式 ID，RPP 判定需要物理/特殊拆分和出招状态。 | 依赖先有招式和现代规则；不作为 CHS 原版战斗 Bug。 | 高 / 高 |
| **#351** `d706e39e61` | feat(battle): 引入多级招式优先度并区分 ExtremeSpeed | 多档行动优先度及 ExtremeSpeed 独立优先级 | **需评估** | CHS 使用一代招式及行动顺序，缺 RPP 扩展 EXTREME_SPEED；替换优先度系统会改战斗平衡。 | 大规模规则扩展，用户明确要求现代战斗机制前暂缓；独立考虑联机确定性。 | 极高 / 高 |
| **#352** `694c46e7f7` | feat(move): 将 Rolling Kick 替换为 Aura Sphere 并移植专属动画 | 用 Aura Sphere 波导弹替换 Rolling Kick 回旋踢并接专属动画 | **需评估** | CHS `src/constants/move_constants.asm` 和 `src/data/moves/moves.asm` 仍有 ROLLING_KICK，缺 Aura Sphere/物特分离；原位替换会影响旧存档招式 ID。 | 真实玩法改动，不是 Bug；必须用户决定，默认不动。 | 极高 / 高 |
| **#353** `306a28f605` | feat(animation): 移植 Gold/Crystal 金属翼动画并完成实机验收 | Steel Wing 金属翼与 Iron Tail/翅膀攻击复合动画 | **依赖暂缓** | CHS 无 STEEL_WING/IRON_TAIL 原招式 ID，不具备参考扩展特效与 Steel 调色路径。 | 多前置的新技能动画；暂缓。 | 高 / 高 |
| **#354** `17799318cc` | feat(battle): 完善伤害型能力副作用与初代 Special 平衡并完成验收 | 特殊能力副作用与 Gen I Special 平衡、吐丝/瞬间失忆/缩小等规则调整 | **需评估** | CHS `src/data/moves/moves.asm` 明确为 `STRING_SHOT SPEED_DOWN1_EFFECT`、`AMNESIA SPECIAL_UP2_EFFECT`、`MINIMIZE EVASION_UP1_EFFECT`，有真实现有招式差异；参考其他招式多为新增。 | 拆开评估：现有三招属于玩法平衡调整，需用户明确选择，不应一并导入参考新增技能的副作用表。 | 高 / 高 |
| **#355** `afc05dc6c1` | feat(battle): 完善反伤比例与火推电推状态效果并完成本轮验收 | Struggle/其他招式反伤比例及 Flare Blitz/Volt Tackle 附加状态 | **部分实现** | CHS `src/engine/battle/move_effects/recoil.asm` 已为 STRUGGLE 设置 1/2，其他原版反伤为 1/4；缺参考新增 FLARE_BLITZ、VOLT_TACKLE、WOOD_HAMMER 的 1/3 和状态链。 | 原版比例已实现/保留，不重复；新增招式的反伤与烧伤/麻痹缺前置，不单独移植。 | 中 / 高 |
| **#356** `2d4ee184fd` | feat(battle): 修正替身多段攻击与反伤结算时序并完成本轮验收 | 替身被多段攻击打破时本体连续受击和反伤时序 | **待核验 Bug** | CHS 存在 `src/engine/battle/core.asm` 的 Substitute/multihit/recoil 路径，但没有 RPP 独立 `substitute_multihit_helpers.asm` 的状态调整与次序重排。 | 属于可能与原版共通的边界问题。建议先复现“多段击破替身→剩余命中本体”与“反伤/双方濒死”再独立修复；高回归风险，不直接复制。 | 极高 / 中 |
| **#357** `d6671c9232` | feat(animation): 完善伏特攻击三档动态中心及首尾电流轨迹并完成验收 | Volt Tackle 三档中心、五道电流及帧轨迹 | **依赖暂缓** | CHS 无 VOLT_TACKLE、Spark/MBC 新专用动画调度和参考动态特效 Bank 框架。 | 扩展技能专用视觉，依赖 #355 等；暂缓。 | 高 / 高 |
| **#358** `86439bcf46` | feat(ui): 融合首批黄版／金银队伍小图标并完成本轮验收 | 新增黄版皮卡丘与金银海星/蝙蝠/幽灵队伍图标 | **需评估** | CHS `src/data/pokemon/menu_icons.asm` 使用紧凑 4-bit 类别表，Pikachu 仍 ICON_FAIRY、Zubat/Gastly 仍 ICON_MON；`src/data/icon_pointers.asm` 为原版固定图块映射。 | 属于真正有差异的可选 UI 功能。若需导入，先核对图标素材、中文菜单 OAM/VRAM 与镜像帧，不宜整套套补丁。 | 中高 / 高 |
| **#359** `96a0e6747a` | feat(ui): 引入队伍小图标动态加载框架并修复换位白闪，完成本轮验收 | 按队伍槽动态加载图标并修复普通/SELECT 换位白闪 | **依赖暂缓** | CHS `src/engine/gfx/mon_icons.asm` 在进入 Party 前固定 `LoadMonPartySpriteGfxWithLCDDisabled`，而 RPP 使用逐槽动态 atlas 和换位 tile 映射；CHS 原版换位未出现 RPP 引入的同一动态加载白闪。 | 只有决定突破固定类别/VRAM 限制时才需此架构；必须把 RPP #359 的防白闪修复一并引入，保护 FLH Party 窗口优化。 | 极高 / 高 |
| **#360** `d452e78567` | feat(ui): 引入金版洛奇亚与凤王专属队伍小图标并完成本轮验收 | 新增金版洛奇亚/凤王专属 Party 图标 | **依赖暂缓** | CHS 不支持 RPP 两类新图标的动态图集/类别映射，且当前 CHS 原版物种并无 Lugia/Ho-Oh。 | 依赖 #358～359 乃至扩充第二世代物种；当前不移植。 | 中高 / 高 |

## 建议的分批处理次序（本批只评估、不实施）

| 顺序 | 提交 | 处理建议与门槛 |
|---|---|---|
| **优先核查 1** | **#336** | 对照玩家 Transform 目标 Fly/Dig 隐身状态的寄存器值；有明确的源码 A 覆盖问题，适合独立修复并最小测试双方回合。不能照搬地区形态附加逻辑。 |
| **优先核查 2** | **#331** | 名人堂 PC 进入/退出/再次进入及背景恢复；先复现，没问题就不改。 |
| **需要专项复现** | **#356** | Substitute 被多段攻击击破后的连续伤害、反伤/双倒；高复杂度，不与菜单优化混合。 |
| **可选独立 QoL** | **#332、#346～347** | 名人堂轮播去闪；消耗道具继续使用、PP/TM 返回轻绘。需保护 CHS DFS/Party 已有修复。 |
| **明确已实现** | **#334** | CHS 已移除把所有变身捕获当 Ditto 的原版故障处理；不重复改。 |
| **可选新功能** | **#358～359** | 黄版/金银队伍图标与动态资源加载需分别评估，先小规模 UI 方案，不能遗漏 #359 换位防白闪。 |
| **只在用户确定改战斗规则后** | **#335、#351～352、#354** | 重复 Transform 限制、优先度/替换招式、特攻平衡均改变既有游戏规则和可能的旧存档行为。 |
| **暂不适用** | **#333、#337～343、#348～350、#353、#357、#360** | 依赖地区形态、第二世代物种或参考扩展招式/动画，不作为 CHS 原版待修 Bug。 |

## 下一批与验收边界

- 前十一批（001～330）已登记 **328 笔实际提交**，其中 `#072` 与 `#269` 缺号；本批 331～360 的 **30 笔均存在**，累计登记 **358 笔**。
- 下批为 **361～390**；未审查提交不预先判定状态。
- 本轮只更新 `docs/` 评估表、索引、统一验收历史及 `TODO.md`；**不改游戏 `src/`、版本 `ROM-1.21`，不编译、不运行、不 Commit/Push。**
