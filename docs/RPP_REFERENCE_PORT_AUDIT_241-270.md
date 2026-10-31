# RPP 参考分支移植台账：第 09 批（241～270）

> **CHS 正式对照**：`ROM-1.21.zip` / `CHS_Mod` 已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：交接资料中的 RPP `individual/241～270`，实际 29 笔；**#269 缺号**，不虚构 Hash 或补丁。
> **范围**：逐笔核对参考标题、原始 Hash、修改文件与说明，并对照 CHS 源码中的对应函数/数据。只做静态移植评估，**不是运行测试或确认所有 Bug 已复现**。
> **本批仅文档**：不改 ASM、音频、WRAM/SRAM、游戏版本号 `ROM-1.21`；无游戏编译、Commit 或 Push。

## 核心结论

1. **#241～245 大型数据压缩**：参考面向 208 物种、英文 packed_names、扩展技能/音频/训练师数据。CHS 当前有两套中英文物种名称及不同的物种映射和原有音频引擎，**不能直接移植**。特别是 #242 的 `PokedexOrder` 恒等映射前提在 CHS 不成立，移除会出错。
2. **#248 四方向关卡推回状态、#251 游戏厅代币上限、#266 濒死后结算残余伤害**：都找到 CHS 对应源码路径，标为 **待核验 Bug**；证据是静态路径或参考指出的边界，不代表 CHS 运行时已复现。
3. **#255/#258/#260/#263/#267 是可考虑的代码去重**：分别覆盖地图脚本包装、训练师文本入口、训练师地图脚本、文本尾部与 Yes/No 询问。收益主要在 ROMX，或需额外 HOME helper；必须按 CHS 的中文文本、Bank 结构重算，不能按参考收益照抄。
4. **#256～258 是有关联的训练师头/脚本链**：参考 #257 修的是 #256 之后丢失的败北文本指针。CHS 目前保留 12 B 训练师头与第二结束文本指针，**#257 当前不适用**。
5. **#262 的 859 warp 数据重构**虽可能节约较多 ROMX，但波及大批地图和传送数据；CHS 已有可用的 ROM0 余量，不宜仅为约 30 B HOME 收益承担大范围回归。
6. **#244、#270 为 Crystal Audio 专属**，#265 是参考新增的扩展招式动画引起的回归，#268 是删除 RPP 自己新增的 Wonder Trade。这些不能当作 CHS 缺失修复。
7. **#246/#247/#250/#252～254 会改变原版玩法/演出**：固定馆主谜题、删自行车店高价菜单、简化金牙领取、移除向导/捕捉演示、化石即时复活，属维护者决定的独立 QoL，不是“待修 Bug”。

## 状态统计

- **依赖暂缓：5**（#241、#243、#256、#258、#262）。
- **当前不适用：7**（#242、#244、#245、#257、#265、#268、#270）。
- **待核验 Bug：3**（#248、#251、#266）。
- **缺号：1**（#269）。
- **需评估：14**（#246、#247、#249、#250、#252、#253、#254、#255、#259、#260、#261、#263、#264、#267）。

## 241～270 逐笔移植评估

| 编号 / Hash | RPP 原始提交标题 | 改动核心 | CHS 状态 | CHS 代码证据或差异 | 移植建议 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#241** `7ac76eea72` | refactor(names): 压缩精灵名称并保留原有查找契约 | 208 种宝可梦英文名称压缩 | **依赖暂缓** | CHS `src/home/names.asm:GetMonName` 根据 `wENGNameMark` 选择 MonsterNames/MonsterNames2 两张定长名称表，并以 `NAME_LENGTH - 1` 访问；还有旧英文存档的名称兼容需求。 | 不能照搬 RPP 的单套 packed_names；先解决中英文默认名称及旧存档语义，再评估两套名称压缩与 Bank 解码时序。 | 极高 / 高 |
| **#242** `09b2f68f13` | refactor(mapping): 精简图鉴与配色映射并保留独立扩展能力 | 图鉴 ID 恒等表与颜色中间表精简 | **当前不适用** | CHS `src/data/pokemon/dex_order.asm:PokedexOrder` 前几项为 RHYDON、KANGASKHAN、NIDORAN_M 等内部物种顺序，非图鉴编号恒等映射；`src/engine/menus/pokedex.asm` 使用双向转换。 | RPP 208 项恒等映射的零表优化前提不成立；不得移除 CHS PokedexOrder。调色映射可另立题做独立等价性检查。 | 高 / 高 |
| **#243** `2e44c350d3` | refactor(learnset): 压缩升级技能数据并保留独立扩展能力 | 升级技能学习表差分压缩 | **依赖暂缓** | CHS `src/data/pokemon/evos_moves.asm` 仍是原版级数/招式格式，`src/engine/pokemon/evos_moves.asm` 读取该结构；RPP 压缩面向 208 物种、3154 条技能及 Move Reminder。 | 属于 ROMX 数据优化，不是 ROM0 优化；如未来真正缺空间，先导出 CHS 全 learnset 做 round-trip，再分别改升级/初始技能/饲育屋读取，不能套 RPP 208 表。 | 高 / 高 |
| **#244** `6529e674ca` | refactor(cries): 压缩精灵叫声头并保留完整参数扩展能力 | Cry Header 压缩及 sparse override | **当前不适用** | RPP 修改 `crysaudio/cry_header_decoder.asm` 等 Crystal Audio 专用结构，保留 Gold/Silver 扩展参数；CHS `src/home/pokemon.asm:GetCryData` 和 `src/data/pokemon/cries.asm` 仍按原引擎读取。 | 当前不适用；即便想压缩叫声数据，也必须面向 CHS 原引擎独立设计，不能移植 Crystal Audio 解码器。 | 高 / 高 |
| **#245** `4604fbeca6` | refactor(trainers): 压缩训练师名称并保留独立队伍扩展能力 | Normal/Hard 训练师个人名称压缩 | **当前不适用** | RPP 把 792 个 Trainer Party 的个人名压缩；CHS `src/data/trainers/parties.asm` 为等级/物种队伍，训练师类别名称在 `src/data/trainers/names.asm` 单独读取，未见 RPP 双套 Hard parties。 | 源数据结构和汉化名称接口不一样；不能把 RPP 的 party-name 解码作为 CHS 缺失修复。 | 高 / 高 |
| **#246** `ff902a940d` | refactor(gym): 固定枯叶道馆双锁并精简垃圾桶逻辑 | 枯叶道馆垃圾桶双锁固定位置 | **需评估** | CHS `src/engine/events/hidden_objects/vermilion_gym_trash.asm:GymTrashScript` 仍使用 Random 和 GymTrashCans，保留原版随机谜题；参考固定 7→10 并删随机代码。 | 这改变谜题规则，不是原版 Bug 修复；如用户想固定路线可单独做，并验证存档/开锁/失败重置，否则保持原版。 | 中 / 高 |
| **#247** `5874323098` | refactor(bike): 精简自行车店不可达购买流程 | 自行车店不可达的高价购买菜单 | **需评估** | CHS `src/scripts/BikeShop.asm` 无 Voucher 时仍绘制 BICYCLE/CANCEL 与 ¥1000000，随后通常进入买不起分支。 | 低风险 QoL 候选：可精简不可达菜单，但保留兑换券、背包满及已有自行车的全部分支；用户决定是否改变原版交互。 | 低中 / 高 |
| **#248** `539ca1a8ee` | refactor(saffron): 合并饮料关卡逻辑并修正推回状态 | 四个金黄市关卡的饮料拦截和推回状态 | **待核验 Bug** | CHS `src/scripts/Route5Gate.asm` 与 `Route6Gate.asm` 等仍分别存取 `wRoute5GateCurScript` / 各 Gate 脚本状态；参考指出 Route6/7/8 手动对话误用 Route5 pushback。 | CHS 存在同类脚本结构，优先按四方向的手动对话、自动拦截及饮料取得前后复测；只有确认错位才做最小推回状态修复。 | 中 / 中高 |
| **#249** `2a4fd51f6a` | refactor(elite4): 合并四天王房间入口自动行走逻辑 | 四天王房间进入与拦回脚本去重 | **需评估** | CHS `src/scripts/LoreleisRoom.asm`、`BrunosRoom.asm`、`AgathasRoom.asm` 保留独立自动走路与事件状态机。 | 可减少 ROMX 重复，但触碰四天王入口/逃离和存档进度；无空间需求可暂缓，不把重构当 Bug。 | 中高 / 高 |
| **#250** `da7a81447d` | refactor(hm4): 精简金牙兑换 HM04 中间状态 | 金牙换 HM04 的奖励状态简化 | **需评估** | CHS `src/scripts/WardensHouse.asm` 仍使用原版 Gold Teeth / HM04 流程及事件；参考删除中间状态与背包满重试分支。 | 不同于纯优化，可能改变背包满及旧存档补领的行为。除非明确需要简化流程，否则保留原版；改时必须验证物品原子交换。 | 中高 / 中 |
| **#251** `b39374921c` | refactor(gamecorner): 合并免费代币赠送逻辑并修正上限判断 | 游戏厅免费代币 NPC 的上限判断 | **待核验 Bug** | CHS `src/scripts/GameCorner.asm` 保留多个独立赠币 NPC 文本和领取逻辑；参考明确修复第三个 20 Coin NPC 接近上限时的边界判断。 | 优先针对第三个赠币 NPC 的 9999、9980、9990 等临界值与重复领取做最小复测；未验证前不宣称 CHS 已有同样 Bug。 | 中 / 中高 |
| **#252** `f25f108984` | refactor(pewter): 精简博物馆向导并保留道馆带路 | 深灰市博物馆向导自动带路精简 | **需评估** | CHS `src/scripts/PewterCity.asm` 仍有向导/道馆带路与 `wNPCMovementScript*` 状态；参考移除博物馆带路仅留道馆路线。 | 行为删减而非 Bug 修复；除非希望减少导览和代码体积，否则不建议改变现有事件体验。 | 中 / 高 |
| **#253** `13790b8741` | refactor(tutorial): 精简老人抓捕教学并移除专用伪战斗流程 | 常青市老人捕捉教学去伪战斗 | **需评估** | CHS `src/scripts/ViridianCity.asm` 仍使用 `BATTLE_TYPE_OLD_MAN` 并配合教学战逻辑；参考直接改成文字说明。 | 这会删除教学演示，涉及大量战斗/背包特殊路径。可以作为专门简化项目评估，但不是安全的小规模空间迁移。 | 高 / 高 |
| **#254** `222cb08740` | refactor(fossil): 简化化石复活并移除实验室等待状态 | 红莲岛化石即时复活 | **需评估** | CHS `src/engine/events/cinnabar_lab.asm:GiveFossilToCinnabarLab` 在收化石后设置 `EVENT_GAVE_FOSSIL_TO_LAB`、`EVENT_LAB_STILL_REVIVING_FOSSIL`，`src/scripts/CinnabarLabFossilRoom.asm` 保留等待后取回。 | 即时复活是新 QoL/玩法规则，须保证队伍/盒子满、旧等待中存档、背包消耗；暂不作为 Bug 套用。 | 高 / 高 |
| **#255** `05e82b173c` | refactor(maps): 移除冗余地图脚本包装并直接使用共享文本框逻辑 | 85 份无副作用地图脚本包装去重 | **需评估** | CHS `src/scripts/BikeShop.asm:BikeShop_Script` 与 `CinnabarLabFossilRoom.asm` 等仍存在只 `jp EnableAutoTextBoxDrawing` 的入口；参考改为直接指向 ROM0 公共例程，预计总减少约 270 B。 | 是有实际对应的 ROMX 清理候选，但改动地图数多，先自动识别仅有独立跳转的一行包装器、核对 link/map bank 后分批做，避免误删特殊地图脚本。 | 中高 / 高 |
| **#256** `3a5a73a626` | refactor(trainers): 压缩训练师头并移除重复结束文本指针 | 训练师头 12B→10B 压缩 | **依赖暂缓** | CHS `src/home/trainers.asm:ReadTrainerHeaderInfo` 仍支持偏移 `$a` 的第二结束文本指针，`TalkToTrainer` 分别读 `$a`/`$8`，训练师各地图仍按 12B。 | 可能释放 ROMX 和少量 ROM0，但要求全部训练师头、游标步长、战斗结算路径同时迁移；强耦合且有 #257 后续修复，先暂缓。 | 高 / 高 |
| **#257** `1e993752d2` | fix(trainers): 初始化普通训练师败北结束文本指针 | 压缩训练师头后初始化 lose 文本 | **当前不适用** | RPP #257 紧跟 #256，修正其移除第二结束指针后 lose 文本未初始化。CHS 尚未套 #256，`src/home/trainers.asm:TalkToTrainer` 仍显式读 offset `$a` 并传入 `SaveEndBattleTextPointers`。 | 这是参考重构后补丁，当前 CHS 不具有同一结构前提；将来若做 #256 必须一并纳入，不单独移植。 | 中 / 高 |
| **#258** `8b69209605` | refactor(trainers): 合并普通训练师文本入口 | 318 处普通训练师 TX_ASM 包装合并 | **依赖暂缓** | CHS `src/scripts/Route12.asm` 等仍有训练师文本包装入口；参考为 RPP 宏系统新增 TX_TRAINER 并清理 318 处，约省 2116 B ROMX。 | 作为大批量 ROMX 优化可以研究，但须先确认 CHS TX_ASM/CHS 字体脚本契约，不能套原 RPP 带 #256 头格式的脚本。 | 高 / 中高 |
| **#259** `9eb200b133` | maintenance(events): 同步事件与内存地址备注 | 事件位与 WRAM/SRAM 地址注释同步 | **需评估** | CHS `src/constants/event_constants.asm`、`src/ram/wram.asm` 保留地址和事件注释；RPP 修改的只是其自身内存布局备注。 | 仅参考其“构建后据真实符号生成/核对注释”的方法；不能把 RPP 的绝对地址注释覆写 CHS。 | 低 / 高 |
| **#260** `c79eb8ecfd` | refactor(trainers): 合并训练师地图脚本分派逻辑 | 68 张训练师地图脚本分派去重 | **需评估** | CHS 多个 `src/scripts/*` 保留同类 TrainerHeaderScript/地图状态分派逻辑；RPP 把 40 份标准状态表合并至同 Bank 共享表，约省 660 B ROMX。 | 可考虑作为空间专项，但要按 CHS 的真实 BANK/布局分组，避免错误跨 Bank 跳转与地图状态写回改变。 | 中高 / 中高 |
| **#261** `605119fc93` | refactor(silph): 合并 Silph Co. Card Key 门处理逻辑 | Silph Co. Card Key 20 个门数据驱动 | **需评估** | CHS `src/engine/events/card_key.asm` 仍按前方 tile 判断，并依赖 `src/data/events/card_key_coords.asm` / map 表。 | 可能减少多个楼层重复代码，需核对每门 block、事件位与历史存档；属于 ROMX 优化，暂不优先。 | 高 / 高 |
| **#262** `99d158e3ec` | refactor(warps): 移除重复的地图传送目标位置数据 | 普通 warp 的 EVENT_DISP 数据移除 | **依赖暂缓** | CHS `src/home/overworld.asm:LoadDestinationWarpPosition` 仍使用 `wPredefParentBank` 与 4 字节位置复制；RPP 对 859 个 warp 重建目的地位置，约省 3423 B ROMX、30 B ROM0。 | 大型地图格式迁移，涉及 236 文件、传送/洞窟/特殊 warp。ROM-1.21 已从 ROM0 迁地图指针表，暂无必要为 ~30 B HOME 冒这么大的回归风险。 | 极高 / 高 |
| **#263** `218595bd23` | refactor(text): 合并 PrintText 与 TextScriptEnd 公共尾部 | PrintText + TextScriptEnd 公共尾部 | **需评估** | CHS 各地图仍有 `call PrintText` 后 `jp TextScriptEnd` 的脚本路径；RPP 将 91 处尾部合并，约省 267 B，公共 HOME helper 增 6 B。 | 独立文本去重候选；应先用脚本精确匹配无副作用的相邻尾部，不应跨中文文本 Bank/异步显示/栈路径盲目重写。 | 中 / 中高 |
| **#264** `a23938475c` | refactor(gyms): 合并馆主徽章与 TM 奖励流程 | 八馆主徽章和 TM 奖励状态合并 | **需评估** | CHS `src/scripts/*Gym.asm` 保留分馆主奖励/事件/背包满流程；RPP 用统一表重构，约省 181 B ROMX。 | 属于剧情与旧事件位高敏感改造；若做必须覆盖每馆徽章、TM 领取、背包满及补领，节省不大，暂不优先。 | 高 / 中高 |
| **#265** `32e79e2615` | fix(battle): 修复技能动画破坏中毒文本与回血显示 | 扩展招式动画破坏中毒文本与回血缓存 | **当前不适用** | RPP 依赖 `data/extended_move_animations.asm` 和自定义 wBuffer recipe 后覆盖 HP-bar 状态；CHS `src/engine/battle/effects.asm:HealEffect` 目前经原本 `jpfar HealEffect_` 路径，未见同一扩展动画 recipe。 | 不能把 RPP 新动画带来的显示 Bug 当作 CHS 当前问题；若独立复现中毒或回血异常，再按 CHS HL/HP 状态调用链处理。 | 中 / 高 |
| **#266** `ca1d40d9e4` | fix(battle): 阻止已濒死行动者继续结算回合末残余伤害 | 已濒死行动者被继续结算中毒烧伤寄生 | **待核验 Bug** | CHS `src/engine/battle/core.asm:HandlePoisonBurnLeechSeed` 选择双方 HP 指针后，直接检查状态位；没有参考新增的入场 16-bit HP==0 早退。 | 有实质代码差异，优先用反伤/自伤击倒且同回合中毒/烧伤/寄生的场景验证；确认后独立最小修补，不改 HP 动画。 | 中 / 高 |
| **#267** `c8b2de5785` | refactor(text): 合并 PrintText 与 YesNoChoice 公共询问流程 | PrintText + YesNoChoice 公共询问去重 | **需评估** | CHS 多个文本询问场景仍 `call PrintText`、`call YesNoChoice` 并检查 `wCurrentMenuItem`；ROM-1.20A 已把 YesNo 主体放入 Bank `$2D`。 | 可做小范围批量去重，注意返回 A/Z Flags、中文文本框/ROMX Bank 恢复及 ROM0 helper 额外占用；不盲目套 RPP 的 42 处替换。 | 中 / 中高 |
| **#268** `698a509bef` | refactor(wondertrade): 移除 Wonder Trade 功能及专用资源 | 移除参考 Wonder Trade 及其图块/资源 | **当前不适用** | CHS `src/` 未发现参考 `engine/wonder_trade.asm` 和专用 Wonder Trade 终端；RPP 是删除自己此前新增的系统。 | CHS 无此待删功能，不能把参考清理当作 CHS 待移植代码。 | 低 / 高 |
| **#269** — | **缺号：交接包没有对应原始补丁** | 无法确认改动 | **缺号** | 无来源可供核对 | 保留编号，不补造内容/Hash | — |
| **#270** `68c9d6f848` | refactor(audio): 恢复有效 custom 曲目并预留独立音乐选择功能 | 恢复 Crystal Audio custom 音乐素材 | **当前不适用** | RPP 重新加入 `crysaudio/music/custom` 下 11 首自定义曲目并预留音乐选择；CHS 使用 `src/audio/music/`、既有音频引擎，未采用 Crystal Audio。 | 不移植 Crystal Audio 资源或链接配置；如要加自定义曲目，应另行设计 CHS 音频格式、版权和空间预算。 | 高 / 高 |

## 建议的实施优先级（本批只评估，不动源码）

| 优先级 | 编号 | 具体后续动作 | 为什么 |
|---|---|---|---|
| P1 待复现 | **#266** | 备份存档，构造反伤/自伤导致 0 HP、同时有中毒/烧伤/寄生种子的回合；检查是否继续结算，若成立再设计最小提前退出 | CHS 同一路径缺少 16-bit HP 零值前置检查 |
| P1 待复现 | **#248、#251** | 四个金黄关卡的手动/自动推回状态、游戏厅三个赠币 NPC 近上限的表现 | 具体边界差异，较容易独立复测 |
| P2 低风险优化 | **#247、#255** | 用户确认是否简化自行车购买菜单；若需要 ROMX 空间，先脚本识别无副作用的一行地图脚本包装器 | 前者改变原版行为，后者要谨防大范围映射误替换 |
| P2 空间优化 | **#263、#267** | 按 CHS 当前中文文本/Bank 逐个确认等价尾部和 YesNoChoice 返回 A、Z 状态，分小批测试 | 可减少重复代码，但 ROM0 helper 会占据 HOME，收益以新 MAP 为准 |
| P3 大型数据优化 | **#243、#256～258、#260～262** | 仅当目标 Bank 实际吃紧时再设专题；先做原数据 round-trip 和真实空闲报告 | 高耦合、批量文件修改、地图与存档风险 |
| 暂不移植 | **#241、#242、#244、#245、#257、#265、#268、#270** | 保留参考知识，不在当前 CHS 上套用 | 汉化双名称、208 物种差异、Crystal Audio、RPP 增量功能后续修复/撤销 |
| 玩家自行决定 | **#246、#249、#250、#252～254、#264** | 只有确实想改剧情和操作行为时立项 | 不属于必须修复的功能 Bug |

## 后续审核边界与依赖

- 此前已审核 `001～240`（含 #072 缺号），本批审核 `241～270`（#269 缺号）；本次**不会覆盖前八批判断**。
- RPP #257 依赖 #256，#265 依赖其扩展招式动画系统，#270 依赖 Crystal Audio；这些都要在未来迭代中维持“参考修复不一定适用 CHS”的原则。
- 若今后移植任何游戏功能，必须另建功能/测试补丁，更新对应验收历史，且不擅自改变 `ROM-1.21` 正式版本号。
- 本批评估不代表用户已选择实现任何项目，不强迫重测既有功能。
