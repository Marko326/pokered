# RPP 参考分支移植台账：第 13 批（361～390）

> **CHS 基线**：已提交 `ROM-1.21.zip`，`CHS_Mod` HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：RPP 交接包 `individual/361～390`，核对 **30 笔实际提交，均有原始 patch**。
> **范围**：对照提交内容、涉及文件及 CHS 现有 ASM/验收历史，不进行新编译、模拟器运行或代码移植。分类仅是静态证据判断；不把 RPP 新引入系统产生的 Bug 误记成 CHS Bug。

## 本批关键结论

1. **#390 双针中毒/替身保护是最值得专项复核的战斗项**：CHS 原版 Twineedle 仍在设置两段攻击时把招式效果改为 `POISON_SIDE_EFFECT1`，整招结算处处理附加效果；参考分支采用每击检查承伤前替身状态，并避免整招尾部重复判毒。两边有实质差异，但还未由 CHS 模拟器复现，不能声称已确认严重错误。
2. **#380、#385 属于 RPP 连续钓鱼之后的修复**：CHS 没有该循环，不能为了一个不存在的闪烁入口更改现有钓鱼；#381 是独立新功能而非 Bug，并与 CHS 已有 SELECT 自行车快捷键冲突。#382～385 必须当作一条钓鱼功能链评估。
3. **#361～365、#379 金银/PureRGB 小图标仍依赖参考动态加载系统**：CHS 保留原版固定类别和双帧资源。可以按用户需求选做，但不能直接把 RPP 208 只映射覆盖 CHS，也不能单独复制某笔换位修复。
4. **#366～367 与 #377～378 是可选的真实功能差异**：前者是冲浪外观/飞行图标分流，后者是普通和飞行地图 START/SELECT 快捷定位。CHS 固定冲浪 `SeelSprite`、Fly 固定 `BirdSprite`，地图仅处理方向及 A/B；需要权衡原有游戏体验和汉化 UI。
5. **#368～372、#386～388 多数是扩展招式/动画**：#386 的金币动画可独立讨论，但其金银音效连接 Crystal Audio，CHS 没有该引擎。#388 将 Barrage 改为 Bullet Seed，会影响旧存档招式语义，应用户明确选择之前暂缓。
6. **#373～376 全为 RPP 自己的项目规划文档**，对 CHS 无需按功能移植；#389 多段受击轻震是视觉可选项，不是原版必修 Bug。

## 分类统计

- **依赖暂缓：17**（#361、#362、#363、#364、#365、#368、#369、#370、#371、#372、#379、#382、#383、#384、#385、#386、#387）。
- **当前不适用：5**（#373、#374、#375、#376、#380）。
- **待核验 Bug：1**（#390）。
- **需评估：7**（#366、#367、#377、#378、#381、#388、#389）。

## 361～390 逐笔移植评估

| 编号 / RPP Hash | 原始标题 | 参考改动 | CHS 状态 | CHS 源码/历史证据 | 是否移植及风险 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#361** `7c6d221201` | feat(ui): 完成第三批金版队伍小图标验收并统一映射表列对齐 | RPP 第三批 Gold 图标，新增 10 类，沿用动态加载和换位防闪框架 | **依赖暂缓** | CHS `src/data/pokemon/menu_icons.asm` 仍用 `nybble ICON_*` 固定类别；`src/engine/gfx/mon_icons.asm` 仍复用原图标映射，无参考的动态类别载入。 | 需先决定上一批 #358～359 动态图标框架，再选择具体类别；不是 CHS 显示 Bug。 | 高 / 高 |
| **#362** `9082e265e9` | feat(ui): 完成第四批金版队伍小图标验收，收口 ICO-5.62.60 | RPP 第四批新增 Jigglypuff、Diglett、Jellyfish、Fighter 四类图标 | **依赖暂缓** | CHS `menu_icons.asm` 的 Jigglypuff、Diglett 等仍为原版类别，未配置这些 Gold 动态资源。 | 与 #361 和 #358～359 为连续视觉扩展，不应拆开复制素材和指针。 | 高 / 高 |
| **#363** `df86a74c72` | feat(ui): 完成第五批队伍小图标细分类验收，收口 ICO-5.62.61 | RPP 第五批新增 Shell、Caterpillar、Moth、Blob 四类 Gold 双帧图标 | **依赖暂缓** | CHS 的 `menu_icons.asm`、`data/icon_pointers.asm` 没有对应类别；仍采用固定 4-bit 物种映射。 | 新图标功能而非旧 Bug；引入前需审查 VRAM/图块预算及中文队伍菜单。 | 中高 / 高 |
| **#364** `c19a949a76` | feat(ui): 完成第六批队伍小图标精选细分与两代素材去重验收 | RPP 第六批 Oddish/Fish 类别细分，并对金银原版图标逐帧去重 | **依赖暂缓** | CHS 未引入 RPP 前三批动态图标，也没有对应 `gfx/party_icon_imports` 全套素材。 | 仅可借鉴“按帧去重”检查方法；依赖动态加载框架，不直接移植。 | 高 / 高 |
| **#365** `b299b93176` | feat(ui): 按用户208只图鉴表完成队伍小图标最终定稿（ICO-5.62.63） | RPP 以 208 只物种表最终定稿 38 类小图标，加入 Fox、Humanshape | **依赖暂缓** | CHS 仍是原版 151 物种和紧凑映射，没有 RPP 的 208 只表或该类别配置。 | 数据体系不同；仅在用户确定扩展图标清单后逐只比对，不能用 RPP 208 表覆盖 CHS。 | 高 / 高 |
| **#366** `7fac6e3631` | feat(overworld): 完成皮卡丘／拉普拉斯／普通冲浪图像分流验收（SRF-5.62.64） | 按是否掌握 Surf 及实际选中的宝可梦，在 Pikachu、Lapras 和普通冲浪图像间切换 | **需评估** | CHS `src/home/overworld.asm:LoadSurfingPlayerSpriteGraphics` 直接载入 `SeelSprite`；`src/engine/items/item_effects.asm` 使用原版 Surf 状态，没有 `wSurfingLaprasFlag`。 | 这是可选的新地图视觉功能；需核对实际使用者、队伍菜单选中对象和进入/离开水面时素材，避免改变存档布局。 | 高 / 高 |
| **#367** `b738199c2e` | feat(overworld): 完成飞天宝可梦图标分流与性别主题色验收 | Fly 地图光标和飞行动画改用所选宝可梦的 Party 图标，并根据玩家性别着色 | **需评估** | CHS `src/engine/items/town_map.asm:LoadTownMap_Fly` 仍载入固定 `BirdSprite`；`src/engine/overworld/player_animations.asm` 仍走原版飞鸟动画；未找到 RPP 性别主题色路径。 | 新 UI/玩法表现，不属于 Fly 错误；依赖 Party 图标扩展并需另外定义 CHS 性别主题语义，暂不直接移植。 | 极高 / 高 |
| **#368** `b10f19faa1` | feat(animation): 移植 Ruby 风格高音双圆环 | Hyper Voice 的 Ruby 风格双圆环动画，专用 C2 网关和 Bank $38 渲染 | **依赖暂缓** | CHS `src/constants/move_constants.asm` 无 `HYPER_VOICE`，并无 RPP 的 `extended_move_animations` 网关。 | 没有招式及渲染器，不能当作 CHS 音频/动画 Bug；待决定新增招式后再评估。 | 高 / 高 |
| **#369** `a637809464` | feat(animation): 移植 Lovely Kiss 九锚点逐帧轨迹基础 | Lovely Kiss 九锚点逐帧浮动的专用 OAM helper | **依赖暂缓** | CHS `src/data/moves/animations.asm` 和 `src/engine/battle/animations.asm` 仍使用原版子动画，没有 RPP `lovely_kiss_motion.asm` 网关。 | 可选画面重制；依赖新增专用动画挂钩，不能作为 CHS 现有故障。 | 中高 / 高 |
| **#370** `9144efb7eb` | feat(animation): 优化 Lovely Kiss 逐帧节奏和波峰过渡 | 在 #369 helper 中加入逐帧 X/Y 双轴速度表 | **依赖暂缓** | CHS 未部署 #369 的专用轨迹表。 | 是 #369 的迭代，不能独立安装。 | 中 / 高 |
| **#371** `b177a89a0e` | feat(animation): 定版 Lovely Kiss 近大远小双波浪 | 定稿 Lovely Kiss 双波浪与九锚点高度曲线 | **依赖暂缓** | CHS 缺少前两笔的 Lovely Kiss 专用运动 helper。 | 依赖 #369～370；先确定是否需要动画重制。 | 中高 / 高 |
| **#372** `82c7025753` | feat(animation): 定版 Draining Kiss 双波浪与吸收衔接 | Draining Kiss 新招式爱心轨迹与吸收衔接 | **依赖暂缓** | CHS 招式表无 `DRAINING_KISS`，没有 RPP Fairy 属性/专用动画。 | 扩展招式和属性链，当前不移植，不构成 CHS Bug。 | 高 / 高 |
| **#373** `812e0df1c1` | docs(todo): 整理历史交接资料并补充缺失待办（第1轮） | 整理 RPP 第 1 轮历史交接及 TODO | **当前不适用** | 参考提交仅改 RPP 自己的 `TODO.md`，不包含通用 ASM 功能修复。 | 不能覆盖 CHS 当前 TODO；本台账记录参考来源即可。 | 低 / 高 |
| **#374** `c0cae12cf2` | docs(todo): 整理游戏功能现状、未完成事项与后续计划 | RPP 功能状态/未实现项目分类整理 | **当前不适用** | 仅维护 RPP 自身 TODO，对应的是其独有扩展系统和路线图。 | 不移植文档，不把 RPP TODO 当作 CHS 缺陷清单。 | 低 / 高 |
| **#375** `7f3a60fbc7` | docs(todo): 整理游戏功能验收状态与后续专项 | RPP 战斗/菜单/动画验收清单归档 | **当前不适用** | 仅 RPP 自身 `TODO.md` 与规划记录，非运行代码提交。 | 不移植；可借鉴将“已验收”和“待复现”分离的记录方法。 | 低 / 高 |
| **#376** `7a10edff6b` | docs(todo): 补充游戏功能验收结论与待办边界 | RPP 既有行为和未来待办边界整合 | **当前不适用** | 该笔仅整理 RPP 的 TODO，与其 MoveDex、扩展招式和脚本计划相关。 | 不作为 CHS 未完成功能；避免重复抄入 CHS TODO。 | 低 / 高 |
| **#377** `3467e268fc` | feat(fly): 定版 START／SELECT 快捷定位并归档实测结果 | Fly 地图 SELECT 回真新镇、START 跳最近恢复地点，长按去重 | **需评估** | CHS `src/engine/items/town_map.asm:LoadTownMap_Fly` 输入掩码只接受 A/B/上下键，未提供 START/SELECT 定位。 | 是真实缺少的快捷 UI 功能；先定义快捷键与现有选城交互、特殊恢复地点映射后单独开发，不能复制 RPP 的地图序号。 | 中高 / 高 |
| **#378** `a7ee79fa3f` | feat(map): 定版普通 Town Map 快捷定位并归档实测 | 普通 Town Map SELECT/START 跳真新镇/最近恢复点 | **需评估** | CHS `src/engine/items/town_map.asm:DisplayTownMap` 只处理 A/B/上下键；`wLastBlackoutMap` 存在，但地图浏览未连接此入口。 | 可与 #377 合并为一个用户选定的操作体验需求；注意普通地图与 Fly 地图的按键语义一致。 | 中 / 高 |
| **#379** `4ac823723a` | feat(icon): 新增 PureRGB HUMANOID_INSECT 双帧队伍图标并整理待测记录 | 新增 PureRGB HUMANOID_INSECT 双帧图标，给 Scyther、Pinsir、Kabutops | **依赖暂缓** | CHS 原版 `menu_icons.asm` 尚无 HUMANOID_INSECT 类别，也没有 RPP 的 39 类动态图集。 | 依赖 #358～365 全套图标方案；美术资源单独增加不是 Bug 修复。 | 中高 / 高 |
| **#380** `dc908787bf` | fix(fishing): 修复背包连续钓鱼的对话框闪烁 | 修正 RPP 连续钓鱼选择 Yes 后重复重绘导致的窗口闪烁 | **当前不适用** | CHS `src/engine/items/item_effects.asm` 的 `RodResponse` 单次结束，`FishingInit` 仍为一次性初始化；没有 `wRepeatFishingRod` 或连续 Yes 重试分支。 | 这是 RPP 后加连续投竿流程的衍生问题。CHS 没有同一触发路径，不直接移植；若未来做 #381，必须连同窗口复用审视。 | 中 / 高 |
| **#381** `82679d123d` | feat(fishing): 增加岸边 SELECT 钓鱼与连续投竿询问 | 陆地面向水面按 SELECT 使用最近钓竿，未咬钩可连续询问 | **需评估** | CHS `src/engine/overworld/bike_shortcut.asm:SelectBicycleShortcut` 将 SELECT 用作自行车快捷键；`item_effects.asm` 无最近钓竿状态和循环。 | 实际未实现的新 QoL。存在 SELECT 现有冲突，必须先设计岸边、骑车、野外交互优先级及旧存档兼容，不能照抄 RPP 的存档预留字节。 | 高 / 高 |
| **#382** `b1ca7e4706` | feat(fishing): 增加三位赠竿 NPC 的重复交谈教学 | 三位赠竿 NPC 增加重复钓鱼教学文本 | **依赖暂缓** | CHS 原文本位于 `src/text/VermilionOldRodHouse.asm` 等文件，没有 RPP 岸边 SELECT/连续重试机制。 | 内容明确依赖 #381；仅在决定新增该功能后适配中文文本、已领取标志，不应独立移植。 | 中 / 高 |
| **#383** `90843b3f5a` | feat(fishing): 支持冲浪 SELECT 钓鱼与背包换竿 | 冲浪时 SELECT/BAG 钓鱼、切竿和连续投竿 | **依赖暂缓** | CHS `src/engine/items/item_effects.asm:FishingInit` 对 `wWalkBikeSurfState = 2` 明确 `scf ; can't fish when surfing`。 | 是新增规则，且依赖 #381 的钓竿状态和用户的选择；涉及冲浪状态，需专题设计。 | 高 / 高 |
| **#384** `0e59dc0082` | feat(fishing): 增加冲浪上钩动画与 HM03 重复教学 | 冲浪上钩动画和 HM03 领取者重复教学 | **依赖暂缓** | CHS 冲浪钓鱼当前被阻止，且没有对应上钩动画分支。 | 依赖 #383 后才有实际作用；不能作为 CHS 现有钓鱼动画 Bug。 | 高 / 高 |
| **#385** `57ab81bc8d` | fix(fishing): 复用连续投竿文本窗口并移除重复初始化 | 复用 RPP 连续投竿询问文本窗口，修冗余初始化 | **依赖暂缓** | CHS 没有 `CheckRepeatFishingRod` 和可连续 Yes 的钓鱼窗口。 | 对 #381～383 新功能的收尾修复，若移植该链应一并考虑；现阶段不能单独使用。 | 中 / 高 |
| **#386** `7f90f54cea` | feat(anim): 定版聚宝功金币旋转投掷与金银版音效并清理后续待办 | Pay Day 金币旋转投掷新动画，接入 GSC 两段金钱音效 | **依赖暂缓** | CHS 有 `PAY_DAY` 原版招式，但没有 RPP `pay_day_animation.asm` 渲染和 `crysaudio/rbsfx.asm` 金银音效入口。 | 可选动画提升；音效部分明确 Crystal Audio 专属，不能直接套引擎；如仅做动画应独立设计资源/Bank。 | 高 / 高 |
| **#387** `d800b30af4` | feat(anim): 完善垃圾射击毒液汇聚与三次闪烁喷发 | Gunk Shot 毒液汇聚、闪烁与喷发的新版 renderer | **依赖暂缓** | CHS 没有 `GUNK_SHOT` 招式与 RPP 扩展动画入口。 | 未实现的扩展招式专属动画，不是 CHS 当前战斗 Bug。 | 高 / 高 |
| **#388** `60ec1a2667` | feat(anim): 将 Barrage 替换为种子机关枪并加入逐击投射动画 | 以 Bullet Seed 替换 Barrage 招式槽并添加逐击种子动画 | **需评估** | CHS `src/constants/move_constants.asm` 的 `$8C` 仍是 `BARRAGE`，`src/data/moves/moves.asm` 为普通多段攻击；无 Bullet Seed。 | 这会改变原版招式 ID 与存档中已学招式含义；必须用户先批准玩法替换，默认不移植。 | 极高 / 高 |
| **#389** `4da3adceb0` | feat(anim): 为敌方多段攻击加入逐击短横震反馈 | 敌方多段攻击每次实际命中时增加短横震反馈 | **需评估** | CHS `src/engine/battle/animations.asm:PlayApplyingAttackAnimation` 有通用受击震动，但没有 RPP 按敌方多段/每击独立选择轻震的 helper。 | 视觉 QoL，可独立考虑；应确认原版多段动作是否已经满意，避免在 DMG/CGB 增加不必要的帧等待。 | 中高 / 高 |
| **#390** `5d3fca8915` | fix(battle): 修复双针逐击中毒判定与替身保护 | Twineedle 每击独立中毒概率，保护替身击破当击并避免重复抽取 | **待核验 Bug** | CHS `src/engine/battle/effects.asm` 的 `TWINEEDLE_EFFECT` 在确定两击时改成 `POISON_SIDE_EFFECT1`；`core.asm:ExecutePlayerMoveDone` 的副作用仍在整招结算处处理，未见 RPP 每击保存替身状态/独立判毒 helper。 | 有真实 CHS 同类代码路径。优先用双针两击、首击破替身、双方/敌我方向及免疫场景复现，再决定最小修复；高回归风险，不直接复制 RPP core。 | 高 / 高 |

## 建议处理顺序（本批只评估，不实施）

| 顺序 | 编号 | 建议 |
|---|---|---|
| 优先专项核验 | **#390** | 双针两段攻击和 Substitute：比较每击中毒概率、首击打破替身、已中毒/毒属性免疫、敌我双方及提前击倒。先实测，再单独开发；不要将 RPP 新多段动画和战斗结算一起搬来。 |
| 可选的小型界面改进 | **#377～378** | START/SELECT 在 Fly 与普通地图的快捷定位。需要先审查 CHS 现有地图光标和按键优先级，特殊宝可梦中心不应被错误映射。 |
| 新功能专题 | **#381～385** | 先决定是否需要岸边/冲浪 SELECT 钓鱼，再整体设计连续投竿、窗口复用和提示文本。#380 仅在导入循环后才有直接意义。 |
| 可选外观 | **#366～367、#389** | 冲浪角色图像、飞行动画/地图图标、多段攻击轻震；分任务测试，不与复杂图标扩展一起上线。 |
| 高依赖暂缓 | **#361～365、#379、#368～372、#386～387** | Party 动态图标、扩展招式动画与 Crystal Audio 音效均有前置架构；不因参考分支已成功就适合 CHS。 |
| 玩法规则待用户决定 | **#388** | 替换 Barrage 为 Bullet Seed 会改变已有 Move ID 含义及存档习得技能，不按 Bug 修复处理。 |
| 不需移植 | **#373～376** | 只整理 RPP 自身 TODO/交接，不覆盖 CHS 的项目需求。 |

## 审核边界与下一批

- 前十二批已登记 **358 笔**真实参考提交（#072、#269 缺号）；本批 361～390 均存在，累计 **388 笔**。
- 下批按顺序是 **391～420**，尚未审查，不提前给出状态。
- 本批仅追加 `docs/RPP_REFERENCE_PORT_AUDIT_361-390.md` 并更新审查索引、`docs/CHS_ACCEPTANCE_HISTORY.md`、`TODO.md`；**不修改游戏 src、版本号、ROM/Bank、存档，不编译、运行或 Commit/Push**。
