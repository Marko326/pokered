# RPP 参考提交分批移植审查索引

> CHS 当前正式源码：`ROM-1.21.zip`。参考总计 **442 笔**（编号 001～444，缺 072、269）。本索引用于逐批审查，不是全量核对已完成声明。

## 审查进度

| 批次 | 参考提交范围 | 实际条数 | 状态 | 文档 |
|---|---|---:|---|---|
| 01 | 001～030 | 30 | **已完成第一轮静态对照，等待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_001-030.md`](RPP_REFERENCE_PORT_AUDIT_001-030.md) |
| 02 | 031～060 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_031-060.md`](RPP_REFERENCE_PORT_AUDIT_031-060.md) |
| 03 | 061～090 | 29（#072 缺号） | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_061-090.md`](RPP_REFERENCE_PORT_AUDIT_061-090.md) |
| 04 | 091～120 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_091-120.md`](RPP_REFERENCE_PORT_AUDIT_091-120.md) |
| 05 | 121～150 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_121-150.md`](RPP_REFERENCE_PORT_AUDIT_121-150.md) |
| 06 | 151～180 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_151-180.md`](RPP_REFERENCE_PORT_AUDIT_151-180.md) |
| 07 | 181～210 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_181-210.md`](RPP_REFERENCE_PORT_AUDIT_181-210.md) |
| 08 | 211～240 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_211-240.md`](RPP_REFERENCE_PORT_AUDIT_211-240.md) |
| 09 | 241～270 | 29（#269 缺号） | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_241-270.md`](RPP_REFERENCE_PORT_AUDIT_241-270.md) |
| 10 | 271～300 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_271-300.md`](RPP_REFERENCE_PORT_AUDIT_271-300.md) |
| 11 | 301～330 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_301-330.md`](RPP_REFERENCE_PORT_AUDIT_301-330.md) |
| 12 | 331～360 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_331-360.md`](RPP_REFERENCE_PORT_AUDIT_331-360.md) |
| 13 | 361～390 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_361-390.md`](RPP_REFERENCE_PORT_AUDIT_361-390.md) |
| 14 | 391～420 | 30 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_391-420.md`](RPP_REFERENCE_PORT_AUDIT_391-420.md) |
| 15 | 421～444 | 24 | **已完成静态对照，待维护者确认** | [`RPP_REFERENCE_PORT_AUDIT_421-444.md`](RPP_REFERENCE_PORT_AUDIT_421-444.md) |

> 注：第二批之后按**实际存在的 30 笔补丁**连续编排；因为缺少历史 #072、#269，后续批次的首尾编号需按原参考目录计算，不能把缺号当成提交。

## 审核口径

1. 每次只处理一批，每笔记录编号/Hash、参考改动、CHS 对应证据、状态、处理建议及风险。先参考原始补丁，再查 CHS 源码与历史；不得只看标题猜测。
2. 标记为**已实现、部分实现、待核验、需评估、当前不适用、依赖暂缓**。CHS 未出现的 RPP Bug 不能认作 CHS 的待修复项；新增玩法必须由维护者确定需求。
3. 只要已有相同目标就记录证据，避免重复移植；如果差异仍存在则只评估差异。复杂重构要列出前置提交与额外验证成本。
4. 完成一批、用户审阅一批，再把状态纳入累计台账。前序的结论可根据新的源码/用户反馈修正，并记录原因。
5. 本轮仅更新 `docs/`；**不修改 `src/`、游戏版本、地图数据，也不做 Git Commit/Push**。如后续明确要实现某功能，应另行制作代码补丁并遵守正式项目交付规则。

## 当前批次

- [001～030：第一批详细审查](RPP_REFERENCE_PORT_AUDIT_001-030.md)
- [031～060：第二批详细审查](RPP_REFERENCE_PORT_AUDIT_031-060.md) — 已完成静态对照，等待维护者确认。
- [061～090：第三批详细审查](RPP_REFERENCE_PORT_AUDIT_061-090.md) — 29 笔原始补丁；#072 缺号，明确保留占位。
- [091～120：第四批详细审查](RPP_REFERENCE_PORT_AUDIT_091-120.md) — 30 笔提交已静态对照，重点区分新功能与参考衍生 Bug。
- [121～150：第五批详细审查](RPP_REFERENCE_PORT_AUDIT_121-150.md) — 30 笔已完成源码静态对照，重点区分实时 Summary 与新扩展动画依赖。
- [151～180：第六批详细审查](RPP_REFERENCE_PORT_AUDIT_151-180.md) — 30 笔静态对照；重点为 #177 图块长度、#180 NPC 数据边界、#173 数字指针风险。
- [181～210：第七批详细审查](RPP_REFERENCE_PORT_AUDIT_181-210.md) — 30 笔静态对照；#195 HM 电脑存储、#207 Thrash 失败解除、#201～202 HP 动画已实现。
- [211～240：第八批详细审查](RPP_REFERENCE_PORT_AUDIT_211-240.md) — 30 笔；#219 已实现，#221/#237 待实测，#240 TM index 预防核验。
- [241～270：第九批详细审查](RPP_REFERENCE_PORT_AUDIT_241-270.md) — 29 笔原始补丁，#269 缺号；#248/#251/#266 待核验，#244/#270 依赖参考音频系统。
- [271～300：第十批详细审查](RPP_REFERENCE_PORT_AUDIT_271-300.md) — 30 笔原始补丁；#278/#279 需核验，#272～276 是 Crystal Audio/GB Player 连续链。
- [301～330：第十一批详细审查](RPP_REFERENCE_PORT_AUDIT_301-330.md) — 30 笔原始补丁；#328 START 部分实现，#310/#311 为玩法规则更改，#326 可选动画升级。
- [331～360：第十二批详细审查](RPP_REFERENCE_PORT_AUDIT_331-360.md) — 30 笔原始补丁；#334 已修、#336 Transform 目标隐藏状态待核验、#346～347 道具菜单 QoL、#358～359 Party 图标成组评估。
- [361～390：第十三批详细审查](RPP_REFERENCE_PORT_AUDIT_361-390.md) — 30 笔；#390 双针/替身判毒优先核查，#380/385 属 RPP 连续钓鱼的衍生修复，#377～378 为可选地图快捷键。
- [391～420：第十四批详细审查](RPP_REFERENCE_PORT_AUDIT_391-420.md) — 30 笔；#417 战斗 PP 道具优先复现，#406 主菜单性能仅部分实现；#392～405 地区形态、#418～420 扩容招式暂缓。
- [421～444：第十五批详细审查](RPP_REFERENCE_PORT_AUDIT_421-444.md) — 24 笔，#440～443 混合原版战斗问题与扩展功能，#421～438 依赖扩招身份系统。
- [001～444 第一轮汇总与优先修复建议](RPP_REFERENCE_PORT_AUDIT_TRIAGE_001-444.md) — 15 批静态分类完成，等待维护者选定目标。

## 第一轮审核闭环

- 本地参考目录按 `#001～#444` 编号，其中 #072、#269 缺号，因此已逐批评估 **442 笔**实际提交；15 批静态分类结束。
- 第一轮只判定有无现有实现、对应源码和依赖，**不代表 442 笔均已在 CHS 运行验证**；按 `RPP_REFERENCE_PORT_AUDIT_TRIAGE_001-444.md` 选定后再独立修复或移植。
