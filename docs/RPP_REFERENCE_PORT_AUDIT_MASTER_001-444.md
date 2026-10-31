# RPP 参考分支 442 笔提交：15 批成果总台账

> CHS 对照版本：`ROM-1.21`；本轮整理基线：`CHS_Mod` 已提交 HEAD `f7a43ff08a5e213c55fcfa1a287b5f6bd5658bfb`。
> 本表**由项目已有 15 份分批静态审核文档逐笔提取合并**；不是本轮对 442 笔重新编译或运行验证。原批次原文及其中的 CHS 源码依据仍为权威细节。
> 参考编号 `001～444`，其中 `#072`、`#269` 在交接资料中缺失独立补丁，实际可评估的为 **442 笔**。

## 一、第一轮成果总数

| 状态 | 笔数 | 下一步动作 |
|---|---:|---|
| 已实现 | 16 | 保留现有 CHS 功能，不重复移植 |
| 部分实现 | 24 | 只核对剩余差异；不得覆盖已有稳定实现 |
| 待核验 | 17 | 没有运行复现前不能写成已确认 Bug |
| 待核验 Bug | 16 | 与“待核验”合并统计；按专项场景复现 |
| 需评估 | 111 | 新增功能、规则或 QoL，先由维护者选需求 |
| 当前不适用 | 77 | 缺少参考引擎/前置系统，原则上不移植 |
| 依赖暂缓 | 181 | 大型系统按依赖链整体评估；不拆补丁 |
| **实际提交合计** | **442** | 不包含 2 个缺号 |

> 合并口径：两种写法“待核验”（17）与“待核验 Bug”（16）均表示**未在 CHS 运行证实**，合计 **33 项**，并不是 33 个确定 Bug。

## 二、已整理的决策路线

1. **先审计较明确、改动范围小的风险**：#177（老虎机图块复制长度与素材实际长度不符）；#173（BCD 跨 Bank 输入指针，仅核查 ROMX 指针来源）；#180（standing-only NPC 素材边界）；#442（除数为 0 的可达性）。先做静态核验，不对这四项一概直接套参考代码。
2. **再做可控运行复现**：#443（自伤/落空反伤/替身）、#440（Counter 真实受击）、#336（Transform Fly/Dig）、#266（濒死回合末伤害）、#390（双针与替身）、#417（战斗 PP 道具）、#195（HM 存电脑）等；有问题才开独立修复。
3. **QoL 由维护者按需选**：#073～076（PC 连续存取）、#042（列表翻页）、#101～103（购买、电梯）、#289（Party/Bag/PC 快捷键）、#346～347（连续使用道具）、#237（神奇糖果文字），仍需验证中文 DFS 与现有 START/SELECT 快捷键。
4. **默认暂缓系统链**：Crystal Audio、地区形态/独立图鉴、扩容招式/MoveDex、分类背包、大片动画重构、地图数据全量压缩、非用户要求的战斗规则变更。

更具体的实施顺序、最小验证矩阵见 [`RPP_REFERENCE_PORT_NEXT_ACTIONS.md`](RPP_REFERENCE_PORT_NEXT_ACTIONS.md)；先前审查总览保留在 [`RPP_REFERENCE_PORT_AUDIT_TRIAGE_001-444.md`](RPP_REFERENCE_PORT_AUDIT_TRIAGE_001-444.md)。

## 三、442 笔逐项状态（由原批报告提取）

| 编号 / Hash | 参考改动标题 | 静态分类 | CHS 处理倾向 | 详细证据 |
|---|---|---|---|---|
| #001 `8a681f4f4a` | 修复竖向屏幕震动闪烁并恢复原始节奏 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #002 `7ef6b9035d` | 修复联机交换后存档损坏的问题（暂未修复联机对战问题） | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #003 `f1055b3d60` | 修复联机对战对手显示、调色板及战斗模式异常 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #004 `aeb045ac5d` | 修复遇到特定宝可梦导致游戏卡屏的问题 | 当前不适用 | 不直接适用 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #005 `6364947006` | 修复偶现的开机白屏并移除开机白屏提示 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #006 `ecc3a123fb` | 移植 pureRGB 的 60 帧模式至 RPP，优化游戏流畅度 | 已实现 | 不重复移植 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #007 `44971264ad` | 增加在Stats上按住 START/SELECT 查看个体值或努力值的功能 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #008 `fdcca2b609` | 消除白屏闪烁并缩短黑屏等待时间 | 部分实现 | 只核剩余差异 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #009 `3a40a1382f` | 减少敌方宝可梦受击闪烁次数（从 6 次调整为 4 次） | 已实现 | 不重复移植 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #010 `87e09fcdd1` | Double Edge 在对手使用时动画表现异常 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #011 `8c56ca37f0` | 宝可梦使用睡觉技能导致的睡眠回合从三回合降为两回合 | 已实现 | 不重复移植 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #012 `5ad63a101a` | 联机交换音乐播放及对战对手名称显示问题 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #013 `6006647c8f` | 将联机对战改为联机Lv50级等级对战 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #014 `640404f3ae` | 修复飞翔地图界面右上角白点显示问题 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #015 `8d3be44735` | 新增 Lv50 等级联机对战模式，优化联机大厅查看数值与经验显示规则 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #016 `2dee869a79` | 调整文本显示速度 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #017 `9c5aaa41f6` | 消除对话框出现后的文字显示延迟 | 部分实现 | 只核剩余差异 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #018 `4ecb999647` | 调整麻痹减速效果，由 1/4 改为 1/2 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #019 `ce0187c1bb` | 清理废弃 CryData 旧叫声参数冗余代码 | 当前不适用 | 不直接适用 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #020 `16f6a94211` | 缩短游戏保存时间 | 已实现 | 不重复移植 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #021 `f1f439ec5c` | 与训练师对战时不允许使用背包 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #022 `9894643699` | 强制使用 Set 对战模式 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #023 `6c9b95209d` | 修复 EXP.ALL 经验提示重复显示的问题 | 待核验 | 先复现 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #024 `6007c7715f` | 升级学习新技能时，技能名称展示在下方对话框内以及精简学习新技能的文本 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #025 `d1251404a8` | 继续游戏和存档界面新增当前位置 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #026 `aa9843653d` | 修复头槌闪烁及简化文本 | 当前不适用 | 不直接适用 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #027 `8140eacf3e` | 中毒、烧伤和寄生种子伤害比例由1/16变更为1/8 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #028 `4560d88ab1` | 修复残留状态伤害结算并优化中毒/烧伤/寄生种子流程 | 依赖暂缓 | 成组暂缓 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #029 `635f794363` | 调整冰冻与睡眠状态持续回合机制 | 需评估 | 需求待选 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #030 `0ecb771987` | 调整冰冻与睡眠状态持续机制 | 依赖暂缓 | 成组暂缓 | [001-030.md](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| #031 `5265eea500` | 缩短砍树对话 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #032 `9c35c937c2` | 缩短冲浪对话 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #033 `7d0f914f98` | 缩短怪力对话，与砍树和冲浪流程对齐 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #034 `6e23f2ed20` | 缩短怪力对话 | 依赖暂缓 | 成组暂缓 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #035 `2e5c75ae65` | 增加头槌对话野外交互 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #036 `14b1679ece` | 使用挖洞或瞬间移动前增加确认提示。 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #037 `90b26404ca` | 将 Stats 调整为宝可梦右侧操作菜单的第一项，并将可用的对战外技能排列在其下方。 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #038 `8d9c2b6f5a` | 宝可梦右侧操作菜单启用首尾光标切换 | 已实现 | 不重复移植 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #039 `fc3390da3f` | 迁移bank1文件到bank34 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #040 `2e38bc2bc1` | 移除 “Take your time.” | 已实现 | 不重复移植 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #041 `adfb66297b` | 去除商店商品描述文字闪烁及优化上下切换的流畅度 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #042 `a398fbbab7` | 支持道具菜单翻页与首尾跳转，消除光标闪烁 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #043 `6a0c655c8a` | 缩短PC中心治疗对话内容 | 部分实现 | 只核剩余差异 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #044 `e3e6888756` | 游戏厅增加10000购买500金币 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #045 `1ca6640ee0` | 缩短技能回忆和遗忘的对话文本及流程 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #046 `22dd7e9fd1` | 缩短普通技能教学文本 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #047 `b05bca32ab` | 调整特殊招式教学菜单的显示位置，将文本框上移一行 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #048 `86f73cd2c9` | 新增妙蛙花、喷火龙和水箭龟的大招教学限制 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #049 `0c55fa59f2` | 图鉴列表增加 SELECT 播放叫声 / START 查看栖息地快捷键 | 部分实现 | 只核剩余差异 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #050 `e95f0d8b71` | 图鉴列表上下键在首尾处快速跳转 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #051 `85bde75df2` | 设置中增加关闭背景音乐选项及分页设置菜单 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #052 `fb3e243bb7` | 修复在关闭音乐时进入图鉴详情或状态界面产生爆音的问题 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #053 `89bfd604c1` | 新增背景音乐音量控制与低音量增益补偿 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #054 `6d09ab3d50` | 修复静音时PC治疗后死机 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #055 `1df1d63101` | 修复治疗结束后的爆音 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #056 `e1be5e73ae` | 完善静音状态下的音乐等待、停止与解析隔离 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #057 `b7ee095bdd` | 优化 ROM bank 调用并将属性计算移出 HOME | 部分实现 | 只核剩余差异 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #058 `d6b6cbc5f1` | 新增 map 和 cleanpic | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #059 `ccb8c0dea4` | movebox第一版 | 需评估 | 需求待选 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #060 `4ae0130310` | 修复战斗技能音效的音高/速度修正未生效的问题V2 | 当前不适用 | 不直接适用 | [031-060.md](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| #061 `2da0835680` | 将战斗音效的 dutycycle 替换为 dutycyclepattern 以匹配 Gen1 原版 | 当前不适用 | 不直接适用 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #062 `d64ebf7dca` | 区分 Music Off 与音量静音，消除静音切换时的爆音并保留 BGM 恢复目标 | 当前不适用 | 不直接适用 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #063 `556e19b56e` | 修复瞪眼音效v4.3 | 当前不适用 | 不直接适用 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #064 `87af13bb3a` | 修复：宝可梦中心取消治疗后立即关闭对话框 | 部分实现 | 只核剩余差异 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #065 `ad888623a7` | 优化 START 菜单字体加载与显示时序 | 已实现 | 不重复移植 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #066 `b06a824a9d` | 调整黑夜魔影动画效果 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #067 `3fa5d19633` | 修复退出 MoveDex 后户外屋顶图块乱码 | 当前不适用 | 不直接适用 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #068 `113ec3608b` | 统一游戏版本号显示与维护 | 已实现 | 不重复移植 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #069 `402e1c71f8` | 增加游戏内 Normal / Snowy 世界模式切换 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #070 `1420a790d7` | 修改默认rom生成的名称和位置 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #071 `85c3ffe2a1` | 优化训练家派出宝可梦文本的自动滚动 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #072 `—` | 交接资料缺少 #072 独立补丁（无原始标题） | 缺号 | 无原补丁，不推测 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #073 `887bcb3d13` | 存取宝可梦后保留当前操作界面 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #074 `a82b9c5fa3` | 优化精灵盒子存取限制与界面返回逻辑 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #075 `4590050511` | 修复存取宝可梦后列表游标落到 Cancel 的问题 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #076 `b5dcfc396b` | 完善宝可梦盒子的连续存取与菜单返回体验 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #077 `7ffb140546` | movedex_v1.0.1-v1.2.6 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #078 `82ba739ea2` | 背包分类展示V1 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #079 `0bc91b8e53` | 背包分类展示V2 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #080 `8f10d2186c` | 重构背包分类为 Slot Map 架构并完善 Pocket 交互 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #081 `c9ab87df89` | feat: 完成四分类战斗背包、独立光标记忆与界面稳定性整改** | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #082 `053aecd2e0` | feat: START 背包跳过空分类并修复标题切换残影 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #083 `ce4d5a6384` | feat(menu): START 菜单在当前游戏会话中保留光标位置 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #084 `870f05e8cb` | feat: 钓鱼便捷化：优化未咬钩重试与遭遇文本流程 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #085 `90db9580d5` | feat(bag): 简化物品描述并移除独立 INFO 菜单 | 部分实现 | 只核剩余差异 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #086 `b36ff7a593` | feat(fly): 扩展飞行地点与地图操作 | 需评估 | 需求待选 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #087 `45bd21805f` | feat(fly): 完善特殊飞行地点显示逻辑 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #088 `b959926f2e` | feat(fly): 完善特殊飞行地点显示逻辑 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #089 `7639accfde` | feat(town-map): 优化地图浏览起点并开放常磐森林飞空 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #090 `0aa45cf591` | feat(fly): 完善飞行地图双向地理导航与快捷复位 | 依赖暂缓 | 成组暂缓 | [061-090.md](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| #091 `7ef6b8c846` | fix(town-map): 调整月见山广场地图显示位置 | 当前不适用 | 不直接适用 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #092 `3a4f983360` | feat(fly): 新增玉虹百货楼顶特殊飞行地点 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #093 `ef36f660f1` | feat(town-map): 优化双子岛地图位置并同步飞行显示 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #094 `8d128d1be6` | fix(town-map): 修复 Surf 状态在地图切换中的丢失问题 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #095 `e2d5f4d8d0` | fix(pokedex): 修复捕获地点返回图鉴后的角色残留 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #096 `380d7cff42` | fix(surf): 恢复一代冲浪精灵图标 | 已实现 | 不重复移植 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #097 `e89e14868a` | fix(surf): 添加冲浪皮卡丘支持 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #098 `0b82c8487c` | fix(town-map): 统一 Route19/20 与双子岛地图定位 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #099 `829f64fc5f` | feat(town-map): 添加地图快捷定位并优化按键触发 | 部分实现 | 只核剩余差异 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #100 `95b1274995` | fix(overworld): 优化冲浪碰撞音效触发 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #101 `3148a7c783` | fix(vending-machine): 优化饮料机购买流程 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #102 `47a4b0c801` | fix(item-lists): 统一道具列表操作后的光标与返回行为 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #103 `6151c20df9` | feat(elevator): 缩短建筑电梯等待并定位当前楼层 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #104 `1243dbc826` | feat(summary): 重构宝可梦信息页左右切换机制 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #105 `a909672b44` | feat(summary): 重构宝可梦信息页切换机制 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #106 `f6d104d4df` | feat(summary): 切换宝可梦时不再播放叫声 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #107 `4e649e600d` | fix(summary): 稳定宝可梦信息页切换与野外恢复 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #108 `b290d95b00` | perf(summary): 优化宝可梦信息页实时切换体验 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #109 `51fb7ce3fd` | perf(summary): 优化宝可梦信息页实时切换体验 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #110 `e128b16c55` | fix(summary): 修正实时切换宝可梦时 HP 血条颜色残留 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #111 `5855eba254` | fix(summary): 修正电脑宝可梦信息页返回后的地图显示残留 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #112 `2e0b182b66` | fix(pc): 修正电脑菜单回退时的短暂闪白问题 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #113 `53c33dc3cf` | fix(summary): 修正实时切换宝可梦时前图 Palette 数据残留 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #114 `52a776c3ae` | feat(pokedex): 支持图鉴详情页上下浏览已发现宝可梦 | 需评估 | 需求待选 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #115 `7f74523ea1` | perf(pokedex): 优化图鉴详情页实时切换与局部刷新体验 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #116 `d2a19899a6` | feat(bills-pc): 完成 Deposit Stats 实时切换与原子返回 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #117 `51fea8137d` | feat(bills-pc): 完成 Withdraw Stats 实时切换与最终目标同步 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #118 `74df9eb5cf` | perf(bills-pc): 优化 Withdraw Stats Box Pokémon 实时切换性能 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #119 `84af724964` | fix(cursor): 统一放生与道具合并后的列表光标恢复行为 | 待核验 | 先复现 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #120 `f8582e1d88` | perf(summary): 缩短 Pokémon Summary 初次加载白屏时间 | 依赖暂缓 | 成组暂缓 | [091-120.md](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| #121 `9603ed02b6` | perf(summary): 缩短 Party 返回 START 加载时间 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #122 `2b73220f2f` | perf(summary): 进一步缩短 Party 返回 START 加载时间 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #123 `44e5cd2995` | fix(summary): 修复战斗 Summary 返回后横向震屏的框体异常 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #124 `1261f7ece9` | fix(summary): 修复 Party 返回战斗菜单时命令框闪烁 | 部分实现 | 只核剩余差异 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #125 `c065cd9f6f` | perf(summary): 统一 Party/Summary 快速路径并优化 Battle Party 首次进入 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #126 `4e831043d0` | fix(summary): 清除 Battle Party 快速返回时的父菜单箭头残影 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #127 `8bb23a7348` | fix(summary): 恢复 Battle Party Summary 的上下切换宝可梦 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #128 `8272e87727` | fix(pc): 统一卧室电脑与宝可梦中心的完整 PC 功能 | 需评估 | 需求待选 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #129 `5526c7168f` | fix(pokeflute): 恢复战斗中的宝可梦笛音效并追踪敌方睡眠状态 | 需评估 | 需求待选 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #130 `19f3b60ab7` | fix(party): 修复队伍菜单返回时的窗口闪烁 | 已实现 | 不重复移植 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #131 `3aa60942c8` | fix(ui): 优化菜单离屏重建并修复窗口中间帧闪烁 | 部分实现 | 只核剩余差异 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #132 `ef8a6e79fb` | fix(battle): 修复 PSYCHIC类 动画横向滚动寄存器残留 | 待核验 | 先复现 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #133 `841f964c80` | 改进跨环境构建配置 | 已实现 | 不重复移植 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #134 `3f450abe8e` | movedex_v1.2.7 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #135 `5783b30774` | 修复妖精和恶系的射线显示以及部分Lowkick类技能显示问题 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #136 `d8cdb7e378` | 技能优化高音和妖精粉色射线1.2.9 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #137 `b64e73a2c5` | 新技能动画龙之波动恶之波动 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #138 `8498c9f991` | 新技能冰牙，杂耍技能动画 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #139 `8cb0e1da45` | 修复最后一批动画 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #140 `7b171a76b8` | 修复使用提升能力道具时可能会重复播放动画的问题 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #141 `389d07af2b` | 修复使用道具可能会残留配色的问题 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #142 `b3d4061b8b` | 影子球第一版 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #143 `529469c18c` | 优化BANK1E空间 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #144 `9d8de3205f` | 增加流星群特效 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #145 `4a72da9405` | 增加NightSlash黑色双线切割 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #146 `c0826f31a9` | fix: 完善 Night Slash V2.1 动画评审修复 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #147 `6808f76b6f` | 新增战斗动画18属性动态配色系统 | 需评估 | 需求待选 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #148 `f89756a0e4` | 重构切割类技能并加入属性配色与 X-Scissor 交叉斩 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #149 `49528aac41` | 重构咬击类技能并加入属性配色 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #150 `1169a60561` | 爆裂拳V1 | 依赖暂缓 | 成组暂缓 | [121-150.md](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| #151 `b73e37e9e3` | 十拳大补汤V1 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #152 `124f7cb15e` | 十拳大补汤V2 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #153 `3af2a2b596` | 修复彗星拳举起时变成岩石的缺陷 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #154 `9948f11c9b` | 彗星拳增加举起星星后的延迟 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #155 `d776b31936` | 修复双斩后头部形状缺失 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #156 `9edad1119e` | 增加SLASH双斩动画 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #157 `ecbd361c24` | 三爪动画更新 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #158 `62431d0c03` | 新增空气砍和空气切割动画 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #159 `7a8113a2b3` | fix(rom0): 将 movedex v1.2.7 起新增的 HOME 动画代码迁出 ROM0 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #160 `cc4f9bb250` | fix(rom0): 将 Bill's PC 辅助代码迁出 HOME 并精简动画跨 Bank 跳板 | 当前不适用 | 不直接适用 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #161 `9b75a828b5` | refactor(battle): 合并重复战斗计算逻辑并释放 Bank F 空间 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #162 `6e0b1fe135` | refactor(battle): 迁移类型克制逻辑并精简 Bank F 战斗判断 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #163 `5bacbc8c9c` | refactor(battle): 迁移战斗 HUD helper 并合并能力提升副作用逻辑 | 当前不适用 | 不直接适用 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #164 `296e0b9875` | refactor(battle): 清理 Link Battle 死代码并合并状态副效果概率逻辑 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #165 `3dc5f9d0c2` | refactor(battle): 迁移大型 Move Effect 并修复 Disable/Mimic 随机槽读取 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #166 `0fa6ac95ba` | refactor(battle): 迁移睡眠与蓄力招式效果至 Bank $34 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #167 `670de53cfb` | refactor(battle): 重构 TypeEffects 压缩表并提升可读性 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #168 `10537a2933` | feat(battle): 添加技能专属属性克制覆盖机制 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #169 `705e487485` | refactor(bank03): 重排可重定位 helper 以释放固定 Bank 3 空间 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #170 `76e3240bd0` | refactor(bank03): 压缩普通野外遭遇地图索引表 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #171 `f9577a3a98` | refactor(rom0): 拆分 HOME 辅助函数 section 并改善 ROM0 连续空间利用 | 部分实现 | 只核剩余差异 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #172 `e36e1af9e7` | refactor(rom0): 将列表菜单辅助逻辑迁出 HOME | 已实现 | 不重复移植 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #173 `52e1d7e672` | fix(rom0): 修复 PrintNumber 跨 Bank 输入指针并保留安全迁移结构 | 部分实现 | 只核剩余差异 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #174 `6c10fdacd3` | refactor(snowy): 用稀疏差分压缩雪景 tileset 调色板分配 | 当前不适用 | 不直接适用 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #175 `065954df25` | refactor(bag): 合并 START Bag 与 Battle Bag 的公共菜单逻辑 | 当前不适用 | 不直接适用 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #176 `d830a8a55a` | refactor(options): 合并 Options 菜单重复光标与页面绘制逻辑 | 部分实现 | 只核剩余差异 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #177 `ab612092bc` | refactor(animation): 压缩 Battle Animation Bank 并修复老虎机图块跨 section 越界读取 | 待核验 | 先复现 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #178 `6fed3387ce` | refactor(animation): 重构 subanimation 紧凑编码并恢复可维护的语义化数据定义 | 依赖暂缓 | 成组暂缓 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #179 `acbc0c5a66` | refactor(animation): 迁移 Battle Animation 图块资源并显式化跨 Bank 维护约束 | 需评估 | 需求待选 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #180 `be5a2f1851` | fix(overworld): 修复 standing-only NPC walking 图块跨资源越界读取 | 待核验 | 先复现 | [151-180.md](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| #181 `60d5bd106b` | feat(movedex): 透明压缩 MoveDex 技能说明文本并保持源码可读性 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #182 `a7681658de` | fix(movedex): 修复右侧菜单返回时跨 Bank DrawTileLine 调用导致的白屏 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #183 `7370737b21` | refactor(names): 共享压缩 Move、Item 与 Trainer 名称并保持 GetName ABI | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #184 `27b8e3717a` | fix(battle): 修复 Minimize 动画预处理破坏 DE 导致的死机 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #185 `bd05600986` | fix(pokedex): 退出图鉴时重绘 overworld BG0 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #186 `c709652080` | feat(pokedex): 新增第三页种族值信息 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #187 `4b4ae23ca6` | refactor(pokedex): 重构详情页分类与子页导航 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #188 `9719be906e` | feat(pokedex): 新增进化种族值变化子页 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #189 `a4a659d08d` | feat(pokedex): 记住会话内图鉴浏览位置 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #190 `18eb692948` | feat(movedex): 记住会话内技能图鉴浏览位置 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #191 `5bb96267d8` | feat(party): 独立记忆 START 队伍菜单光标 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #192 `0d1d2e99aa` | fix(pc): 修复 Bill's PC 列表光标越过 Cancel | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #193 `b201e7097d` | feat(pc): 统一 Bill's PC Pokémon 列表首尾跳转行为 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #194 `810de3bd1f` | feat(bag): TM/HM Pocket 支持 START 快捷跳转 HM01 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #195 `80f36849f7` | fix(pc): 禁止 HM 道具存入 Player's PC | 待核验 Bug | 先复现 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #196 `9124e61a8c` | feat(hm): 允许普通技能替换 HM 技能并停用旧删除限制 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #197 `049cc43002` | fix(bag): 优化道具使用后 Pokémon 菜单返回并统一快速恢复 | 部分实现 | 只核剩余差异 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #198 `210e60f1b1` | fix(summary): 修复 Party 快速返回时按键音效被拉长 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #199 `18ac734fb6` | perf(battle): 加快开战双方剪影平移速度 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #200 `55955a7860` | perf(battle): 调整开战双方剪影平移至约 1 秒 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #201 `9dee10095f` | perf(battle): 按伤害比例分档调整战斗 HP 掉血速度 | 已实现 | 不重复移植 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #202 `4699317302` | perf(battle): 平滑大伤害 HP 条刷新并强化超高速表现 | 已实现 | 不重复移植 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #203 `a5787d97e7` | fix(names): 修复压缩名称解码覆盖共享 HRAM 导致的商店价格异常 | 当前不适用 | 不直接适用 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #204 `c32244218f` | feat(battle): 延迟多段攻击的暴击与属性效果提示至实际最后一击 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #205 `8a4350cdbd` | feat(battle): 模仿成功后立即使用复制的技能 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #206 `3d90324a46` | fix(battle): 限制Mimic复制目标避免立即行动导致的死循环 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #207 `49cb007161` | fix(battle): Thrash类技能失败时提前解除锁招 | 待核验 Bug | 先复现 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #208 `f0c884ce8e` | feat(battle): 持久化Mirror Move目标并优化复制流程 | 需评估 | 需求待选 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #209 `8533b7fbff` | feat(battle): 强化Mirror Move复制技能并修正目标记忆 | 依赖暂缓 | 成组暂缓 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #210 `ace01974d6` | feat(version): 分离Red++与Blue++版本身份 | 部分实现 | 只核剩余差异 | [181-210.md](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| #211 `063700d6cf` | feat(version): 区分Red++与Blue++菜单主题配色 | 部分实现 | 只核剩余差异 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #212 `62121acbed` | feat(version): 完善Red++与Blue++版本内容差异 | 部分实现 | 只核剩余差异 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #213 `b02d884b22` | fix(gamecorner): 优化游戏厅奖品兑换菜单返回逻辑 | 需评估 | 需求待选 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #214 `aec6543782` | feat(overworld): 添加水晶版地图切换地名显示 | 需评估 | 需求待选 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #215 `73f66f01f2` | fix(overworld): 优化地图地名牌连续刷新与窗口切换 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #216 `3b543f2784` | fix(overworld): 调整地图地名牌显示时长为90帧 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #217 `5bb394153c` | feat(overworld): 添加 Silph Co. 多层室内楼层显示 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #218 `cdaa7db9a0` | feat(overworld): 扩展多层室内楼层与游戏厅地名显示 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #219 `1d34c76738` | feat(menu): 在Options菜单显示当前游戏版本号 | 已实现 | 不重复移植 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #220 `8da6ceade3` | feat(overworld): 扩展狩猎区分区与主要洞窟楼层地名显示 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #221 `66dcd24c1f` | fix(overworld): 优化60FPS下旋转地板移动与动画节奏 | 待核验 Bug | 先复现 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #222 `ce0cdab361` | feat(overworld): 扩展城市多层建筑地名显示 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #223 `ef4ab83675` | feat(overworld): 补齐特殊事件岛屿地名显示 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #224 `81da391da1` | fix(text): 优化远方船票相关文本显示 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #225 `66ca47d9c8` | fix(overworld): 完善S.S. Anne与Vermilion Dock地名显示 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #226 `a2c8942da5` | fix(overworld): 修复凤王战后不消失并补全定点宝可梦隐藏链路 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #227 `f2184c5da8` | fix(overworld): 优化渡轮菜单返回、光标定位与航行等待 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #228 `ddab053ca2` | fix(menu): 修复 Move Deleter 返回技能列表时光标重置并修正单技能分支栈失衡 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #229 `23fa6a7c61` | fix(movedex): 统一详情页导航与分页交互并优化连续浏览体验 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #230 `c49e3f7f10` | feat(forms): 引入不占用新编号的表驱动地区形态框架并完善捕获与显示链路 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #231 `e8c8b360b1` | feat(forms): 完成不占用新编号的表驱动地区形态核心框架 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #232 `4e52c3704b` | feat(forms): 接入阿罗拉六尾家族并验证第二个地区形态族群 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #233 `bcf71f5e48` | feat(pokedex): 完成地区形态图鉴详情页通用切换 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #234 `a4ff6a7361` | refactor(pokedex): 精简地区形态图鉴数据并修复拉达种族值切换 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #235 `a3d5309369` | feat(forms): 批量接入阿罗拉地区形态并补全图像与图鉴数据 | 依赖暂缓 | 成组暂缓 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #236 `eaaee9e854` | refactor(pokemon): 压缩精灵基础数据并保留独立扩展能力 | 需评估 | 需求待选 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #237 `ddc2e90a64` | fix(party): 珍稀糖果升级音效结束后自动显示能力值 | 需评估 | 需求待选 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #238 `d1b8af1431` | feat(hof): 优化重复通关结算并恢复联盟挑战后队伍状态 | 需评估 | 需求待选 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #239 `cb4c757e7f` | refactor(battle): 清理固定 Hard 与 Set 规则下的无效战斗代码 | 当前不适用 | 不直接适用 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #240 `d3b0ef2a54` | refactor(trainer): 去重训练师AI配置并修复TM兼容判断 | 部分实现 | 只核剩余差异 | [211-240.md](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| #241 `7ac76eea72` | refactor(names): 压缩精灵名称并保留原有查找契约 | 依赖暂缓 | 成组暂缓 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #242 `09b2f68f13` | refactor(mapping): 精简图鉴与配色映射并保留独立扩展能力 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #243 `2e44c350d3` | refactor(learnset): 压缩升级技能数据并保留独立扩展能力 | 依赖暂缓 | 成组暂缓 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #244 `6529e674ca` | refactor(cries): 压缩精灵叫声头并保留完整参数扩展能力 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #245 `4604fbeca6` | refactor(trainers): 压缩训练师名称并保留独立队伍扩展能力 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #246 `ff902a940d` | refactor(gym): 固定枯叶道馆双锁并精简垃圾桶逻辑 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #247 `5874323098` | refactor(bike): 精简自行车店不可达购买流程 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #248 `539ca1a8ee` | refactor(saffron): 合并饮料关卡逻辑并修正推回状态 | 待核验 Bug | 先复现 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #249 `2a4fd51f6a` | refactor(elite4): 合并四天王房间入口自动行走逻辑 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #250 `da7a81447d` | refactor(hm4): 精简金牙兑换 HM04 中间状态 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #251 `b39374921c` | refactor(gamecorner): 合并免费代币赠送逻辑并修正上限判断 | 待核验 Bug | 先复现 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #252 `f25f108984` | refactor(pewter): 精简博物馆向导并保留道馆带路 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #253 `13790b8741` | refactor(tutorial): 精简老人抓捕教学并移除专用伪战斗流程 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #254 `222cb08740` | refactor(fossil): 简化化石复活并移除实验室等待状态 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #255 `05e82b173c` | refactor(maps): 移除冗余地图脚本包装并直接使用共享文本框逻辑 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #256 `3a5a73a626` | refactor(trainers): 压缩训练师头并移除重复结束文本指针 | 依赖暂缓 | 成组暂缓 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #257 `1e993752d2` | fix(trainers): 初始化普通训练师败北结束文本指针 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #258 `8b69209605` | refactor(trainers): 合并普通训练师文本入口 | 依赖暂缓 | 成组暂缓 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #259 `9eb200b133` | maintenance(events): 同步事件与内存地址备注 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #260 `c79eb8ecfd` | refactor(trainers): 合并训练师地图脚本分派逻辑 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #261 `605119fc93` | refactor(silph): 合并 Silph Co. Card Key 门处理逻辑 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #262 `99d158e3ec` | refactor(warps): 移除重复的地图传送目标位置数据 | 依赖暂缓 | 成组暂缓 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #263 `218595bd23` | refactor(text): 合并 PrintText 与 TextScriptEnd 公共尾部 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #264 `a23938475c` | refactor(gyms): 合并馆主徽章与 TM 奖励流程 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #265 `32e79e2615` | fix(battle): 修复技能动画破坏中毒文本与回血显示 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #266 `ca1d40d9e4` | fix(battle): 阻止已濒死行动者继续结算回合末残余伤害 | 待核验 Bug | 先复现 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #267 `c8b2de5785` | refactor(text): 合并 PrintText 与 YesNoChoice 公共询问流程 | 需评估 | 需求待选 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #268 `698a509bef` | refactor(wondertrade): 移除 Wonder Trade 功能及专用资源 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #269 `—` | **缺号：交接包没有对应原始补丁** | 缺号 | 无原补丁，不推测 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #270 `68c9d6f848` | refactor(audio): 恢复有效 custom 曲目并预留独立音乐选择功能 | 当前不适用 | 不直接适用 | [241-270.md](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| #271 `2e60784dea` | fix(link): 修复联机摘要首开花屏并同步联机房名称 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #272 `52519a72ae` | feat(audio): 新增 GB Player 并支持 RBY/GSC/custom 曲目试听 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #273 `8b0d2c5bf6` | feat(audio): 将 GB Player 界面与 MoveDex 对齐并完善菜单交互 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #274 `d12dc2301a` | feat(audio): 在设置中添加音乐风格切换并支持 Custom/Random | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #275 `814d4dba60` | fix(audio): 移除重复 GSC 映射并修正 Random 候选 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #276 `d3a1e92dcd` | feat(audio): 扩展 Random 模式并支持多候选 BGM 池 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #277 `f6cc3367b5` | fix(battle): 修复 Dynamic Punch 与 Nuzzle 副作用动画及失败停顿 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #278 `ffe486fe5f` | fix(town-map): 区分未知地点文本在不同界面的显示 | 待核验 Bug | 先复现 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #279 `3049bad5da` | fix(battle): 修正能力大幅变化文本的重复停顿 | 待核验 Bug | 先复现 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #280 `91c532d36b` | fix(menu): 优化技能服务与改名流程的逐级返回 | 部分实现 | 只核剩余差异 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #281 `8dc5129a23` | fix(menu): 简化姓名鉴定改名确认流程 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #282 `fc064b6bba` | feat(intro): 优化新游戏开场流程 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #283 `0c89fcca7f` | fix(intro): 修复 Oak 开场调色板残留 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #284 `3db7017063` | feat(battle): 平滑连续投射物战斗动画 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #285 `9dfb554632` | feat(battle): 平滑捕获球与投掷类抛物线动画 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #286 `8c4b2eb4ca` | feat(battle): 重做吸取系动画节奏并恢复回流重力感 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #287 `6a7e59b3d5` | feat(battle): 完善分段动画桥接并修复 Acid 切换 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #288 `7bd9c65d3d` | feat(battle): 实现 Shadow Punch 跨阶段残留与命中特效同步 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #289 `c3c8aeffd1` | feat(menu): 新增 Party 与 Bag 菜单快捷操作 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #290 `5d6c4d456f` | feat(battle): 补充 Fly / Dig 半无敌状态特殊招式交互 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #291 `1e6a5eac78` | fix(battle): 修复 Fly / Dig 特殊命中后的异常显形 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #292 `82ce72f94d` | refactor(battle): 拆分暴击、特殊伤害与中毒效果逻辑 | 需评估 | 需求待选 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #293 `ef26e87ba5` | feat(battle): 重做 Wing Attack 与 Drill Peck 动画 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #294 `3e3ffdbb6e` | feat(battle): 完善 Sludge 与 Acid 分段动画 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #295 `bd71e753e8` | refactor(battle): 复用 Sludge 滴落阶段并释放 Subanimation 槽位 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #296 `f75ba2832f` | refactor(battle): 释放 Wing Attack 的 Subanimation 槽位 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #297 `b6b7d07e21` | feat(battle): 加入 KEP Iron Head 并恢复对应学习列表 | 当前不适用 | 不直接适用 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #298 `70d3489f22` | fix(animation): 恢复闪焰冲锋、伏特攻击与终极冲撞旧版动画及音效语义 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #299 `d9573d1a1b` | fix(animation): 恢复 Gunk Shot 与 Poison Jab 旧版动画并完善毒系动态配色 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #300 `2e2ea4ee58` | fix(animation): 恢复多项旧版技能动画与特殊演出 | 依赖暂缓 | 成组暂缓 | [271-300.md](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| #301 `f93ce84750` | fix(animation): 修复暗影拳敌方使用时命中特效错位 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #302 `2b9c167d15` | fix(animation): 将污泥波替换为污泥爆弹并还原金版演出 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #303 `47cbca58f0` | fix(animation): 还原金银版空中爆破完整演出 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #304 `d97fa46b7e` | fix(animation): 还原金银版爆裂拳爆炸演出 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #305 `4546ae9660` | feat(move): 加入 Sacred Fire 并还原金银版完整演出 | 需评估 | 需求待选 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #306 `57b1f6c56e` | fix(animation): 优化暗影拳并融合金版电光一闪前序演出 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #307 `b48784c4aa` | fix(animation): 还原金银版 Flame Wheel 演出并修正本方受击反馈 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #308 `fe13528446` | fix(animation): 还原金银版 Cross Chop 并修复全帧横向震屏 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #309 `272ed3e001` | fix(animation): 还原金银版 Crunch 并整理受击反馈例外 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #310 `b6839f5620` | feat(move): 将 Razor Wind 替换为 Spark 并还原金银版完整演出 | 需评估 | 需求待选 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #311 `2c353bac1e` | feat(move): 强化 Egg Bomb 并还原金银版完整演出 | 需评估 | 需求待选 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #312 `39f72b7701` | fix(animation): 修复 Acid 与 Sludge 敌方分段动画轨迹错位 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #313 `2e3ec812c1` | fix(animation): 还原金银版 Icy Wind 并修复目标波纹重叠 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #314 `0ed2664a81` | fix(animation): 修复 Icy Wind 上方波纹边界串入本方 HUD | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #315 `54417b9a63` | fix(animation): 修复 Icy Wind 本方宝可梦下沿波纹 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #316 `febfd57ee1` | fix(animation): 修复 Icy Wind 对方宝可梦顶部波纹 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #317 `623af1465b` | fix(animation): 修复 Icy Wind 对方宝可梦下沿波纹 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #318 `e33c962141` | feat(animation): 将 Dragon Pulse 替换为金银版 Dragon Rage 波动演出并平滑降速 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #319 `5f0ba08a70` | refactor(animation): 压缩 Dragon Pulse 减速坐标表为 20 帧周期 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #320 `366ce0dba4` | fix(animation): 修正 Shadow Ball 金银版投射轨迹 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #321 `128b4ea8e7` | fix(animation): 重制 Earth Power 并还原 Polished Crystal 三段喷发演出 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #322 `22a0481481` | feat(move): 将 Petal Blizzard 正式替换为 Energy Ball 并移植 Polished Crystal 动画 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #323 `4c739acd95` | fix(animation): 完成 Iron Tail 金版摆动并修正敌方命中反馈 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #324 `0d3ca2bad7` | fix(animation): 完整移植 Gold/Crystal Iron Tail 并收口扫描线、前奏与命中反馈 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #325 `8ec82d006a` | fix(animation): 修复 Iron Tail 换人后目标下沿空白 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #326 `08554aa91a` | feat(animation): 移植 Gold/Crystal Bone Club 与 Bonemerang 骨棒动画 | 需评估 | 需求待选 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #327 `9889bec65b` | feat(animation): 移植 Polished Crystal Gunk Shot 动画 | 依赖暂缓 | 成组暂缓 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #328 `758cef5fdb` | perf(menu): 轻量化 START 菜单并完善子菜单返回显示时序 | 部分实现 | 只核剩余差异 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #329 `af0fe260e2` | fix(forms): 稳定地区形态身份并修复捕获后首次图鉴展示 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #330 `3f1662b444` | feat(forms): 补全联机交换与名人堂地区形态显示 | 当前不适用 | 不直接适用 | [301-330.md](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| #331 `972de8d6dc` | fix(pc): 修复名人堂电脑退出后的地图花屏 | 待核验 Bug | 先复现 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #332 `29f17bdf82` | fix(pc): 优化名人堂电脑轮播切换显示 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #333 `c69bca0727` | fix(forms): 补全 Transform 地区形态继承 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #334 `39aba8363f` | fix(capture): 修复变身后捕获物种识别错误 | 已实现 | 不重复移植 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #335 `23c9867a02` | fix(transform): 阻止重复及同身份变身并稳定 Transform 配色 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #336 `a92186be32` | fix(battle): 统一失败文字节奏并补充技能说明 | 待核验 Bug | 先复现 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #337 `5b55c92267` | feat(forms): 补全训练家、礼物、NPC交换与地区进化形态生产链 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #338 `aa9af3ca30` | feat(forms): 固化随机野生遭遇的地区形态实例身份 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #339 `e9bcb3f871` | feat(forms): 固化初始宝可梦的显式地区形态身份 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #340 `37d0c72beb` | feat(forms): 固化钓鱼与撞树遭遇的地区形态实例身份 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #341 `c7822e33ca` | feat(forms): 固化固定野怪遭遇的地区形态实例身份 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #342 `1fcc440106` | feat(forms): 增加地区形态持久标记的编译期防撞检查 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #343 `00fb1931c5` | feat(forms): 固化培育产生宝可梦的地区形态实例身份 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #344 `5d542adde1` | docs(todo): 建立当前路线图并校正 TM 状态说明 | 当前不适用 | 不直接适用 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #345 `e4e12c03ef` | feat(evolution): 增加冰之石并完善进化石等级门槛流程 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #346 `15e52a9d8a` | feat(items): 完善队伍消耗道具连续使用流程 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #347 `5dda2fb671` | feat(menu): 收口队伍PP道具与TM教学的菜单显示和返回流程 | 部分实现 | 只核剩余差异 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #348 `4ec23173ca` | feat(animation): 移植 Polished Crystal Hurricane 暴风动画并收口运行验证 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #349 `01031fd728` | feat(animation): 重制 Sucker Punch 突袭动画并使用 Dark 命中配色 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #350 `495c8557e0` | feat(battle): 补全 Sucker Punch 突袭的现代失败判定 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #351 `d706e39e61` | feat(battle): 引入多级招式优先度并区分 ExtremeSpeed | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #352 `694c46e7f7` | feat(move): 将 Rolling Kick 替换为 Aura Sphere 并移植专属动画 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #353 `306a28f605` | feat(animation): 移植 Gold/Crystal 金属翼动画并完成实机验收 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #354 `17799318cc` | feat(battle): 完善伤害型能力副作用与初代 Special 平衡并完成验收 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #355 `afc05dc6c1` | feat(battle): 完善反伤比例与火推电推状态效果并完成本轮验收 | 部分实现 | 只核剩余差异 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #356 `2d4ee184fd` | feat(battle): 修正替身多段攻击与反伤结算时序并完成本轮验收 | 待核验 Bug | 先复现 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #357 `d6671c9232` | feat(animation): 完善伏特攻击三档动态中心及首尾电流轨迹并完成验收 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #358 `86439bcf46` | feat(ui): 融合首批黄版／金银队伍小图标并完成本轮验收 | 需评估 | 需求待选 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #359 `96a0e6747a` | feat(ui): 引入队伍小图标动态加载框架并修复换位白闪，完成本轮验收 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #360 `d452e78567` | feat(ui): 引入金版洛奇亚与凤王专属队伍小图标并完成本轮验收 | 依赖暂缓 | 成组暂缓 | [331-360.md](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| #361 `7c6d221201` | feat(ui): 完成第三批金版队伍小图标验收并统一映射表列对齐 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #362 `9082e265e9` | feat(ui): 完成第四批金版队伍小图标验收，收口 ICO-5.62.60 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #363 `df86a74c72` | feat(ui): 完成第五批队伍小图标细分类验收，收口 ICO-5.62.61 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #364 `c19a949a76` | feat(ui): 完成第六批队伍小图标精选细分与两代素材去重验收 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #365 `b299b93176` | feat(ui): 按用户208只图鉴表完成队伍小图标最终定稿（ICO-5.62.63） | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #366 `7fac6e3631` | feat(overworld): 完成皮卡丘／拉普拉斯／普通冲浪图像分流验收（SRF-5.62.64） | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #367 `b738199c2e` | feat(overworld): 完成飞天宝可梦图标分流与性别主题色验收 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #368 `b10f19faa1` | feat(animation): 移植 Ruby 风格高音双圆环 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #369 `a637809464` | feat(animation): 移植 Lovely Kiss 九锚点逐帧轨迹基础 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #370 `9144efb7eb` | feat(animation): 优化 Lovely Kiss 逐帧节奏和波峰过渡 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #371 `b177a89a0e` | feat(animation): 定版 Lovely Kiss 近大远小双波浪 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #372 `82c7025753` | feat(animation): 定版 Draining Kiss 双波浪与吸收衔接 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #373 `812e0df1c1` | docs(todo): 整理历史交接资料并补充缺失待办（第1轮） | 当前不适用 | 不直接适用 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #374 `c0cae12cf2` | docs(todo): 整理游戏功能现状、未完成事项与后续计划 | 当前不适用 | 不直接适用 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #375 `7f3a60fbc7` | docs(todo): 整理游戏功能验收状态与后续专项 | 当前不适用 | 不直接适用 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #376 `7a10edff6b` | docs(todo): 补充游戏功能验收结论与待办边界 | 当前不适用 | 不直接适用 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #377 `3467e268fc` | feat(fly): 定版 START／SELECT 快捷定位并归档实测结果 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #378 `a7ee79fa3f` | feat(map): 定版普通 Town Map 快捷定位并归档实测 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #379 `4ac823723a` | feat(icon): 新增 PureRGB HUMANOID_INSECT 双帧队伍图标并整理待测记录 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #380 `dc908787bf` | fix(fishing): 修复背包连续钓鱼的对话框闪烁 | 当前不适用 | 不直接适用 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #381 `82679d123d` | feat(fishing): 增加岸边 SELECT 钓鱼与连续投竿询问 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #382 `b1ca7e4706` | feat(fishing): 增加三位赠竿 NPC 的重复交谈教学 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #383 `90843b3f5a` | feat(fishing): 支持冲浪 SELECT 钓鱼与背包换竿 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #384 `0e59dc0082` | feat(fishing): 增加冲浪上钩动画与 HM03 重复教学 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #385 `57ab81bc8d` | fix(fishing): 复用连续投竿文本窗口并移除重复初始化 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #386 `7f90f54cea` | feat(anim): 定版聚宝功金币旋转投掷与金银版音效并清理后续待办 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #387 `d800b30af4` | feat(anim): 完善垃圾射击毒液汇聚与三次闪烁喷发 | 依赖暂缓 | 成组暂缓 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #388 `60ec1a2667` | feat(anim): 将 Barrage 替换为种子机关枪并加入逐击投射动画 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #389 `4da3adceb0` | feat(anim): 为敌方多段攻击加入逐击短横震反馈 | 需评估 | 需求待选 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #390 `5d3fca8915` | fix(battle): 修复双针逐击中毒判定与替身保护 | 待核验 Bug | 先复现 | [361-390.md](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| #391 `ecc56963c1` | feat(anim): 为双针加入双向对称粗针与独立双轨飞行动画 | 需评估 | 需求待选 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #392 `5a3b8b2987` | feat(gfx): 恢复所选宝可梦战斗图并独立保存地区形态素材 | 需评估 | 需求待选 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #393 `00e8568f11` | feat(forms): 接入九种地区形态并整理占位数据与后续验收 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #394 `9030352fff` | feat(forms): 追加地区形态并完成种族值与图鉴体型校正 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #395 `a9440aca13` | fix(pal): 定版旧版验证配色并整理地区形态维护记录 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #396 `da4513cb64` | feat(dex): 建立地区形态独立记录底座并完善交付规范 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #397 `ec9f8081bb` | feat(dex): 扩展地区形态独立记录容量至 128 个身份 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #398 `2834fd4e5e` | feat(dex): 接入实际战斗的地区形态独立 Seen 登记 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #399 `5abf1cf0b5` | feat(dex): 完成地区形态捕获与图鉴独立解锁并收口验收记录 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #400 `89694af4d1` | feat(dex): 图鉴精灵球区分地区形态收集完整度并完成 119 修复与验收收口 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #401 `0ce0b96768` | feat(dex): 收口地区形态野外捕获标记与各形态首次捕获图鉴弹出 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #402 `d74f3a0e3d` | feat(dex): 收口图鉴正背切换、朝向保持与图片刷新时序 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #403 `584b1ba896` | feat(dex): 收口图鉴正背浏览并保留 Party/PC 临时查看，恢复捕获图鉴原流程 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #404 `88853cab99` | feat(dex): 补全赠送、进化与交换的地区形态图鉴登记 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #405 `ac1612cea3` | feat(dex): 定版大木博士地区形态研究统计并修复文本翻页 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #406 `d5092e2864` | feat(intro): 恢复 Mateo 首页常驻并收口主菜单加载优化 | 部分实现 | 只核剩余差异 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #407 `7a89953cdc` | fix(audio): 修复开场跳过音效残留与低血量招式命中声衔接 | 当前不适用 | 不直接适用 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #408 `79f1f6b473` | refactor(audio): 清理电梯与训练师战倒下音效的旧等待逻辑 | 当前不适用 | 不直接适用 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #409 `86e7d405e3` | feat(battle): 定版 Volt Tackle 双向命中高频横震 | 当前不适用 | 不直接适用 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #410 `162fd29ef7` | feat(battle): 收口第一批招式效果与吸取之吻替身结算 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #411 `01a9feaffc` | feat(animation): 收口毒击 Quick Attack 独立动画移植 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #412 `549504790a` | feat(animation): 收口毒击 Quick Attack 独立动画移植 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #413 `f18b044b4e` | feat(battle): 收口虫咬家族映射及双向横向受击反馈 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #414 `710dbf8ceb` | feat(battle): 收口岩石打磨共用高速移动 ID 与战斗独立表现 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #415 `6107848052` | feat(move): 收口岩石打磨战斗外名称映射与菜单显示 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #416 `c9d97b93df` | feat(move): 收口岩石打磨 PP 道具名称显示与战斗回合待办 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #417 `8b41b7a139` | fix(item): 收口战斗 PP 回复回合与连续用药升级界面显示 | 待核验 Bug | 先复现 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #418 `437b285e68` | feat(move): 收口双表招式扩容原型与双招学习战斗回忆 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #419 `ab20fd0567` | feat(move): 收口十招扩容及回忆师候选列表修复 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #420 `6b2e65496d` | feat(move): 收口二十招容量试验及扩展学习回忆显示 | 依赖暂缓 | 成组暂缓 | [391-420.md](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| #421 `60b3970b51` | feat(move): 收口四十招独立扩容并移除临时升级测试分配 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #422 `23858fc8b5` | fix(move): 收口扩展技能身份隔离与普通升级回归修复 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #423 `f54c194013` | refactor(move): 收口地区形态身份隔离与普通／地区统一学招入口 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #424 `e56805e96a` | fix(move): 收口 TM/HM／教学师普通招式的扩展身份判重 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #425 `449717df44` | fix(move): 收口玩家变身后的扩展招式身份同步 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #426 `1d1628fe05` | refactor(move): 单独收口 182B 当前出招身份公共加载及 098 槽位修正 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #427 `ebbac18868` | fix(move): 183 为敌我扩展招建立完整身份伤害分类基础 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #428 `ea163ba9a4` | fix(move): 收口双向派生招式扩展身份传递 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #429 `60e8832b8b` | fix(move): 收口敌方扩展招式身份记录与原生来源 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #430 `af8beef2e5` | fix(move): 收口共用追加异常状态跨 Bank 传参与三拳验收 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #431 `8f9265ccba` | fix(move): 收口扩展招式会心与飞天身份撞号专项验收 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #432 `5fccba7371` | fix(move): 收口训练师 AI 扩展候选基础识别与评分修复 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #433 `103679501f` | feat(move): 支持扩展招式按等级学习与回忆 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #434 `73aad942dd` | feat(anim): 为扩展招式嬉闹加入专属战斗动画 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #435 `550e6cd5ce` | fix(anim): 嬉闹复用原版战斗音效 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #436 `52ab845da2` | feat(anim): 将嬉闹主体调整为 Gunk Shot 3/4 速度 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #437 `b795cba9fb` | feat(move): 嬉闹增加两项独立 10% 追加效果 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #438 `6f448d6915` | feat(anim): 移植 Power Gem 八石头动画并完成双向轨迹验收 | 依赖暂缓 | 成组暂缓 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #439 `66c9b058aa` | feat(move): 新增 Dynamic 分类并让 Spark 动态选择伤害类别 | 需评估 | 需求待选 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #440 `8030b0f2f1` | fix(battle): 收口 Dynamic Spark、Counter 真实受击和异常状态能力重算 | 待核验 Bug | 先复现 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #441 `eba1a803a7` | fix(battle): 完善能力等级限幅与 Counter 失败提示 | 部分实现 | 只核剩余差异 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #442 `3595661a0c` | fix(battle): 收口 Dynamic Spark、Counter 幽灵免疫与伤害边界保护 | 待核验 Bug | 先复现 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #443 `71d78a1a4a` | fix(battle): 收口替身多段提示与自伤反伤路由 | 待核验 Bug | 先复现 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |
| #444 `6d87cab1c7` | test(battle): 增加独立战斗测试 ROM 与集中测试入口 | 需评估 | 需求待选 | [421-444.md](RPP_REFERENCE_PORT_AUDIT_421-444.md) |

## 四、使用及维护边界

- **已实现**指“同目标已在 CHS 有实现或验收记录”，未必与 RPP 指令完全相同；**部分实现**不得一键认定全覆盖。
- **待核验**绝不等于存在确定故障；CHS 没有 Crystal Audio 等前置系统时，不为 RPP 衍生 Bug 引入该系统。
- 这份表是“选择与追踪索引”，**不取代**每笔报告的源码证据、风险及依赖链；后续发现误判时先更新所属分批原文，再更新汇总状态。
- 本次是纯文档整理；不更改 `src/`、游戏内版本号 `ROM-1.21`、MAP、ROM 或 Git 历史；不存在“已移植全部 442 笔”的结论。
