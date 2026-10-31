# RPP 参考分支移植台账：第 15 批（421～444，最后一批）

> **CHS 基线**：已提交 `ROM-1.21.zip` / `CHS_Mod` HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：RPP 交接包内 `individual/421～444` 共 **24 笔实际独立补丁**，本批无缺号。
> **审核范围**：逐笔阅读参考提交说明与补丁，并与 CHS 当前源码、既有验收记录及前 14 批台账静态对照。没有编译新 ROM、模拟器复现或修改游戏代码。
> **原则**：RPP 的 Crystal Audio、扩展招式、地区形态及其二次修复不是 CHS 现有 Bug；同一提交混杂新增功能与原版战斗问题时必须拆分评估。

## 本批结论

1. **#421～433** 是 40 招扩容身份、Party/PC sidecar、学习/回忆、敌方来源、AI 和跨 Bank 包装器的连续收口。CHS 没有第二招式身份层，**整组暂缓**。参考 #430 的三拳状态异常来自它自己的跨 Bank 新包装器，不代表 CHS 的三拳坏了。
2. **#434～438** 是 Play Rough、Power Gem 等新增招式动画和追加效果；#435 包含 `crysaudio` 入口。CHS 没有这些招式，也没有 Crystal Audio，**不能移植音频引擎专属部分**。
3. **#439** 是 Dynamic Spark 的新战斗规则，不是原版 Bug。CHS 甚至没有 Spark，除非维护者明确要求改变招式体系，否则不做。
4. **#440** 中 RPP Dynamic Spark 部分不适用，但 **Counter 依据共享 `wDamage` 与对方“当前选择招式”判断**的原版风险，在 CHS `HandleCounterMove` 注释中有直接证据。建议专项复现并设计 CHS 自己的修复，不全量移植。
5. **#441～442** 混有能力值 1～999 限幅、战斗数据除数保护、Counter 失败提示与 Ghost 免疫等。CHS 已有部分夹值，参考的 Ghost/伤害属性规则未必相同。先确认哪种零除或上限边界可达，再改最小一段。
6. **#443** 的混乱自伤、Jump Kick 落空反伤与 Substitute/多段击破路径，在 CHS 源码里确实具有相应分流；自伤指针及敌方替身误承伤值得优先核验。不要把文字提示优化和 HP 结算修复混为一个问题。
7. **#444** 只应视作测试工程设计参考。它的可选构建方案可以考虑，但 NPC、地图、WRAM、测试 Hooks **绝不应直接并入正式 ROM**。

## 分类数量

- **依赖暂缓：18**（#421、#422、#423、#424、#425、#426、#427、#428、#429、#430、#431、#432、#433、#434、#435、#436、#437、#438）。
- **待核验 Bug：3**（#440、#442、#443）。
- **部分实现：1**（#441）。
- **需评估：2**（#439、#444）。

## 421～444 逐笔评估

| 编号 / RPP Hash | 原始标题 | 参考改动摘要 | CHS 状态 | CHS 源码证据 / 差异 | 移植建议 | 复杂度 / 判断置信度 |
|---|---|---|---|---|---|---|
| **#421** `60b3970b51` | feat(move): 收口四十招独立扩容并移除临时升级测试分配 | 将 RPP 第二招式表收口为40个扩展身份 $0100～$0127；清理为测试临时发放的升级学习映射 | **依赖暂缓** | CHS `src/constants/move_constants.asm` 和 `src/data/moves/moves.asm` 仍使用原版单字节 Move ID；不存在40招第二表/sidecar | 这是 #418～420 的正式收口，不是 CHS 遗漏修复；涉及招式身份/旧存档，暂缓 | 极高 / 高 |
| **#422** `23858fc8b5` | fix(move): 收口扩展技能身份隔离与普通升级回归修复 | 扩展身份同低字节防碰撞、SELECT 换位、Struggle 清除临时标志及 Party sidecar 高字节 | **依赖暂缓** | CHS `src/engine/battle/core.asm` 没有 `wExtendedBattleMoveFlags`、扩展四槽标志或额外 ordinal | RPP 扩容系统后续兼容修复；CHS 没有相同身份冲突，不能直接移植 | 极高 / 高 |
| **#423** `f54c194013` | refactor(move): 收口地区形态身份隔离与普通／地区统一学招入口 | 把普通与地区形态升级学习汇入统一入口，携带扩展序号并处理回忆候选 | **依赖暂缓** | CHS `src/engine/pokemon/evos_moves.asm` 仍处理原始学习表；没有地区形态学习表/完整扩展身份协议 | 依赖地区形态与第二招式表，涉及学习/回忆/旧档；暂缓 | 极高 / 高 |
| **#424** `e56805e96a` | fix(move): 收口 TM/HM／教学师普通招式的扩展身份判重 | TM/HM 与教学师判重改为同时检查普通招式 ID 和扩展身份位 | **依赖暂缓** | CHS `src/engine/items/tmhm.asm:CheckIfMoveIsKnown` 仅需对现有单字节招式判断；没有扩展同低字节碰撞 | 仅对 #418～423 扩容身份系统必要；不把它混同此前 #240 的普通 TM 表索引问题 | 高 / 高 |
| **#425** `449717df44` | fix(move): 收口玩家变身后的扩展招式身份同步 | 变身复制普通招式后清除临时扩展身份，并防止升级写回污染变身临时槽 | **依赖暂缓** | CHS 有 Transform，但没有扩展 ordinal、Party sidecar；普通 Transform 另有独立待核验项 #336 | 扩展招式特有的身份残留修复不适用；不能掩盖 #336 独立问题 | 高 / 高 |
| **#426** `1d1628fe05` | refactor(move): 单独收口 182B 当前出招身份公共加载及 098 槽位修正 | 按当前行动槽位同时读取普通技能和扩展序号；修复随机不听话出招下扩展身份和 PP 索引 | **依赖暂缓** | CHS 战斗选择仍使用原版 `wPlayerMoveListIndex` 与四个单字节技能；无 EXT 身份半字节掩码 | 只在 RPP 扩容系统前提下成立，直接改共用装载会破坏 CHS 原版行为 | 极高 / 高 |
| **#427** `ebbac18868` | fix(move): 183 为敌我扩展招建立完整身份伤害分类基础 | 为扩展招式建立独立的物理/特殊分类及共用 Bank 入口 | **依赖暂缓** | CHS 当前分类仍按一代招式类型处理，未引入第二技能表与40项 EXT 分类 | 牵涉战斗伤害类别规则而非纯修复；未经批准不引入 | 极高 / 高 |
| **#428** `ea163ba9a4` | fix(move): 收口双向派生招式扩展身份传递 | Mimic、Mirror Move、Metronome 复制/抽取扩展身份，保持战斗临时槽与永久技能分离 | **依赖暂缓** | CHS 有三个原版招式，但没有 EXT 40 招身份来源和独立存储 | CHS 的原版 Mimic/Mirror Move Bug 如需修复应另行验证；此补丁依赖扩容系统 | 极高 / 高 |
| **#429** `60e8832b8b` | fix(move): 收口敌方扩展招式身份记录与原生来源 | 敌方 MoveDex 登记扩展身份，增加敌方野生/训练家原生扩展招式来源及 PP 装载 | **依赖暂缓** | CHS 未有 RPP MoveDex/EXT 来源匹配器；普通敌方招式按原版物种/训练师来源初始化 | RPP 扩容身份与 MoveDex 的配套开发；目前不移植 | 极高 / 高 |
| **#430** `af8beef2e5` | fix(move): 收口共用追加异常状态跨 Bank 传参与三拳验收 | 为 RollStatusSideEffect 跨 Bank 包装器保留 A 中效果编号，修复三拳附加异常状态 | **依赖暂缓** | CHS 无 RPP `RollStatusSideEffectFar`、扩展技能 Bank 网关；普通三拳效果路径需按自身引擎检查 | 是参考跨 Bank 新网关引发的参数覆盖；不能据此宣称 CHS 三拳有 Bug | 高 / 高 |
| **#431** `8f9265ccba` | fix(move): 收口扩展招式会心与飞天身份撞号专项验收 | 扩展技能跳过普通高会心名单、避免 EXT ordinal 与 Gust/Fly/Dig 规则误碰撞 | **依赖暂缓** | CHS 原本单字节技能 ID 不会把 EXT02 与 Karate Chop 视为同一招 | 扩展身份碰撞修复，无需移植；若想调整 Fly/Dig 规则应另起需求 | 高 / 高 |
| **#432** `5fccba7371` | fix(move): 收口训练师 AI 扩展候选基础识别与评分修复 | 训练师 AI 针对扩展技能身份读取候选数据、修 A 寄存器与倍率常量比较 | **依赖暂缓** | CHS 训练师 AI 无 EXT sidecar 候选输入，只有普通招式字段 | RPP 扩容 AI 衍生缺陷，当前不适用；不要覆盖 CHS 当前 AI | 极高 / 高 |
| **#433** `103679501f` | feat(move): 支持扩展招式按等级学习与回忆 | 普通物种升级表与回忆师可配置扩展招式，并按完整身份去重 | **依赖暂缓** | CHS 没有 #421 的40招和回忆师扩展列表，常规升级学习为原版数据 | 与 #421～432 一组大型系统，旧存档和汉化招名风险极高 | 极高 / 高 |
| **#434** `73aad942dd` | feat(anim): 为扩展招式嬉闹加入专属战斗动画 | 为 EXT02 Play Rough 增加双方专属突进、星星、爱心等复合动画 | **依赖暂缓** | CHS `src/constants/move_constants.asm` 无 PLAY_ROUGH、`src/engine/battle/animations.asm` 无该专用渲染 | 扩展技能专属视觉功能，不是 CHS 原版画面 Bug；暂缓 | 高 / 高 |
| **#435** `550e6cd5ce` | fix(anim): 嬉闹复用原版战斗音效 | Play Rough 动画改用 Throw Ball/Bone Club 等参考现有 SFX 播放入口 | **依赖暂缓** | CHS 无 #434 嬉闹动画；RPP 的音效桥接含 `crysaudio/rbsfx.asm` 路径 | 不能为了参考动画引入 Crystal Audio；如未来单独做动画须复用 CHS 自己的音效系统 | 高 / 高 |
| **#436** `52ab845da2` | feat(anim): 将嬉闹主体调整为 Gunk Shot 3/4 速度 | 把 Play Rough 动画主体由73逻辑帧调整为98 VBlank 并处理音效时序 | **依赖暂缓** | CHS 没有 #434/435 的动画主体和 RPP 时间轴 | 依赖前两笔才有意义；不是 CHS 现有动画节奏 Bug | 中高 / 高 |
| **#437** `b795cba9fb` | feat(move): 嬉闹增加两项独立 10% 追加效果 | 给 Play Rough 追加两个彼此独立的10%降攻、混乱副作用 | **依赖暂缓** | CHS 不存在 Play Rough 和对应扩展效果编号 | 新增战斗规则，非 Bug 修复；须玩家明确批准再讨论 | 高 / 高 |
| **#438** `6f448d6915` | feat(anim): 移植 Power Gem 八石头动画并完成双向轨迹验收 | 移植 Power Gem 八石头轨迹、双方发射与素材/SFX | **依赖暂缓** | CHS 无 POWER_GEM 的扩招身份，参考资源来自 Polished Crystal 和 RPP 扩展动画 | 复杂素材与动画系统；当前不适用，不应改 CHS 现有 Rock Throw | 高 / 高 |
| **#439** `66c9b058aa` | feat(move): 新增 Dynamic 分类并让 Spark 动态选择伤害类别 | 新增 Dynamic 伤害类别，Spark 根据 Attack/Special 实时判断物理或特殊 | **需评估** | CHS `src/constants/move_constants.asm` 无 SPARK；战斗伤害分类为原版类型判定，不含 Dynamic 类 | 这是改招式/战斗规则的新功能，不是原版 Bug；暂不移植，须用户先确认玩法目标 | 极高 / 高 |
| **#440** `8030b0f2f1` | fix(battle): 收口 Dynamic Spark、Counter 真实受击和异常状态能力重算 | 混合 Dynamic Spark 修复与 Counter 使用当回合实际本体 HP 受击记录、不再依赖共享 wDamage | **待核验 Bug** | CHS `src/engine/battle/core.asm:HandleCounterMove` 仍读取对方选中招式及共享 `wDamage`，源码注释已警告菜单选招/交换及双方共用伤害引发判定异常 | **可独立研究 Counter**：先复现换人、上回合伤害、替身、多段攻击、反伤场景，设计不依赖 Dynamic Spark 的小改动；RPP 整份补丁禁止直接套 | 高 / 高 |
| **#441** `eba1a803a7` | fix(battle): 完善能力等级限幅与 Counter 失败提示 | 区分 Counter 条件失败与真正未命中；能力等级阶段达到+6/-6、结果 1～999 限幅需分开处理 | **部分实现** | CHS `src/engine/battle/core.asm:CalculateModifiedStat` 已有 `MAX_STAT_VALUE` 999 与最小1的限幅，但战斗实时 StatModifierUp/Down 与 Counter 失败提示仍需逐分支核验 | 仅在独立复现后修正具体边界，不覆盖已有 1～999 夹值；Counter 提示依赖 #440 改造策略 | 高 / 中高 |
| **#442** `3595661a0c` | fix(battle): 收口 Dynamic Spark、Counter 幽灵免疫与伤害边界保护 | 混合 Dynamic Spark 最低值、Counter 对 Ghost 免疫、混乱自伤属性，及伤害除数 c 最小为1 | **待核验 Bug** | CHS `src/engine/battle/core.asm:CalculateDamage` 只在 EXPLODE_EFFECT 防御折半后保护 c≠0；其后普通 `ld [hl],c` 进入 Divide；但是否可达到零除仍需分析。CHS Counter 规则采用 Normal/Fighting 判定，与 RPP 新图表并不一致 | **优先静态证明**一般防御除数是否可能为零，必要时只补最小值保护；Counter Ghost/新类型规则暂不移植；混乱自伤 Attack/Defense 已有现行路径需对照 | 高 / 中高 |
| **#443** `71d78a1a4a` | fix(battle): 收口替身多段提示与自伤反伤路由 | 替身多段命中文字顺序、混乱自伤/Jump Kick 落空反伤绕开敌方替身并恢复正确伤害指针 | **待核验 Bug** | CHS `src/engine/battle/core.asm:PrintMoveFailureText` 落空反伤仍跳 `ApplyDamageToPlayerPokemon/EnemyPokemon`；`AttackSubstitute` 注释指出自身反伤可能落入对方替身；SelfConfusionDamage 也走普通伤害入口 | 这是 CHS 真实共享路径差异，建议优先做小范围独立复现；区分结算规则与文字优化、慎防双侧 HP/替身误扣，不能整搬 RPP 多段助手 | 高 / 高 |
| **#444** `6d87cab1c7` | test(battle): 增加独立战斗测试 ROM 与集中测试入口 | 新增 test-red/test-blue 可选 ROM、脚本化战斗 NPC 与集中多段/替身/落空反伤测试入口 | **需评估** | CHS 当前 `Makefile` 为正式 red/blue 构建，无 RPP TEST ROM 宏和地图专用测试 NPC | 测试基础设施可借鉴思路，但不应让临时 NPC、WRAM 别名或测试 Hooks 混入正式构建；可独立实现纯测试 ROM | 高 / 高 |

## 本批优先核验队列（不直接实现）

| 优先级 | 提交 | CHS 最小核验路径 | 备注 |
|---|---|---|---|
| **高** | **#443** | 己方/敌方各一次：开替身后混乱自伤、Jump Kick 落空反伤；检查真实本体 HP、替身 HP、两段动画和提示 | 可能影响真实战斗 HP，不能直接把 RPP 全部状态机移入 CHS |
| **高** | **#440** | Counter 面对换人、替身、多段攻击、此前己方伤害、对方用无威力招式；检查是否反击无效/旧伤害 | CHS 源码明确保留共享 `wDamage` 风险；优先做游戏复现 |
| **中高** | **#442** | 分析极端 Defense/Special/Explosion 缩放是否能令分母 `c=0`；如可达则独立加最低 1 保护 | 不顺手改变 Ghost 免疫、伤害分类或 Dynamic Spark 规则 |
| **中** | **#441** | 能力阶段已满且显示数值 999 时的合法升降；Counter 失败与命中文字对照 | CHS 已有计算值 1～999 夹值，不可重复套整段 |
| 按需 | **#444** | 是否需要隔离的 test-red/test-blue 验证 ROM 与自动化测试，且正式 ROM 无测试 Hook | 属测试工程，非游戏功能 |
| 暂缓 | **#421～439** | 先由维护者明确是否需要扩招、地区形态、Play Rough、Dynamic Spark | 未有需求，不新增大系统 |

## 完整参考提交范围闭环

- 历史目录按 `#001～#444` 编号，缺少 `#072`、`#269` 两个文件，因此 **实际 442 笔**；`#421～444` 均有原始补丁。
- **15 批编号范围 001～444 已全部完成第一轮静态分类**，不代表 442 笔都完成运行级验收或适合移植。
- 批次结论与“跨批次建议总览”仅供用户逐批挑选；尚未授权的战斗机制变更、扩展招式与参考引擎路径不做代码移植。
- 本次仅变更 `docs/` 与 `TODO.md`，不改变游戏内 `ROM-1.21` 版本，不编译 ROM，也不执行 Git Commit / Push。
