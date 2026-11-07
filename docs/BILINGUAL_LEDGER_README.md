# 双语项目盘点台账说明

这些 TSV 是 `docs/BILINGUAL_PROJECT_PLAN.md` 的可筛选明细，不是补丁，也不表示表内所有条目已完成验收。

- `BILINGUAL_COVERAGE_MASTER.tsv`：翻译标签清单、源码级引用位置和初步状态。引用扫描不是完整运行时调用证明。
- `BILINGUAL_SCREEN_COMPONENT_MATRIX.tsv`：将同一画面拆成独立文本组件。
- `BILINGUAL_MAP_NAME_ENTRY_AUDIT.tsv`：地图名称相关 selector、数据表和图形入口分组清单；尚非最终 map-ID 交叉表。
- `BILINGUAL_MODULE_ROADMAP.tsv`：阶段、优先级和退出标准。
- `BILINGUAL_UNINDEXED_SURFACES.tsv`：未完全包含在普通 `text_far` 标签清单中的独立资源面。
- `DATA_XLSX_IMPORT_OPERATIONS.tsv`：`data.xlsx` 导入规则逐行记录；操作行数不等于唯一文本数量。
- `DATA_XLSX_SHEET_SUMMARY.tsv`、`DATA_XLSX_SUMMARY.tsv`：按工作表和规则类型汇总。

更新台账时必须同时更新总计划和 TODO 当前状态；不要只更新一个数字而不说明统计口径。

## 阶段1地图名称系统审计

- `BILINGUAL_MAP_IDENTITY_CROSSWALK.tsv`：248 个物理 map ID 与 Town Map/Fly/CGB 的逐项交叉表。
- `TOWNMAP_ORDER_CROSSWALK.tsv`、`MAP_NAME_INTERNAL_RANGES.tsv`：TownMap selector 与 60 条内部地图范围。
- `FLY_DESTINATION_CROSSWALK.tsv`、`FLY_PLAYER_MARKER_OVERRIDES.tsv`、`FLY_UNLOCK_CONDITIONS.tsv`、`ROUTE20_SEAFOAM_LOGICAL_CLASSIFICATION.tsv`：Fly 目的地、坐标 marker、解锁和逻辑区域规则。
- `CGB_MAP_SIGN_MAP_ID_CROSSWALK.tsv`、`CGB_MAP_SIGN_LABEL_ASSETS.tsv`：CGB 地名牌 map ID 与 107 个 1bpp label 资产。
- `MAP_NAME_STRING_SOURCES.tsv`、`MAP_NAME_UI_COMPONENTS.tsv`、`TOWNNAMES_GYM_SCRIPT_LITERALS.tsv`：地点名称、UI 字符串和 Gym 脚本文字分类。
- `MAP_NAME_DISPLAY_WIDTH_AUDIT.tsv`、`MAP_NAME_DISPLAY_CONSUMERS.tsv`、`MAP_NAME_SPECIAL_SELECTORS.tsv`：renderer 宽度、调用链和特殊 selector。
- `MAP_NAME_SYSTEM_AUDIT_ROM142B.md`：阶段1地图名称系统只读审计报告。
