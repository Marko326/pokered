# 全游戏双语化总计划与维护规程

**项目：** pokeredCHS / `CHS_Mod`
**当前正式版本：** ROM-1.42（由开发候选 ROM-1.42B 正式清理）
**计划状态：** 持续维护；本文件是双语化工作的唯一总计划入口
**最近整理：** 2026-11-07

> 本计划是项目内的路线图和范围控制文件，不替代 `RPP_PROJECT_CONTEXT/03_PROJECT_REQUIREMENTS.txt` 中生效的交付、构建与 Git 规则。RPP 上下文目录属于导出快照，不在这里直接修改。

**修订记录：** 2026-11-07 整合双语路线图与 ROM-1.42B 盘点台账；完成 ROM-1.42B → ROM-1.42 正式版号清理；阶段1首轮地图身份 crosswalk 已建立；ROM-1.42C 试验撤销作为跨 Bank 参数回归案例记录。

## 1. 项目目标与开发原则

目标是在不破坏原有中文体验、存档兼容和红/蓝版本行为的前提下，为游戏各文本系统逐步增加 English 显示。当前已有 LANGUAGE 选择和共享双语文本读取机制，但**LANGUAGE 能切换不代表全游戏已经双语化**。

后续开发遵守以下原则：

1. **按文本系统和真实调用入口分类，不按画面位置临时修补。** 同一画面可以有固定标签、动态地点、名称表、引擎对白、数字变量和图形文字等多种来源。
2. **先盘点、后设计、再成批实施。** 不采用“发现一处中文就改一处”的零散方式；一个模块先列全消费者和共享数据，再确定统一方案。
3. **一个文本组件一个状态。** 只有画面内全部文本槽位都完成并通过相应验收，才可称该画面双语化完成。
4. **数据身份与显示界面分离。** 例如地点名称由地图 ID/逻辑地点身份决定，Continue、Save、Town Map、Fly、Pokédex AREA 各自负责渲染；不能为每个页面复制一份地点判断。
5. **复用现有基础设施。** 优先复用 `text_bilingual`、`scripts/generate_bilingual_dialogue.py`、`scripts/prepare_build.py` 和现有 XLSX 导入流程；除非证明无法扩展，不另造重复生成器。
6. **动态内容不能被静态替换破坏。** 玩家名、物种名、招式名、物品名、数量、RAM 文本、脚本命令和特殊字典扩展必须保留其语义。
7. **语言设置与名称设置不能擅自合并。** `wOptions` LANGUAGE bit 5 与 `wENGNameMark` 是不同设置；按 `docs/NAME_LANGUAGE_COMPATIBILITY.md` 处理旧存档、自定义昵称和进化改名。
8. **静态检查、构建和实机测试分开记账。** 单元测试通过不等于 ROM 链接成功；MAP 存在不等于对应当前源码；局部录像不等于全红/蓝、DMG/CGB 全矩阵验收。
9. **保持用户明确的范围决定。** 共用 YES/NO 选择框继续暂缓，除非用户重新授权。

## 2. 项目文件职责：避免多份计划互相冲突

| 文件 | 唯一职责 | 更新时机 |
|---|---|---|
| `TODO.md` | 当前候选状态、最重要待办、按 ROM 版本保留的历史记录 | 每轮开发/验收收口时更新顶部当前状态；历史条目不随意重写 |
| `docs/BILINGUAL_PROJECT_PLAN.md` | 全游戏双语化总路线、模块边界、阶段门槛和进度口径 | 每次模块范围或阶段状态变化时更新 |
| `docs/BILINGUAL_PROJECT_AUDIT_ROM142B.md` | ROM-1.42B 快照的盘点证据、数量口径、已知风险 | 新一轮全量审计时新增版本记录，不覆盖历史快照 |
| `docs/BILINGUAL_COVERAGE_MASTER.tsv` | 翻译标签、来源文件、源码引用位置、状态 | 每次新增/接入/复核标签时更新 |
| `docs/BILINGUAL_SCREEN_COMPONENT_MATRIX.tsv` | 页面拆分后的文本槽位与来源分类 | 每发现新的页面组件或共享消费者时更新 |
| `docs/BILINGUAL_MAP_NAME_ENTRY_AUDIT.tsv` | 地图名称相关数据表、selector、特殊分支和图形资源入口 | 地图名称阶段继续审计时更新；目前是分组清单，不是最终 ID 交叉表 |
| `docs/MAP_NAME_SYSTEM_AUDIT_ROM142B.md` 及地图/Fly/CGB TSV | 阶段1地图身份、名称来源、renderer、宽度和 Bank 契约的只读证据 | 每次地图名称模块范围或映射变化时更新版本记录 |
| `docs/DATA_XLSX_IMPORT_OPERATIONS.tsv` 及摘要 | XLSX 导入规则逐行审计、版本范围和风险 | 导入器规则变化后重做审计 |
| `docs/BILINGUAL_MODULE_ROADMAP.tsv` | 模块优先级、状态、退出标准 | 模块开始/完成/暂缓时更新 |
| `docs/ROM141_MAP_DIALOGUE_BILINGUAL.md`、`docs/ROM142_POKEDEX_RATING_BILINGUAL.md`、`docs/ROM142B_PLAYER_INFO_BILINGUAL.md` | 各已实现模块的技术实现和测试证据 | 只更新对应模块事实，不承担全局路线图 |
| `docs/CHS_ACCEPTANCE_HISTORY.md` | 用户明确反馈的实测范围和验收历史 | 收到新的实测反馈时追加，不把未测项目标为通过 |
| `MAINTAINER_BUILD.md` | 维护者当前构建提示、当前候选状态和关键限制 | 当前候选或构建方式变化时更新 |
| `RPP_PROJECT_CONTEXT/` | RPP 自动生成的导出辅助信息 | 不直接编辑；由 RPP 下次导出刷新 |

**权威顺序：** 项目生效要求优先；本计划负责双语项目路线；TODO 负责当前待办索引；TSV 负责可筛选明细；单模块文档负责技术细节；验收历史只记录用户实际反馈。旧 ROM 章节保留为历史事实，不得把历史“待做”直接当成当前状态。

> **导出索引提示：** 本次新增的 docs 文件在 ROM-1.42B 导出后写入项目快照，因此随包 `RPP_PROJECT_CONTEXT/01_PROJECT_FILE_INDEX.txt` 可能仍是导出时的旧文件清单。不要手工修改 RPP 自动生成索引；下一次从 RPP 重新导出项目时会刷新。当前应以项目根目录 `TODO.md` 的链接和本文件中的文件职责表定位计划。

## 3. 当前基线与状态

### 3.1 基线

- 项目分支声明：`CHS_Mod`。
- 导出记录声明的 Git HEAD：`608a85501b97174401367f544427aaac60639e54`。
- 当前审计对象：用户提供的 ROM-1.42B ZIP 中的实际 Worktree 文件，并叠加本轮地图名称审计台账；ZIP 同时带有 `RPP_PROJECT_CONTEXT/patches/current_worktree.patch`。**Worktree 快照不能冒充干净 HEAD。**
- 导出记录声明 HEAD `608a85501b97174401367f544427aaac60639e54`；随包 Bundle 分支停在 `bd091a28...`，通过所附 003／004 Commit Patch 重建 608a8550 内容树后用于全量补丁核验。
- 当前正式版本目标为 ROM-1.42；开发候选 ROM-1.42B 的版号／Options 对齐已清理。ROM-1.42C 地点名称试验仍已撤销，不应用、不叠加。

### 3.2 已有双语能力与用户反馈

| 模块 | 当前事实 | 状态 |
|---|---|---|
| LANGUAGE / Options | 复用 `wOptions` bit 5，中文/English 设置页已建立 | 基础机制完成 |
| 地图脚本对白 | 1,944 条 `text_far` 中接入 1,942 条，覆盖 1,941 个唯一标签；另 2 条既有 English pilot wrapper | 源码接入完成；红/蓝最终构建与完整回归仍需按项目要求留证 |
| 图鉴统计/博士评价 | 19 个双语标签，含 16 档评价和 HOF 复用标签 | 用户录像确认所展示的英文场景；用户反馈中文模式正常；不代表所有分支/平台矩阵 |
| Continue/Save 固定标签 | PLAYER、BADGES、POKéDEX、TIME | 用户抽测未发现明显问题 |
| Trainer Card | NAME、MONEY、TIME、BADGES | 用户抽测未发现明显问题 |
| Hall of Fame 玩家统计 | PLAY TIME、MONEY；Seen/Owned/Rating 另走图鉴评价 wrapper | 用户抽测未发现明显问题；HOF 其他标签仍需独立盘点 |
| Continue/Save 当前地点 | 仍从汉化后的 Town Map 名称数据读取，English 下显示中文 | **已知未完成项；归入地图名称模块，不单独修页面** |

上述用户反馈只覆盖实际测试过的界面和路径，不等于红/蓝、DMG/CGB 全组合验收。

### 3.3 ROM-1.42C 撤销记录

`ROM-1.42C-current-location-fix.patch` 已按用户要求撤回：不应用、不叠加、不作为开发基线。该候选在实测中地点固定显示 `ROUTE 17`。

源码核对的故障机制：`farcall` 宏把目标 Bank 放入 B、目标地址放入 HL，再进入 `Bankswitch`；`Bankswitch` 将 A 改写为 B 中的 Bank 编号后跳入目标例程，因此调用前放在 A 中的 map ID 不会自动保留。C 候选调用目标 Bank `$1C`，而 `ROUTE_17` 的 map ID 恰为 `$1C`，于是被误当作当前地图 ID。以后跨 Bank 调用必须明确寄存器契约；不得假定 A/B/C/DE/HL 在宏调用后仍保留原值。

这次失败要作为负向回归案例：构造/检查跨 Bank 调用时 map ID 参数被 Bank 编号覆盖的情况，检查器必须能发现；不能复用 C 的页面专用实现。

## 4. 当前盘点数字与正确口径

### 4.1 翻译标签清单

| 指标 | 数量 | 解释 |
|---|---:|---|
| 当前 manifest 行 | 2,452 | 地图脚本、非地图引擎文本及人工补充标签的清单行 |
| 地图脚本双语标签 | 1,941 | 1,933 自动路由 + 8 个人工英文补充 |
| 非地图脚本范围 | 511 | 不是地图脚本生成器的直接覆盖范围 |
| 已双语的图鉴评价标签 | 19 | 17 个完成度/评价文字 + 2 个 HOF 复用统计 wrapper |
| 有源码级引用位置、待接入的非地图标签 | 486 | 按引用文件路径初步分类，需在模块实施前复核真实调用链 |
| 动态 token 需人工处理 | 1 | `_ChooseABoxText`，包含 `<PKMN>` |
| 暂无直接 ASM 引用的候选 | 5 | 只表示本轮文本扫描未找到直接引用，不得直接删除 |

地图脚本另外有 1,944 条 `text_far` 引用；两条既有 pilot wrapper 不在这 2,452 行 manifest 中。**标签行数、唯一标签数、脚本引用数和屏幕文本组件数是不同统计口径，不能相加或互相替代。**

486 个待处理标签的初步来源分类：

| 来源类别 | 标签数 |
|---|---:|
| 事件/隐藏物 | 150 |
| 战斗引擎 | 149 |
| 菜单/UI | 53 |
| 道具/商店/地图工具 | 48 |
| 宝可梦/队伍/PC | 26 |
| 过场/名人堂/交换 | 17 |
| 游戏厅/老虎机 | 14 |
| 公共文本/名称引擎 | 11 |
| 通信/交换 | 8 |
| 野外/Field Move | 6 |
| 道具 + 野外共享入口 | 3 |
| 公共文本 + 野外共享入口 | 1 |
| **合计** | **486** |

这是根据非定义 ASM 文件中的源码级文本引用和文件路径作出的初步分类；它不是完整控制流证明。实施某个模块前，仍须确认真正调用者、间接引用、共享 wrapper 和实际屏幕输出。

5 个暂未找到直接引用的标签：`_FuchsiaHouse3Text_56217`、`_HM02ExplanationText`、`_HM03ExplanationText`、`_Route12HouseText_564d4`、`_VermilionHouse2Text_560c5`。逐一确认宏、表指针、间接脚本或废弃状态后，才能更新状态。

### 4.2 data.xlsx 导入规则

当前盘点 `data.xlsx` 得到 951 条非空导入操作：898 条文本替换指令、53 条代码/格式/结构变更。898 条文本指令中，845 条属于当前 Red/Blue 构建范围，53 条为 RGB-only 并在 RB 构建时跳过。

845 条 RB 活动文本指令进一步分为：

- 23 条已有 LANGUAGE 双语分支（Options 13 条 + 玩家资料固定标签 10 条）；
- 199 条由独立 `wENGNameMark` / Names 选项控制（物种名 190 条 + 当前 RB 交易昵称 9 条）；
- 11 条公共 YES/NO 选项框规则，按用户决定暂缓；
- 612 条其他活动导入指令，需逐项核对实际文本、条件、重复键和所属模块。

这些是**导入器行级指令数**，不是唯一字符串数，也不等于需要翻译的文本条数。`Main` 工作表含版本分段、条件替换和非文本修改。

本轮临时副本导入器检查记录：4 条 `Not Found`（`English@`、`Chinese@`、`ver@`、`Now saving...@`）；`CANCEL@` 一条条件规则依赖当前目标文件中不存在的 `OptionMenuCancelText` 上下文；多个 `MISSINGNO.` 共用 replace-all 键，其中一个目标槽位期望「幽灵」、其他槽位期望「缺号」，存在后续规则只修改注释而未改目标数据的风险。

后续应在**现有导入器**上增加 stale-key、重复键冲突、条件未命中和 RB/RGB 范围检查；先设计负向用例，再决定工具修改。不要另建重复生成器。

### 4.3 其他独立资源面

| 资源 | 规模 | 说明 |
|---|---:|---|
| 地图名称表 | 53 | `data/maps/names.asm`；构建导入后为中文 |
| TownMapOrder | 52 selectors | 逻辑地点选择器，不是 ROM 地址 |
| ExternalMapEntries / InternalMapEntries | 37 / 60 | 外部地图与室内地图归属/名称映射 |
| SpecialFlyEntries | 13 | 特殊 Fly 目的地 |
| LoadTownMapEntry 特殊分支 | 7 | 特殊 selector/别名 |
| Town Map UI 字符串 | 4 | `To`、`'s`、`nest`、`AREA UNKNOWN` 等，不等同地点名 |
| Gym 脚本地点/训练家静态字符串 | 16 | `Townnames` 工作表中目标为 Gym scripts 的行 |
| CGB 地名牌图形标签 | 107 | 41 local + 47 ext A + 19 ext B；是图形资源 |
| CGB map-ID 映射 | 73 行 / 69 个唯一图形 label ID | 4 组房间/屋顶别名复用图形标签 |
| Pokédex 说明 / 元数据 | 各 151 | `dex.xlsx` 与 `dexEntry.xlsx`，两类不同字段 |
| 自定义道具短说明 | 79 个唯一块 / 83 个指针槽位 | Bag、PC、Mart 共用 CHS 字节数据 |
| Save/PC Box 名称 | 12 槽 | 盒名/前缀字形规则，不是普通地图文本 |
| 特殊地点硬编码名称 | 2 | Celadon Mart Roof 与 Fly Power Plant short name |
| Credits | 65 个文本记录 | 当前英文为主，需决定是否纳入双语范围 |

名称系统还需分别审计：招式名 165、道具名 97（另有 Route 23 的 7 条直接字符串）、训练家名 47（另有 16 个短名/类别入口）、属性名 16、玩家/宿敌默认名各 7。物种名 190 与当前 RB 交易昵称 9 由独立 Names 选项控制，不应误认为已经随 LANGUAGE 自动切换。

## 5. 统一文本分类模型

所有画面先拆成文本槽位，再为每个槽位指定类别、来源、消费者和测试证据。

| 类别 | 内容 | 常见来源 | 典型处理 |
|---|---|---|---|
| A 固定 UI | PLAYER、BADGES、菜单命令、按钮提示 | 菜单 ASM 字符串 | 按 LANGUAGE 选择静态标签 |
| B 地图/地点数据 | 城镇、道路、室内归属、楼层、特殊地点 | map ID、Town Map 表、逻辑 selector、CGB 地名牌 | 共享地点身份表，各 renderer 独立呈现 |
| C 动态数据 | 玩家名、金钱、徽章数、Seen/Owned、时间 | RAM/SRAM、`text_decimal`、`text_ram` | 数据读取不变，周边标签独立切换 |
| D 地图脚本文本 | NPC、路牌、事件、教学、训练家战前/战后对白 | `src/scripts/`、`text_far` | 复用现有 `text_bilingual` 生成流程 |
| E 引擎内部文本 | 战斗消息、图鉴评价、菜单提示、通信状态 | Battle/Pokédex/菜单/Link 引擎 | 按引擎独立接入，保留命令和控制流 |
| F 名称表 | 物种、招式、道具、训练家、类型、默认名字 | 独立名称表和名称读取函数 | 先定义 LANGUAGE 与 Names 兼容策略 |
| G 图形文字 | CGB 地名牌、图块中的文字 | 1bpp/2bpp 图像、VRAM tile | 独立英文图形资源或 renderer，不走普通字符串表 |

**同一画面示例：** Continue 页面至少包含固定 UI 标签（A）、当前地点名称（B）、玩家名/计数/时间（C）。所以固定标签已英文，不代表当前地点也已英文；整个页面不能提前标记为完整双语。

**同一数据示例：** 地图地点名称可能被 Continue、Save、Town Map、Fly 和 Pokédex AREA 共用；地点身份应只定义一次，再检查每个消费者。CGB 地名牌是图形 renderer，不能直接套普通字符串处理。

## 6. 分阶段路线图

### 阶段 0 — 全源入口盘点与登记（首轮已完成；关闭前仍需人工复核）

范围：manifest 标签、data.xlsx、名称表、dex 工作簿、图形文字、自定义道具说明、页面组件及真实消费者。

已完成：建立标签 master、导入器逐行清单、屏幕组件矩阵、地图名称入口清单、未索引资源清单和模块路线表。

关闭前剩余：核实 5 个无直接引用标签；扫描/登记 manifest 之外的 inline literals 和特殊 renderer；将“源码级引用”中真正的调用关系、间接表引用和共享消费者逐项复核。

退出标准：已知入口均有类别、来源、消费者、状态或明确的待确认理由；不同计数口径分开记录；无未分类文本被误标为完成。

### 阶段 1 — 地图名称系统（当前最高优先级；先只读设计）

必须一次盘点以下消费者：

1. Continue 当前地点；
2. Save 当前地点；
3. Town Map 当前选中地点；
4. Fly 城镇/特殊目的地名称与 Power Plant 短名称；
5. Pokédex AREA / nest 地点文字；
6. CGB 地名牌图形文字。

数据来源：`src/data/maps/names.asm`、`src/data/maps/town_map_order.asm`、`src/data/maps/town_map_entries.asm`、`src/engine/items/town_map.asm`、`src/engine/items/special_fly_locations.asm`、`src/engine/overworld/cgb_map_name_sign.asm`、`src/gfx/map_name_sign/` 及 `Townnames` 工作表。

首轮只读交叉表已于 2026-11-07 建立：`BILINGUAL_MAP_IDENTITY_CROSSWALK.tsv` 覆盖 248 个物理 map ID，并由 `TOWNMAP_ORDER_CROSSWALK.tsv`、`MAP_NAME_INTERNAL_RANGES.tsv`、Fly、CGB label 和 renderer 台账补齐逻辑身份。阶段1仍未完成：名称 variants、Fly 短名、CGB 英文图形/动态 renderer 仍需设计评审。

首轮审计结论（ROM-1.42B，只读）：
- 248 个物理 map ID：11 城市、25 道路、190 室内/地牢、22 unused；ExternalMapEntries 37 项，InternalMapEntries 60 条阈值范围。
- TownMapOrder 52 个 selector；13 个 SpecialFlyEntries、13 个 FlyTownMapPlayerOverrides；Route20/Seafoam 还存在坐标/入口相关逻辑 selector。
- CGB 地名牌 107 张 1bpp 图，109 条 map-id 映射（36 城市/道路直映 + 73 特殊地图映射），其中 4 个物理地图别名共享 label，2 张通用 Mt. Moon/Rock Tunnel 图当前未被运行时表引用。
- `names.asm` 53 个英文原文全部有 XLSX 中文替换；Townnames 工作表另含 4 个 UI 字符串和 16 个 Gym 脚本静态字符串，不能混算成地图名称。
- 不同 renderer 的名称语义不同：Continue/Save 使用 raw `wCurMap`；Town Map/Fly/Pokédex AREA 使用逻辑 selector；CGB 地名牌使用物理 map ID 的楼层 label。
- 已确认 ROM-1.42C 固定 ROUTE 17 的原因是跨 Bank `farcall` 在 callee 入口前把 A 改成目标 Bank `$1C`，而 `ROUTE_17=$1C`。C 已撤销，不复用其代码。
- 名称栏宽度不同：Town Map 10 列、Fly 7 列、Continue/Save 13 列、CGB 18 tile 列；必须建立 per-renderer variant，不能只生成一份全名。

详细证据和未决设计见 `docs/MAP_NAME_SYSTEM_AUDIT_ROM142B.md` 及其 TSV 台账。

设计约束：

- 使用 map ID/逻辑地点身份作为语义键；不以裸 16-bit ROM 地址作为唯一身份。
- 同一地点身份映射供多个 renderer 使用；普通字符串与 CGB bitmap label 分开渲染。
- 特殊 selector、室内别名、楼层、屋顶、洞窟、西/东区域等逐项纳入，不可只覆盖 53 个普通名称。
- 所有跨 Bank 调用写明输入/输出寄存器契约。`farcall` 会通过 `Bankswitch` 改写 A；若 map ID 放在 A，调用前必须按明确 ABI 保存/重载，不得假设寄存器保留。
- 设计生成流程时优先扩展现有生成器/导入流程，不先创建页面专用的第二个生成器。

退出标准：地点身份交叉表完整；每个消费者的来源和显示限制明确；中英文名称、别名、宽度、字形、Bank 和动态参数策略通过静态设计审查；负向检查能拦截 ROUTE 17 固定显示这一类参数破坏。通过后才开始一次性实施，不先做 Continue 单页补丁。

### 阶段 2 — 名称系统与旧存档兼容

范围：物种、招式、道具、训练家、类型、能力变化、状态统计、Field Move、玩家/宿敌默认名及交易昵称。

先遵循 `docs/NAME_LANGUAGE_COMPATIBILITY.md`。明确 `wOptions` LANGUAGE 与 `wENGNameMark` Names 两个维度；自定义昵称原样保留；不批量改写 SRAM 名称，不改变 `NAME_LENGTH`、存档布局、进化判断或联机语义。名称表调用方必须逐一覆盖 Party、PC、Summary、Pokédex、Battle、HOF 等消费者。

退出标准：中英文标准名与自定义昵称规则明确；旧英文档、汉化新档和自定义昵称兼容测试通过；不改变 SRAM/进化/联机行为。

### 阶段 3 — Pokédex 剩余系统

范围：主列表、DATA/CRY/AREA/QUIT 子菜单、151 条目说明、分类/身高/体重元数据、栖息地和未知地点提示。

已完成的 19 个评价/Seen/Owned 标签不重复开发；列表 UI、条目说明、元数据、物种名、AREA 地点分别登记。依赖阶段2名称规则和阶段1地点身份表。

退出标准：所有图鉴子页按文本槽位完成双语；分页、宽度、动态名称和地点一致；数字、光标、排序、存档行为不变。

### 阶段 4 — Battle 引擎

范围：FIGHT/ITEM/RUN/Safari 命令框、战斗消息、招式/PP/属性/状态名称、训练家/野生战斗开场与结算、捕捉、经验、升级、进化、换人、逃跑、伤害/能力变化等。

地图脚本中已双语的战前/战后对白保留；战斗引擎内部文本和命令 UI 独立分类。保留脚本控制流、动态物种/招式/训练家名称、数字命令和状态 token；未知命令 fail-closed。

退出标准：野战、训练家战、Safari、状态变化、捕捉、升级/进化、胜负和道具效果的中英文路径回归通过。

### 阶段 5 — 菜单、PC、背包与商店 UI

范围：主标题菜单、START 菜单、Party、Bag、Summary、PC、Save/Box、Poké Mart 买卖、数量选择、机器/电梯/教学提示及通用对话框。

同一页面拆开固定命令、动态名称、物品说明、数字和公共选项框。79 个自定义道具短说明块作为独立共用资源审计。**共用 YES/NO 选择框继续暂缓**，只记录其消费者，不修改。

退出标准：每个组件有对应语言路径；Bag/PC/Mart 共用说明一致；光标、输入、数量、取消、分页和存档行为不变。

### 阶段 6 — 事件、通信、野外、其他脚本和图形文字

范围：隐藏物、道具事件、Game Corner、Link/Cable Club、Field Move、命名界面、开场/结尾/制作人员名单、路牌和非 `text_far` 事件文本，以及其他图形文字。

按真实入口决定复用脚本生成器、引擎 wrapper、名称表或图形资源；不得因画面相邻而把不同引擎强行合并。

退出标准：每类资源有完整消费者清单和语言来源；事件分支、动态值、通信状态、输入行为不变。

### 阶段 7 — 全局集成验收与正式清理

- 按 `BILINGUAL_SCREEN_COMPONENT_MATRIX.tsv` 对每个屏幕槽位逐项检查，排除意外中英混杂。
- 中文 → English → 中文切换，保存、退出、重启后复测。
- 检查动态变量、特殊 token、字符宽度、分页、Bank、指针、跨 Bank 寄存器契约和存档兼容。
- 由维护者使用 RGBDS 1.0.4，在项目根目录执行 `make red`、`make blue`；保存对应 MAP、ROM SHA-256 和构建日志。
- 按项目要求运行适用静态检查；历史检查器若有旧版本守卫失败，明确区分版本不兼容与功能失败，不删除/弱化守卫。
- 只有用户明确验收后，才按项目交付规范进入正式清理；Git Commit/Push 由用户执行。

## 7. 每个模块统一的开发门槛

1. 入口盘点：列出数据源、定义、所有调用者和共享消费者。
2. 分类：固定、动态、名称、控制命令、图形文字分开登记。
3. 英文来源：同代英文原文、人工补充、缺失原文明确区分。
4. 技术设计：LANGUAGE 位、指针、Bank、寄存器契约、WRAM/SRAM、存档兼容、字符宽度和分页明确。
5. 自动检查：缺失/重复标签、重复键、条件未命中、版本过滤、未知 token、行宽、Bank 分段、生成确定性和消费者覆盖。
6. 负向测试：故意注入错 Bank、参数被覆盖、缺标签、重复键、条件不匹配和超宽文本，确认检查器会阻断。
7. 源码回归：运行模块专用检查及适用的既有检查；不把单元测试当全项目审计。
8. 维护者构建：红版、蓝版分别链接并检查 MAP、Bank 和 ROM 容量。
9. 实机验收：中文、English、切回、保存重启，以及该模块相关的设备/显示路径。
10. 记录收口：更新总计划、TODO、TSV、模块说明和用户验收历史；未测试范围保持待验收。

## 8. 当前下一步（不改游戏代码）

1. 阶段1首轮只读 crosswalk 已建立；完成名称 variants、Fly 7 列短名和 CGB renderer 的设计评审。
2. 核对 `BILINGUAL_MAP_IDENTITY_CROSSWALK.tsv` 中 Route20/Seafoam 的语义差异、特殊 selector 和所有消费者。
3. 明确 Continue/Save 保留 raw `wCurMap` 语义，还是改用 Town Map 的逻辑 selector；未经确认不改变现有地点归属行为。
4. 为 Town Map 10 列、Fly 7 列、Continue/Save 13 列建立 renderer-specific 名称 variants，并审查 `#`、`<PKMN>` 等特殊 token。
5. 设计 CGB 英文 bitmap/动态 renderer 和 Bank-safe name-copy 接口；设计审查通过后再批量实施，不做单页补丁。

## 9. 构建与交付边界

所有补丁交付、Git 基线、模式 A/B 清理、Commit 日志、RGBDS 版本、红/蓝构建和 AI 不编译/链接 ROM 的规定，以项目当前生效要求为准：`RPP_PROJECT_CONTEXT/03_PROJECT_REQUIREMENTS.txt`。该 TXT 是 RPP 自动生成的导出快照，不应在此直接编辑；长期要求应在 RPP 的原始要求编辑位置维护并重新导出。

本轮正式清理把 ROM-1.42B 版号收口为 ROM-1.42（8 字符），Options 版本绘制起点由 x=10 恢复 x=11；不改变图鉴评价、玩家资料、地图对白等运行逻辑。同步更新正式版静态守卫、项目计划、TODO、维护者说明和验收历史，并纳入阶段1地图身份 crosswalk。未运行 RGBDS／`rgblink`，未生成新 ROM／MAP／SHA，未执行 Git Commit／Push。
