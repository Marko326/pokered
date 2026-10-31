# RPP 参考分支移植台账：第 11 批（301～330）

> **CHS 对照版本**：`ROM-1.21.zip`，已提交 HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **RPP 来源**：交接包 `individual/301～330`，**30 笔实际存在的提交**。逐条查看原始 patch 中的文件差异、Hash 和提交描述。
> **审查范围**：静态对照 CHS 的 `src/`、验收历史与 RPP 原补丁；**参考新增功能产生的 Bug 不等于 CHS 现存 Bug**。未进行游戏运行验证，本轮不移植游戏代码。

## 核心判断与依赖关系

1. **#301～309、#312～325、#327 绝大多数是 RPP 新技能和 extended animation 后续修复**：Shadow Punch、Sludge Bomb、Aeroblast、DynamicPunch、Flame Wheel、Cross Chop、Crunch、Icy Wind、Dragon Pulse、Shadow Ball、Earth Power、Energy Ball、Iron Tail、Gunk Shot 等均不属于当前 CHS 原版招式系统。大部分提交还依赖 `data/extended_move_animations.asm`、Crystal Audio `crysaudio/rbsfx.asm`、CGB 动态调色、专用 VBlank/WX 震动或新的 HBlank/LCD STAT 中断。不能因为标题写 `fix` 就直接断言 CHS 有这些故障。
2. **#310 和 #311 是真实玩法规则改动**：#310 用 Spark 替换 CHS 确实存在的 Razor Wind；#311 让 CHS 也存在的 Egg Bomb 改威力体系、属性来源、命中率和附加效果。这不属于修 Bug，直接套会改变战斗平衡、招式 ID 兼容性及存档体验。默认不做，先听维护者决定。
3. **#326 是本批相对独立的画面增强**：CHS 已有 Bone Club/Bonemerang 原版动画，参考提供 Gold/Crystal 骨棒图块与轨迹。可以单独评估，但这仍是自选美术增强，不是现有故障。
4. **#328 START 菜单的目标已在 CHS 分阶段部分实现**：QOL-1.11～1.16 已做完整显示、字库/窗口传输提速、快速关闭和二级菜单白屏返回；与 RPP 直接复用 VRAM 常驻资源及 `wStartMenuSavedMenuItem` bit7 的具体方法并不相同。汉化 DFS 字形缓存与 auto-text 地图让直接照搬具有高风险，先保留为部分实现，不默认追加优化。
5. **#329～330 参考地区形态系统专属**：包括 Party/form marker、Safari Catch Rate、首次捕获图鉴、联机交换和名人堂记录。CHS 并无地区形态持久标记，不能把它们认作 CHS 原版缺陷；如果以后要新增地区形态，必须连同原始生产者和存档/联机格式一并审查。

## 分类统计

- **依赖暂缓：15**（#302、#303、#304、#306、#307、#308、#309、#313、#318、#320、#321、#322、#323、#324、#327）。
- **当前不适用：10**（#301、#312、#314、#315、#316、#317、#319、#325、#329、#330）。
- **部分实现：1**（#328）。
- **需评估：4**（#305、#310、#311、#326）。

## 301～330 逐笔移植评估

| 编号 / RPP Hash | RPP 原始提交标题 | 核心改动 | CHS 现状 | CHS 源码对照依据 | 建议与移植约束 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#301** `f93ce84750` | fix(animation): 修复暗影拳敌方使用时命中特效错位 | Shadow Punch 敌方命中特效坐标从 X32 修正到 X40 | **当前不适用** | CHS `src/constants/move_constants.asm` 的原版招式表没有 Shadow Punch；原提交只改 `data/extended_move_animations.asm` 中 `PlayShadowPunchCenteredPoof`。 | 属于参考扩展招式的专属 Bug，CHS 没有相同动画入口；不移植。 | 低 / 高 |
| **#302** `2b9c167d15` | fix(animation): 将污泥波替换为污泥爆弹并还原金版演出 | 将 Sludge Wave 换成 Sludge Bomb，并移植金版投射/毒液演出 | **依赖暂缓** | CHS 只有原版 Sludge/Acid 等技能，`move_constants.asm` 无 Sludge Wave 或 Sludge Bomb；提交还更新 `crysaudio/rbsfx.asm`、扩展动画和学习表。 | 若未来新增 Sludge Bomb，单独规划技能 ID、名称、汉化与动画，不能把 RPP 的整体替换视作 CHS Bug 修复。 | 高 / 高 |
| **#303** `47cbca58f0` | fix(animation): 还原金银版空中爆破完整演出 | Aeroblast Gold/Crystal 四阶段风压与射线动画重制 | **依赖暂缓** | CHS 原版招式表无 Aeroblast，缺少 RPP 的 `data/extended_move_animations.asm` 与 Crystal Audio 音效链。 | 依赖新增招式、扩展渲染器及图形音频；当前不移植。 | 高 / 高 |
| **#304** `d97fa46b7e` | fix(animation): 还原金银版爆裂拳爆炸演出 | DynamicPunch 五次 Explosion2 与金银版爆炸时间轴 | **依赖暂缓** | CHS 无 Dynamic Punch，RPP 改 `engine/battle/dynamic_punch_animation.asm` 与 `crysaudio/rbsfx.asm`。 | 原参考动画增强，不是 CHS 既有 Bug；归入未来扩展招式项目。 | 高 / 高 |
| **#305** `4546ae9660` | feat(move): 加入 Sacred Fire 并还原金银版完整演出 | 新增 Sacred Fire 技能、50% 烧伤效果与专用动画 | **需评估** | CHS 原版招式表没有 Sacred Fire 或 RPP #248 Bone Rush 槽位；移植会改变招式常量、学习表、伤害效果、音效及中文文本。 | 这是大型可选新功能，不是漏洞修复；除非明确决定扩充世代招式，否则暂不开发。 | 极高 / 高 |
| **#306** `57b1f6c56e` | fix(animation): 优化暗影拳并融合金版电光一闪前序演出 | 给 Shadow Punch 增加 Gold Quick Attack 前奏及速度线 | **依赖暂缓** | CHS 有 QUICK_ATTACK，但无 Shadow Punch；参考依赖 #301 与已有 Shadow Punch 额外动作。 | 不能只因原版电光一闪存在就认作可移植；当前不适用，保留动画依赖记录。 | 中高 / 高 |
| **#307** `b48784c4aa` | fix(animation): 还原金银版 Flame Wheel 演出并修正本方受击反馈 | Flame Wheel 8 枚环绕火焰及受击反馈修复 | **依赖暂缓** | CHS 原版招式表无 Flame Wheel，参考使用 #305 Sacred Fire 图形素材和扩展动画时间轴。 | 需要先导入相关扩展技能和动画图形；不作为 CHS 目前待修复问题。 | 高 / 高 |
| **#308** `fe13528446` | fix(animation): 还原金银版 Cross Chop 并修复全帧横向震屏 | Cross Chop 金银版双斩与 VBlank 锁存 WX 横震 | **依赖暂缓** | CHS 无 Cross Chop；参考修改 `color/vblank.asm` 并依赖已扩展的横震动画桥接。 | 直接移植会触及 CHS DMG/CGB 显示与 VBlank 时序，暂缓。 | 极高 / 高 |
| **#309** `272ed3e001` | fix(animation): 还原金银版 Crunch 并整理受击反馈例外 | Crunch 双颚动画和 DamageFeedbackOverrides 集中例外表 | **依赖暂缓** | CHS 只有原版 BITE，没有 Crunch / Shadow Ball / Shadow Punch / Flame Wheel 对应扩展受击路径。 | 参考新增技能后的集中反馈调度，不能覆盖 CHS 现有动画分派。 | 极高 / 高 |
| **#310** `b6839f5620` | feat(move): 将 Razor Wind 替换为 Spark 并还原金银版完整演出 | 将原版 Razor Wind 技能槽替换成 Spark，重写威力/属性/麻痹规则 | **需评估** | CHS `src/constants/move_constants.asm` 仍定义 RAZOR_WIND，原版双回合效果路径仍有用途。 | 这是删除原技能再换入新技能的玩法变更；需要用户明确同意、评估存档招式 ID 兼容，不当作修 Bug。 | 极高 / 高 |
| **#311** `2c353bac1e` | feat(move): 强化 Egg Bomb 并还原金银版完整演出 | Egg Bomb 命中率 75%→90%、改特殊攻击、使用者第一属性、附加混乱 | **需评估** | CHS `src/constants/move_constants.asm` 保留 EGG_BOMB，`src/data/moves/animations.asm:EggBombAnim` 有原版动画；本提交修改的是实际存在招式的规则。 | 有直接可对照对象，但会明显改变一代伤害/属性/存档战斗体验；必须用户决定，不默认移植。 | 极高 / 高 |
| **#312** `39f72b7701` | fix(animation): 修复 Acid 与 Sludge 敌方分段动画轨迹错位 | 修复 RPP Acid/Sludge `$13→$14` 新分段动画的敌方轨迹 | **当前不适用** | CHS 有 ACID/SLUDGE，但没有 RPP #287/#294 引入的无缝 high-water 两段桥接与 DDA 补偿逻辑。 | 不代表 CHS 原版 Acid/Sludge 必然错位；如动画实际异常另行复现，不套扩展动画专用坐标补丁。 | 中 / 高 |
| **#313** `2e3ec812c1` | fix(animation): 还原金银版 Icy Wind 并修复目标波纹重叠 | Gold/Crystal Icy Wind 专用波纹与 HBlank 效果 | **依赖暂缓** | CHS 原版招式表无 Icy Wind，也没有 `engine/battle/icy_wind_animation.asm`。 | 新增技能与扫描线波形需整体设计；涉及显示管线，暂缓。 | 极高 / 高 |
| **#314** `0ed2664a81` | fix(animation): 修复 Icy Wind 上方波纹边界串入本方 HUD | 修复 Icy Wind 顶部波纹采样到本方 HUD | **当前不适用** | CHS 没有 Icy Wind 波纹渲染器；该问题发生在 #313 创建的特殊 HBlank 波形中。 | 是参考新效果引出的边界故障，不能按 CHS 现有 Bug 标记。 | 低 / 高 |
| **#315** `54417b9a63` | fix(animation): 修复 Icy Wind 本方宝可梦下沿波纹 | 修复 Icy Wind 本方图像底部少一行波纹 | **当前不适用** | CHS 不存在 #313 生成的 Icy Wind 波纹表和目标裁剪边界。 | 只随未来 Icy Wind 功能开发整体验收，当前不移植。 | 低 / 高 |
| **#316** `febfd57ee1` | fix(animation): 修复 Icy Wind 对方宝可梦顶部波纹 | Icy Wind 波纹改用 LCD STAT Mode-0 ISR 以覆盖顶部扫描线 | **当前不适用** | CHS 没有 Icy Wind；参考补丁改动 `home/vblank.asm`、`color/vblank.asm` 和 LCD STAT 中断。 | 不能为不存在的技能贸然加入高风险中断路径；未来若要类似效果先做兼容性设计。 | 极高 / 高 |
| **#317** `623af1465b` | fix(animation): 修复 Icy Wind 对方宝可梦下沿波纹 | 修复 Icy Wind 对方图像最下沿波纹与 HUD 边界 | **当前不适用** | CHS 缺少 #313～316 的 Icy Wind 扫描线渲染与裁剪表。 | 是该新增特效的衍生修复；当前不适用。 | 低 / 高 |
| **#318** `e33c962141` | feat(animation): 将 Dragon Pulse 替换为金银版 Dragon Rage 波动演出并平滑降速 | Dragon Pulse 改用 Gold Dragon Rage 的 16 发火焰波动 | **依赖暂缓** | CHS 有 DRAGON_RAGE 但**没有** DRAGON_PULSE；参考通过独立扩展技能、Gold 火焰素材与渲染入口实现。 | 不能把“CHS 存在 Dragon Rage”误判为已经拥有 Dragon Pulse 或对应动画链。 | 高 / 高 |
| **#319** `5f0ba08a70` | refactor(animation): 压缩 Dragon Pulse 减速坐标表为 20 帧周期 | 将 Dragon Pulse 45 项慢速坐标表压缩至 20 项 | **当前不适用** | CHS 没有 #318 的 Dragon Pulse 减速坐标表或 helper。 | 参考新增动画后的局部节省，不是 CHS 可独立回收的 ROM 空间。 | 低 / 高 |
| **#320** `366ce0dba4` | fix(animation): 修正 Shadow Ball 金银版投射轨迹 | Gold Shadow Ball 正弦投射轨迹与敌方镜像修正 | **依赖暂缓** | CHS 原版招式表无 SHADOW_BALL，也没有 RPP WAVE_TO_TARGET 扩展配方。 | 若未来添加 Shadow Ball 则包含此修复，当前不可当作 CHS 现有投射物 Bug。 | 中高 / 高 |
| **#321** `128b4ea8e7` | fix(animation): 重制 Earth Power 并还原 Polished Crystal 三段喷发演出 | Earth Power 的 Polished Crystal 三段地脉喷发与横震 | **依赖暂缓** | CHS 原版招式表无 Earth Power，参考新建 `earth_power_animation.asm`，依赖 WX 震动和扩展渲染网关。 | 大范围新增视觉功能，先决技能和动画引擎均不存在，暂缓。 | 极高 / 高 |
| **#322** `22a0481481` | feat(move): 将 Petal Blizzard 正式替换为 Energy Ball 并移植 Polished Crystal 动画 | 以 Energy Ball 替换扩展 Petal Blizzard #217 槽位及专用动画 | **依赖暂缓** | CHS 原版招式表无 Petal Blizzard/Energy Ball，也没有 RPP #217 扩展槽位及 MoveDex。 | 参考扩展技能内部替换，不是 CHS 对应 Bug；如以后扩充技能需先设计 ID。 | 极高 / 高 |
| **#323** `4c739acd95` | fix(animation): 完成 Iron Tail 金版摆动并修正敌方命中反馈 | Gold Iron Tail 后段摆动、命中反馈与依赖补齐 | **依赖暂缓** | CHS 原版招式表无 Iron Tail；参考含 `crysaudio/rbsfx.asm`、动态调色与 bank-$3D 前置代码。 | 不能只移植命中反馈片段；依赖专用技能与动画渲染器。 | 极高 / 高 |
| **#324** `0d3ca2bad7` | fix(animation): 完整移植 Gold/Crystal Iron Tail 并收口扫描线、前奏与命中反馈 | Iron Tail 全部 Gold/Crystal 扫描线、前奏、动态配色与命中反馈 | **依赖暂缓** | CHS 没有 #323 的 Iron Tail helper、Steel 类型扩展动画与目标扫描线代理。 | 与 #323 为同一功能链的后续完整实现，暂缓。 | 极高 / 高 |
| **#325** `8ec82d006a` | fix(animation): 修复 Iron Tail 换人后目标下沿空白 | 修复参考 Iron Tail 换人后 OBP1 未恢复导致底部白行 | **当前不适用** | CHS 没有 Iron Tail 的 W2_UseOBP1 静止 OBJ 行方案；这是 RPP #323～324 新增视觉效果中的特定回归。 | 不推断 CHS 换人后存在同类白行；若未来引入 Iron Tail 必带上修复。 | 中 / 高 |
| **#326** `08554aa91a` | feat(animation): 移植 Gold/Crystal Bone Club 与 Bonemerang 骨棒动画 | Gold/Crystal Bone Club 与 Bonemerang 两块新骨棒图形与轨迹 | **需评估** | CHS 原版 `src/data/moves/animations.asm` **确实**存在 `BoneClubAnim` 和 `BonemerangAnim`；但没有本参考的 Gold 骨图和旋转帧实现。 | 这是可以选择的动画品质升级，未确认原版异常；比整套 Extended 动画轻，但需确认素材授权、OBJ 时序与 DMG/CGB 效果。 | 中高 / 高 |
| **#327** `9889bec65b` | feat(animation): 移植 Polished Crystal Gunk Shot 动画 | Polished Crystal Gunk Shot 毒团连续投射与动态震屏 | **依赖暂缓** | CHS 没有 Gunk Shot 扩展招式，也没有 RPP 动态 OBJ palette/VBlank WX 动画网关。 | 新技能专属动画，暂缓，不作为 CHS Bug 修复。 | 极高 / 高 |
| **#328** `758cef5fdb` | perf(menu): 轻量化 START 菜单并完善子菜单返回显示时序 | START 轻量打开/直接关闭、子菜单白屏返回和状态位复用 | **部分实现** | CHS 在 `src/engine/menus/display_text_id_init.asm`、`start_window_fast.asm`、`src/home/start_menu.asm` 已实现 QOL-1.11～1.16 的加速、窗口缓存、子菜单返回与快速关闭；仍会在某些路径调用 `LoadFontTilePatterns`，也没有 RPP `wStartMenuSavedMenuItem` bit7 状态协议。 | 同一体验目标部分已实现，不能整笔重复套。若用户仍感到慢，应单独比较普通地图 vs auto-text、DFS 字体加载、Bank0 图块污染与关闭路径，严禁直接复制依赖英文  VRAM 常驻字形的轻量模式。 | 高 / 高 |
| **#329** `af0fe260e2` | fix(forms): 稳定地区形态身份并修复捕获后首次图鉴展示 | 地区形态持久化 marker、捕获后首帧图鉴与 Safari 捕获率修复 | **当前不适用** | CHS 无区域形态持久化 marker、`wEnemyMonForm` 或 `wPokedexViewForm`；现存原版 Header/图鉴只按 Species。 | RPP 地区形态新系统的衍生修复；不能认为 CHS 有同样的捕获图鉴 Bug。 | 极高 / 高 |
| **#330** `3f1662b444` | feat(forms): 补全联机交换与名人堂地区形态显示 | 地区形态联机交换与 Hall of Fame 记录/显示 | **当前不适用** | CHS 没有 #329 所依赖的持久 form marker；参考复用旧 HoF spare byte 会触及存档/联机布局约定。 | 仅在未来明确要做地区形态时成组研究，且需独立评估中文名、存档与联机兼容；目前不适用。 | 极高 / 高 |

## 优先级建议（本轮不实施）

| 优先级 | 提交 | 建议 | 前置条件 |
|---|---|---|---|
| P1 先向用户确认 | **#311** | 是否希望 Egg Bomb 变更为参考的多属性/高命中版本 | 属于改变现有战斗规则，不可默认为 Bug 修复 |
| P1 先向用户确认 | **#310** | 是否真的要以 Spark 替代原版 Razor Wind | 涉及招式 ID、战斗与旧存档兼容；默认保持原版 |
| P2 可选体验 | **#326** | Gold/Crystal Bone Club 与 Bonemerang 骨棒图像 | 仅用户希望动画升级时做专项；不引入 RPP 全套动画系统 |
| P2 专项性能审计 | **#328** | 对比 CHS 已有 START 快速关闭与 RPP 分支剩余差异 | 先实测真实瓶颈，保护 DFS 字库和 auto-text 地图，不直接套 RPP patch |
| P3 高依赖暂缓 | **#301～309、#312～325、#327** | 作为扩展技能/动画库的参考，不单独接收其 fix | 需要先有对应技能及完整渲染框架，Crystal Audio 不能直接移植 |
| P3 新系统暂缓 | **#329～330** | 地区形态及联机/名人堂支持仅作后续需求索引 | 必须先设计持久 form marker、中文名与存档/联机兼容 |

## 下批与审核边界

- 第十批以前已静态评估 **298 笔真实提交**（#072、#269 缺号）；本批再评估 **30 笔**，累计 **328 笔**，审查至 #330。
- 下一批为 **331～360**，当前不得预先把未审查提交写成已完成。
- 本批仅新增项目审核文档并更新分批索引、统一验收历史和 TODO；**不改变 `src/`、游戏版本 `ROM-1.21`、音频、存档或 ROM Bank。无编译、模拟器运行、Commit/Push。**
