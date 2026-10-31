# RPP 参考分支移植台账：第 10 批（271～300）

> **CHS 对照版本**：`ROM-1.21.zip`，已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **RPP 来源**：交接包 `individual/271～300` 共 **30 笔真实提交**，以原始 Hash、标题、补丁改动文件和提交正文为准。
> **审查边界**：静态对照 CHS 现存 `src/`、历史记录及 RPP 补丁元数据。**待核验 Bug ≠ 已复现 Bug；原引擎功能不同 ≠ CHS 缺少修复**。此次不运行游戏、不移植代码、不变更版本号。

## 本批核心判断

1. **#272～276 音乐功能链**：先新增 GB Player (158 首 RBY/GSC/custom 曲目)，再改 UI、Options 音乐风格和 Random 曲库；#275 是这套新音乐映射的去重修补。CHS 使用自有音频引擎、没有 Crystal Audio 的 `crysaudio/engine.asm`，不能把这 5 项当成可直接移植的小 Bug。
2. **#277 和 #283/#291**：分别涉及 RPP 扩展技能 Dynamic Punch/Nuzzle、新 Oak 开场后调色板问题、Fly/Dig 特殊命中规则引入后的显形回归。CHS 没有相同前提，这些不能记作 CHS 已有故障。
3. **#278/#279 值得小范围核验**：CHS 未知地点显示仍有前导空格，能力大幅变化文本中有 `text_pause`；这与 RPP 优化目标存在源码差异，但要先验证实际页面错位或重复停顿后再改。
4. **#280/#281/#289 属于可拆分的菜单体验调整**：姓名鉴定、TM 取消返回、Party SELECT 置顶、背包/PC 快捷键；不能把 RPP 的 Move Deleter/Move Relearner/MoveDex 相关调用误当成 CHS 必有路径。
5. **#284～288、#293～300 大量动画扩展**：CHS 保留原版动画解释器，RPP 拆分/桥接、high-water OAM、direct ROM script、18 属性动态配色及新技能是有前后依赖的整套功能链。#295/#296 是前序扩展动画产生的新槽位清理，不能独立“省空间”。
6. **#290～291 是成对的玩法更新/修复**：#290 改半无敌规则，#291 修其新增允许命中的显形问题。CHS 当前保留一代半无敌规则，既非缺功能 Bug，也不应只套 #291。
7. **#292 的 Battle Helpers 拆分**主要解决参考 Bank $0F 等 ROMX 组织，不自动释放 CHS ROM0。若未来 ROMX 目标 Bank 空间不足，再用 CHS 新 MAP 与 ABI 检查评估收益和迁移风险。

## 分类统计

- **依赖暂缓：14**（#272、#273、#274、#276、#285、#287、#288、#293、#294、#295、#296、#298、#299、#300）。
- **当前不适用：6**（#271、#275、#277、#283、#291、#297）。
- **待核验 Bug：2**（#278、#279）。
- **部分实现：1**（#280）。
- **需评估：7**（#281、#282、#284、#286、#289、#290、#292）。

## 271～300 逐笔移植评估

| 编号 / RPP Hash | RPP 原始提交标题 | 核心改动 | CHS 现状 | CHS 源码对照依据 | 建议与移植约束 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#271** `2e60784dea` | fix(link): 修复联机摘要首开花屏并同步联机房名称 | 联机状态页首次共用图块/联机房地图名称 | **当前不适用** | CHS `src/engine/link/cable_club.asm:TradeCenter_DisplayStats` 仍直接调用 StatusScreen/StatusScreen2；全源码未见 RPP 的 `wStatusScreenCommonTilesReady` one-shot 标志；联机房中文地名系统也不同。 | 参考所修的 one-shot 缓存被联机接收块覆盖的前提不成立；CHS 若有首次打开联机摘要花屏，需按本项目图块载入/DFS 时序重新定位，不直接移植标志位修补。 | 中高 / 高 |
| **#272** `52519a72ae` | feat(audio): 新增 GB Player 并支持 RBY/GSC/custom 曲目试听 | GB Player 音乐播放器道具、158 首曲库 | **依赖暂缓** | CHS `src/constants/item_constants.asm` 无 GB Player；`src/audio/` 为原有引擎，无 `crysaudio/gb_player_pointers.asm` 和 GSC/custom 直选 Music ID。 | 作为大型可选音乐播放器新功能，必须先独立确认需求、曲目版权、可用 Bank/WRAM 与音乐格式；不直接引入 Crystal Audio 和 158 首曲库。 | 极高 / 高 |
| **#273** `8b0d2c5bf6` | feat(audio): 将 GB Player 界面与 MoveDex 对齐并完善菜单交互 | GB Player 与 MoveDex 布局和局部重绘 | **依赖暂缓** | CHS 无 `engine/menu/gb_player.asm`，也无 MoveDex 的右侧功能栏布局；本提交是 #272 新播放器的二次 UI 重构。 | 仅在先立项完成本项目音频播放器后参考交互模式；作为孤立 Bug 修复当前不适用。 | 高 / 高 |
| **#274** `d12dc2301a` | feat(audio): 在设置中添加音乐风格切换并支持 Custom/Random | Options 三页音乐风格 RBY/GSC/RND/CSTM | **依赖暂缓** | CHS `src/engine/menus/options_menu.asm` 没有 `MusicStyle` 和 RBYC/GSCC 选项；RPP 改 `crysaudio/engine.asm` 的播放映射策略。 | 依赖 #272 的曲库与 Crystal Audio，不应触碰 CHS 稳定音乐引擎；如用户希望切风格，先独立设计 CHS 可播放数据。 | 极高 / 高 |
| **#275** `814d4dba60` | fix(audio): 移除重复 GSC 映射并修正 Random 候选 | 去重 GSC 音乐映射并修正 Random 候选 | **当前不适用** | 这是 #274 的 RBY→GSC/CSTM/RND ID 映射表清理；CHS 没有该映射和 RND 音乐风格。 | RPP 新功能的后续修正，当前 CHS 无对应对象可修；未来若移植音乐风格需将其作为依赖清单。 | 低 / 高 |
| **#276** `d3a1e92dcd` | feat(audio): 扩展 Random 模式并支持多候选 BGM 池 | Random 音乐模式多候选 BGM 池 | **依赖暂缓** | RPP 为 #274 增加 MusicStyleRandomExtraMap；CHS 无 MusicStyle / Random BGM family 和相应数据表。 | 是前序播放器/音乐风格开发链，暂缓；切勿为该功能改地图/战斗正常 BGM ID。 | 高 / 高 |
| **#277** `f6cc3367b5` | fix(battle): 修复 Dynamic Punch 与 Nuzzle 副作用动画及失败停顿 | Dynamic Punch 混乱与 Nuzzle 麻痹副作用重复动画/失败等待 | **当前不适用** | CHS `src/constants/move_constants.asm` 为原版技能表，没有 Dynamic Punch/Nuzzle；`src/engine/battle/effects.asm:ConfusionSideEffectSuccess` 对普通混乱仍区分副作用/主动技能动画，`ConfusionEffectFailed` 有 50 帧等待。 | 原提交针对扩展招式，不直接套；若 CHS 原有混乱/麻痹招式出现重复动画或不必要停顿，应按原版招式另行复现，不能据此认定已有 Bug。 | 中 / 高 |
| **#278** `ffe486fe5f` | fix(town-map): 区分未知地点文本在不同界面的显示 | 未知地图名称在图鉴与 Continue/Save 的空格差异 | **待核验 Bug** | CHS `src/engine/items/town_map.asm:AreaUnknownText` 仍是带前导空格的 `" AREA UNKNOWN@"`；与 RPP 专门将地图/图鉴/存档界面拆分字符串的做法不同。 | 先确认 CHS 图鉴、地图、存档/继续页面实际是否共用同一串以及出现对齐异常；若确有不齐，按中文显示坐标做最小改动。 | 低中 / 中 |
| **#279** `3049bad5da` | fix(battle): 修正能力大幅变化文本的重复停顿 | 能力大幅上升/下降文字重复停顿 | **待核验 Bug** | CHS `src/engine/battle/effects.asm:GreatlyRoseText/GreatlyFellText` 仍存在 `text_pause`，而参考提交移除其额外等待以避免重复 `Char4C` 停顿。 | 用 Sword Dance、Tail Whip 等 ±2 能力变化逐帧比较提示停顿；待确认真实双重暂停后再修 CHS 文本，不直接删中文文本控制码。 | 低 / 中高 |
| **#280** `91c532d36b` | fix(menu): 优化技能服务与改名流程的逐级返回 | TM/HM、姓名鉴定、技能遗忘/回忆/教学的多级返回 | **部分实现** | CHS `src/scripts/NameRatersHouse.asm` 有宝可梦选择与放弃改名路径，`src/engine/menus/start_sub_menus.asm` 有 Party 返回；但无 RPP 独立 `scripts/move_deleter.asm` / `move_relearner.asm` / `move_tutor.asm` 整套服务。 | 把原本存在的姓名鉴定、TM 放弃换招当成独立 QoL 核对；缺失服务不当作 Bug，不能移植参考的菜单栈整体改动。 | 中高 / 高 |
| **#281** `8dc5129a23` | fix(menu): 简化姓名鉴定改名确认流程 | 姓名鉴定去掉冗余 How about it? 文本页 | **需评估** | CHS `src/text/NameRatersHouse.asm:_NameRaterText_1dabd` 仍含 `para "How about it?"`，后续确实在脚本内再调用 YesNoChoice。 | 是低风险文本精简候选，须考虑汉化文本显示节奏和用户偏好；按需要单独做，不属于必须修复。 | 低 / 高 |
| **#282** `fc064b6bba` | feat(intro): 优化新游戏开场流程 | Oak 开场性别选择前移及红蓝不同演示精灵 | **需评估** | CHS `src/engine/movie/oak_speech/oak_speech.asm:OakSpeech` 仍展示 NIDORINO、RedPicFront、ChoosePlayerName，再 ChooseRivalName；没有 RPP Red++/Blue++ 性别选择流程。 | 属于大型开场新功能，涉及性别人物图、命名与旧存档/默认人设；暂时不做，不能把不一样的演出当 Bug。 | 高 / 高 |
| **#283** `0c89fcca7f` | fix(intro): 修复 Oak 开场调色板残留 | 修复新 Oak 性别/调色板开场遗留颜色 | **当前不适用** | RPP 紧跟 #282 修复新版开场的调色板状态；CHS 没有该性别选择与 Pikachu palette 残留来源。 | 参考新增开场后的衍生修复，当前不直接适用；如 CHS 自身开场确有残色，应独立复现。 | 低中 / 高 |
| **#284** `3db7017063` | feat(battle): 平滑连续投射物战斗动画 | 连续投射物战斗动画逐 VBlank OAM 平滑 | **需评估** | CHS `src/engine/battle/animations.asm` 使用原版 Subanimation frame/OAM 路径；无 RPP extended move recipe 复用和相同平滑白名单。 | 原版 Leech Seed、Swift 等可单独评估视觉收益，但 451 行动画改动影响帧节奏/音效/双模式，不作为 Bug 直接移植。 | 高 / 高 |
| **#285** `9dfb554632` | feat(battle): 平滑捕获球与投掷类抛物线动画 | 精灵球、Pay Day、Safari 投掷动画平滑 | **依赖暂缓** | 参考只向 #284 已建立的逐 VBlank 平滑白名单添加投掷/抛物线类型；CHS 未建该机制。 | 需要先做 #284 的独立、兼容 DMG/CGB 平滑实现，再把这一笔作为可选小扩展。 | 中 / 高 |
| **#286** `8c4b2eb4ca` | feat(battle): 重做吸取系动画节奏并恢复回流重力感 | 吸取系动画回流节奏与重力感 | **需评估** | CHS `src/data/moves/animations.asm` 保留 Absorb/MegaDrain 对应原版动画，缺少 RPP 专用动画辅助节奏。 | 主观视觉增强，可用原本动画系统少量重做作为独立选项；没有复现问题时不优先。 | 中 / 中高 |
| **#287** `6a7e59b3d5` | feat(battle): 完善分段动画桥接并修复 Acid 切换 | 分段动画 OAM high-water 桥接、Acid 去空白 | **依赖暂缓** | RPP 修改 `data/extended_move_animations.asm`、动画引擎及 WRAM 桥接；CHS 没有该 extended recipe 数据和桥接状态。 | 是参考扩展动画系统新机制；如果将来立项逐帧平滑，再一起设计 OAM/WRAM/Bank 资源，不单独套。 | 高 / 高 |
| **#288** `7bd9c65d3d` | feat(battle): 实现 Shadow Punch 跨阶段残留与命中特效同步 | Shadow Punch 跨阶段拳头残留 | **依赖暂缓** | CHS 没有 Shadow Punch 扩展招式及 #287 high-water OAM 桥接；原版招式表未定义该技能。 | 依赖 #287 与扩展招式，当前不适用；只作为后续新技能功能链参考。 | 高 / 高 |
| **#289** `c3c8aeffd1` | feat(menu): 新增 Party 与 Bag 菜单快捷操作 | Party SELECT 置顶及 Bag / PC 菜单快捷操作 | **需评估** | CHS `src/engine/menus/start_sub_menus.asm` 已有 SwitchPartyMon 和 Bag 光标保存，但无 `START_PARTY_MENU` 专用 SELECT 快捷范围，也无 `engine/menu/menu_shortcuts.asm`。 | 可独立分出 Party 首位交换、Bag/PC 快捷跳转两个可选 QoL；需要检验输入作用域、中文光标、战斗/改名/教学等入口不误触。 | 中高 / 高 |
| **#290** `5d6c4d456f` | feat(battle): 补充 Fly / Dig 半无敌状态特殊招式交互 | Fly/Dig 半无敌期间部分后世招式特殊命中/倍伤 | **需评估** | CHS `src/engine/battle/effects.asm` 的 `INVULNERABLE` 仍按原版半无敌规则；没有 RPP bank34 例外招式查表，部分后世招式亦不存在。 | 属于刻意改变一代战斗规则的新玩法，不是 bug 修复；只有用户明确希望采用后世交互才成组设计与测试。 | 高 / 高 |
| **#291** `1e6a5eac78` | fix(battle): 修复 Fly / Dig 特殊命中后的异常显形 | Fly/Dig 特殊命中后提前显形 | **当前不适用** | RPP #291 修复 #290 新允许命中规则导致的 sprite 恢复；CHS 未实现 #290 的例外命中逻辑。 | 先决功能不存在，单独补丁不适用；未来如果移植 #290 必须同时核对 #291。 | 低中 / 高 |
| **#292** `82ce72f94d` | refactor(battle): 拆分暴击、特殊伤害与中毒效果逻辑 | 暴击、固定伤害和中毒效果搬至 Battle Helpers | **需评估** | CHS `src/engine/battle/core.asm:CriticalHitTest` 与 `src/data/battle/critical_hit_moves.asm` 仍在原项目路径；伤害、中毒分支也分布在 core/effects。 | 属于 Bank $0F 等 ROMX 空间整理，不等于释放 ROM0；若特定 Bank 确实吃紧先做真实 MAP/跨 Bank ABI 评估，不为重构而重构。 | 高 / 高 |
| **#293** `ef26e87ba5` | feat(battle): 重做 Wing Attack 与 Drill Peck 动画 | Wing Attack/Drill Peck 扩展动画重绘 | **依赖暂缓** | CHS `src/data/moves/animations.asm` 有 WingAttackAnim、DrillPeckAnim，但没有 RPP `data/extended_move_animations.asm` 和专用配方。 | 普通攻击动画存在不代表扩展动画实现；视觉需求明确时再单独设计，后续 #296 为本链槽位优化。 | 中高 / 高 |
| **#294** `3e3ffdbb6e` | feat(battle): 完善 Sludge 与 Acid 分段动画 | Acid/Sludge 动画衔接与毒液下落 | **依赖暂缓** | RPP 依赖 #287 high-water 桥接与 extended animation 配方；CHS 为原版 Acid/Sludge 动画。 | 需先有同类扩展桥接，不能直接把参考特有的阶段闪烁记为 CHS Bug。 | 中高 / 高 |
| **#295** `bd71e753e8` | refactor(battle): 复用 Sludge 滴落阶段并释放 Subanimation 槽位 | 复用 Sludge 滴落段并释放 Subanimation57 | **依赖暂缓** | 参考在 #294 的新增滴落动画上再清理额外 Subanimation57；CHS 的原版 Subanimation 编号不同。 | RPP 新动画优化，单独移植没有可复用对象；并入未来扩展动画专题。 | 中 / 高 |
| **#296** `f75ba2832f` | refactor(battle): 释放 Wing Attack 的 Subanimation 槽位 | 释放 Wing Attack 使用的 Subanimation56 | **依赖暂缓** | 参考 #293 先新增 Wing Attack 三段演出，再移除专用槽位；CHS 未新增该槽位。 | 是 #293 的后续空间回收，当前不适用。 | 中 / 高 |
| **#297** `b6b7d07e21` | feat(battle): 加入 KEP Iron Head 并恢复对应学习列表 | 新增 KEP Iron Head #254 与扩展学习表 | **当前不适用** | CHS `src/constants/move_constants.asm` 原版技能表中没有 Iron Head，也没有 KEP 254 招式、Steel 物攻分类及阿罗拉形态体系。 | 这是大型新增技能/世代规则差异，不是修复；如未来扩展招式系统，须先做技能 ID、翻译、存档与攻击分类规划。 | 极高 / 高 |
| **#298** `70d3489f22` | fix(animation): 恢复闪焰冲锋、伏特攻击与终极冲撞旧版动画及音效语义 | Flare Blitz/Volt Tackle/Giga Impact 旧动画直读 ROM | **依赖暂缓** | 这些均为 RPP 的扩展技能；参考新增 direct-script 动画模式与临时 Bank 指针、SFX 语义，CHS 没有对应机制。 | 只能随扩展技能动画引擎整套评估，当前无可独立迁入的小修复。 | 极高 / 高 |
| **#299** `d9573d1a1b` | fix(animation): 恢复 Gunk Shot 与 Poison Jab 旧版动画并完善毒系动态配色 | Gunk Shot/Poison Jab 毒系动画与动态 OBJ 配色 | **依赖暂缓** | CHS 无 Gunk Shot/Poison Jab 扩展技能和 `MOVE_TYPE_DARK` 18 属性调色模式；RPP 依赖 #298 direct-script。 | 参考新技能与动态调色系统专属，现阶段暂缓。 | 高 / 高 |
| **#300** `2e2ea4ee58` | fix(animation): 恢复多项旧版技能动画与特殊演出 | Ice Shard/Tri Attack/Crabhammer 等多项重绘 | **依赖暂缓** | CHS 有 IceBeam、TriAttack、Crabhammer 等原版招式，但没有 Ice Shard/Power Gem/Rock Blast 扩展招式及 RPP 的 extended recipe/动态调色轨道。 | 若以后只优化某个原版技能，应拆成独立视觉需求；不能整体套入混合扩展技能与动画解释器的提交。 | 高 / 高 |

## 维护者可以选择的后续项目（本次未实施）

| 优先级 | 提交 | 下一步 | 约束 |
|---|---|---|---|
| P1 小型核验 | **#279** | 在 CHS 当前战斗中使用能力 +2/-2 招式，比较动画/文字停顿，确认是否存在重复等待 | 涉及中文文本 `text_pause` 的位置，不可只依参考删除控制码 |
| P1 小型核验 | **#278** | 在图鉴/城镇地图/Continue 或存档页检查未知地点名称位置 | 只有真实出现多余空格或错位才做最小修补 |
| P2 用户选择 | **#281** | 决定是否去掉姓名鉴定冗余确认句 | 文本体验变更，避免破坏中文标点和 Yes/No 顺序 |
| P2 用户选择 | **#289** | 拆开评估 Party 置顶和 Bag/PC 快捷键，先确定键位冲突和生效入口 | 禁止影响战斗 Party、取名字、技能学习等其他调用者 |
| P3 性能专项 | **#284/#285** | 如确实需要改善精灵球/投射物动画，再独立评估逐 VBlank 插值 | 需保证 DMG/CGB 帧计时和音效一致，量化空间预算 |
| P3 空间专项 | **#292** | 先收集新 MAP 的 Bank $0F、$34 余量，若确实吃紧再研究代码分拆 | 不是 ROM0 收益，不能贸然改跨 Bank 入口 |
| 暂缓 | **#272～276、#287～288、#293～300** | 统一归入音乐播放器/扩展招式动画独立专题 | Crystal Audio 和参考新系统依赖不可省略 |
| 按玩法决定 | **#290/#291** | 若以后考虑后世 Fly/Dig 命中规则，必须一起评估 | 不把改变战斗规则当修 Bug |

## 下批与既有结论

- 前九批 `001～270` 已登记 **268 笔真实提交**（#072、#269 缺号）；加本批 **30 笔**，累计 **298 笔**，审查至 #300。
- 下一批 **301～330**；本批没有变更先前对 #177/#180、#195、#248/#251/#266 等待核验事项的判断。
- 本批审核是资料交付，**无 ASM、地图、音频、存档、版本修改，无编译/模拟器运行，无 Commit/Push**。
