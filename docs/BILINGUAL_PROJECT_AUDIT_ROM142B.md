# ROM-1.42B 阶段0双语入口盘点与阶段1地图名称审计

**审查时间：** 2026-11-07 14:12:04（北京时间）\
**审查对象：** 用户上传的 ROM-1.42B.zip 源码快照\
**工作性质：** 只读源码审计、导入规则检查、路线图整理\
**源码修改：** 无\
**ROM 构建/链接：** 未执行\
**ROM / MAP / SHA 产物：** 未生成

## 0. 基线与撤销状态

-   本轮以 ROM-1.42B ZIP 内的源码快照为唯一开发审计对象。
-   导出记录声明的 Git HEAD 为
    `608a85501b97174401367f544427aaac60639e54`，同时 ZIP 附带
    `current_worktree.patch`。这两者必须区分，不能把 ZIP
    快照直接等同于干净 HEAD。
-   旧 Git Bundle HEAD 为 `bd091a28...`，不是当前 ROM-1.42B
    快照的直接基线。
-   **ROM-1.42C-current-location-fix.patch
    已按用户要求撤销，不应用、不叠加、不纳入本轮工作。** 本报告不包含 C
    补丁。
-   当前 ZIP 内没有 ROM-1.42C 补丁或其生成器；本轮未修改源码树。

## 1. 最重要的盘点结论

项目不是"看到某页中文就加一个英文分支"。同一页面可能同时由固定
UI、地图名称表、动态数据、引擎文本、名称表、图形资源等不同系统组成。

本轮建立了五份互相关联的清单：

1.  `BILINGUAL_COVERAGE_MASTER.tsv`：2452
    个翻译标签的源码级引用位置、英文来源、动态 token 和当前状态。
2.  `DATA_XLSX_IMPORT_OPERATIONS.tsv`：`data.xlsx` 中 951
    条实际导入操作，区分文本、代码/格式改写和 RB/RGB 版本范围。
3.  `BILINGUAL_SCREEN_COMPONENT_MATRIX.tsv`：同一画面拆成多个文本组件，不以页面名整体判定完成。
4.  `BILINGUAL_MAP_NAME_ENTRY_AUDIT.tsv`：Town Map/Fly/CGB 地名牌的
    selectors、映射表、特殊别名和图形资源入口。
5.  `BILINGUAL_UNINDEXED_SURFACES.tsv`：未被普通 text_far
    标签清单完整代表的图鉴、道具说明、图形文字等独立表面。

### 1.1 翻译标签集

  指标                    数量  含义
  ---------------------- ------ ---------------------------------------
  Manifest 标签行         2452  包含地图脚本、引擎文本和人工补充项
  地图脚本双语入口        1941  auto-routed + manual English override
  非地图脚本范围          511   outside-map + manual review
  图鉴评价双语标签         19   已有 ROM-1.42A 双语实现
  非地图活动待处理标签    486   有源码级引用位置（仍需核实真实调用链）、尚未接入全局 LANGUAGE
  人工复核标签             1    `_ChooseABoxText`，含 `<PKMN>` token
  无直接 ASM 调用候选      5    待确认，不得直接删除

地图脚本的 manifest 统计为 1933 个自动接入标签、8
个人工英文补充标签，合计 1941 个唯一双语入口；manifest 记录的地图脚本
`text_far` 引用数为 1942。源码脚本文本扫描还找到 1944 条 `text_far`
引用，其中 manifest
之外的两个既有英文试点标签为：`_Route1Text2English; _ViridianCityText1English`。

**注意：** 这组标签计数不是全游戏覆盖率。它不包括 `data.xlsx`
静态字串、宝可梦/招式/道具名称表、图鉴条目、CGB
图形文字和自定义道具说明。

### 1.2 非地图引擎文本：486 个活动待处理标签

  主要引用文件类别（初步分类）               活动待处理标签
  ------------------------- ----------------
  事件/隐藏物                     150
  战斗引擎                        149
  菜单/UI                          53
  道具/商店/地图工具               48
  宝可梦/队伍/PC                   26
  过场/名人堂/交换                 17
  游戏厅/老虎机                    14
  公共文本/名称引擎                11
  通信/交换                        8
  野外/Field Move                  6
  道具 + 野外共享入口              3
  公共文本 + 野外共享入口          1
  **合计**                      **486**

另有： - 19 个图鉴评价标签已经双语化（17 个评价/完成度文本，另有 2 个
Seen/Owned/Rating 标签被 HOF 复用）。 - 1 个 `_ChooseABoxText`
需要人工处理 `<PKMN>` 动态物种名 token。 - 5
个没有直接调用点的标签，作为 orphan candidates 留档。

5 个候选标签： - `_FuchsiaHouse3Text_56217` - `_HM02ExplanationText` -
`_HM03ExplanationText` - `_Route12HouseText_564d4` -
`_VermilionHouse2Text_560c5`

这 5 个只表示"当前扫描没有发现非定义 ASM 文本引用"，不表示可以删除。

## 2. 修正旧审计数字的口径

早期 `ROM139_LANGUAGE_TEXT_AUDIT.md` 的 483 条"未匹配"是当时只扫描
`src/text/` 的结果。后续 `generate_bilingual_dialogue.py`
的英文来源索引还扫描了 `src/data/text/text_1.asm` 至
`text_7.asm`，因此大量标签在引擎文本文件中找到了同代英文原文。

当前应使用后续 manifest 的口径： - 原始翻译记录：2,447 行，2
个重复，2,445 个唯一标签。 - 同代英文来源：2,444 个标签直接匹配。 - 1
个标签 `_OaksLabHomePCUpdatedText` 使用人工英文覆盖。 - 另有 7
个人工补充标签，加入地图脚本生成清单。 - 不应再把旧审计的 483
条全部称为"缺少英文原文"。

## 3. data.xlsx：不是纯翻译表

实际导入流程在 `scripts/prepare_build.py` 中调用
`_importTextData.py`。对 `data.xlsx` 的行级盘点结果：

  指标                                 数量
  ----------------------------------- ------
  导入操作总行数（含代码/格式改写）    951
  文本替换指令                         898
  非文本代码/格式/结构指令              53
  RB 构建范围内的文本指令              845
  RGB 专用、RB 构建跳过的文本指令       53
  已有 LANGUAGE 双语分支                23
  已有独立 Names 选项                  199
  用户明确暂缓的 YES/NO                 11
  其他 RB 活动文本指令                 612

这都是**行级导入指令数量，不是唯一文本数量**。尤其是 `Main`
表包含版本分段和条件替换，不能把工作簿行数直接当作需要翻译的字符串数。

### 3.1 版本与分类

-   `data.xlsx` 共 898 条文本替换指令，其中 845 条属于当前 Red/Blue
    构建范围，53 条属于 RGB 版本并在 RB 构建时跳过。
-   已双语的 23 条：OptionsBilingual 13 条 + 玩家资料固定标签 10 条。
-   独立 Names 选项控制的 199 条：物种名 190 条 + 当前 RB 构建的交易昵称
    9 条。它们不随全局 LANGUAGE 自动切换。
-   YES/NO 公共选择框 11 条：按用户此前决定暂缓。
-   其余 612 条是 RB 活动文本导入指令，尚未统一接入
    LANGUAGE；其中有旧规则、条件规则和重复键，需要逐项清理，不能把这个行数当成独立翻译任务数。

### 3.2 实际导入器检查发现

我在**临时解压副本**中运行了项目原有
`_importTextData.py`，没有运行编译或链接。导入日志出现 4 条
`Not Found`： - `English@` - `Chinese@` - `ver@` - `Now saving...@`

另发现两类没有可靠告警的隐患：

1.  **重复键冲突：** `data/pokemon/names.asm` 中多个 `MISSINGNO.`
    共用同一 replace-all
    键，其中一项期望译为「幽灵」，其他项译为「缺号」。导入器全局替换并在注释中保留原始键，后续规则可能只改到注释，不能改变目标数据字节。
2.  **条件上下文失配：** `main_menu.asm` 中一条 `CANCEL@` 规则依赖
    `OptionMenuCancelText`，当前目标文件没有该上下文。导入器不会明确报告条件未命中。

这意味着"导入日志没有报错"不等于"每个目标数据都按预期替换"。后续应在现有导入工具上增加
stale-key、重复键冲突和条件未命中的检查，不另造第二套生成器。

`data.xlsx` 还包含非文本代码/格式变更（例如 Ghost 类型字形、BOX
前缀字形、训练家名称指针、动画和 Makefile
相关调整）。正式清理时必须区分游戏数据与工具/构建脚本变更。

## 4. 名称系统：LANGUAGE 与 Names 是两个维度

源码中的 `wOptions` LANGUAGE 位和 `wENGNameMark` 并不是同一个开关。

当前 `wENGNameMark` 影响： - 宝可梦物种名（190 个表项）。 - 当前 RB
构建中的游戏内交易昵称（9 条）。 - Pokédex
未知物种占位名/地图巢穴相关文本行为。 - Naming Screen
的名称布局等相关逻辑。

它**不自动等于全局
LANGUAGE**。不能在没有设计和旧存档兼容验证前，把两个设置强行绑定。

仍需独立处理的名称表： - 招式名：165 条。 - 道具名：97 条，加上 Route 23
中 7 条直接字符串。 - 训练家名：47 条，另有 16 条短名/类别入口。 -
属性名：16 条。 - 能力变化名、状态界面统计名、Field Move 名称。 -
玩家/宿敌默认名字（当前 RB 表中各 7 项），不受 `wENGNameMark` 自动控制。

必须遵循
`docs/NAME_LANGUAGE_COMPATIBILITY.md`：自定义昵称、旧存档内保存的名称不能被批量覆盖；物种名语言选择不能破坏
SRAM/进化/PC/队伍读取行为。

## 5. 地图名称系统：阶段1只读审计

这是当前用户可见的明确问题：ROM-1.42B 的 Continue/Save
固定英文标签已经有分支，但当前地点名称仍从被汉化导入的地图名称表读取。

### 5.1 已查明的入口和数据规模

  数据/入口                       数量  来源
  ------------------------------ ------ -------------------------------------
  Town Map 名称表                  53   `data/maps/names.asm`
  TownMapOrder selectors           52   `data/maps/town_map_order.asm`
  ExternalMapEntries               37   `data/maps/town_map_entries.asm`
  InternalMapEntries               60   `data/maps/town_map_entries.asm`
  SpecialFlyEntries                13   `special_fly_locations.asm`
  LoadTownMapEntry 特殊别名        7    `engine/items/town_map.asm`
  Town Map UI 片段                 4    `To`、`'s`、`nest`、`AREA UNKNOWN`
  Gym 脚本静态字符串               16   `Townnames` 工作表中的 Gym 脚本目标
  CGB 地名牌图形标签              107   41 local + 47 ext A + 19 ext B
  CGB map-id → 图形 label 映射     73   `MapNameSignSpecialMapTable`

另外： - `CeladonMartRoofName` 是独立硬编码特殊地点名。 -
`FlyPowerPlantShortName` 是 Fly 专用短名称。 - Town Map 与 Fly 通过
`DrawPlayerOrBirdSprite` / `LoadTownMapEntry` 共用地图名称路径。 -
Continue/Save 通过 `PrintCurrentMapOnSaveScreen`
调用同一地点查找逻辑。 - CGB 地名牌使用 map-id → 1bpp 图形 label
的独立路径，不应与普通字符串表混为一谈。 当前表有 73 条 map-id
映射行、69 个唯一图形 label ID，4 组房间/屋顶别名复用既有图形。 -
`TownMapOrder` 的 selector 是逻辑身份，不是 ROM Bank
地址；内部地图还需要映射到城市/道路或楼层身份。 - `LoadTownMapEntry`
包含 7 个特殊 selector/别名分支，必须纳入英文名称映射。 - `Townnames`
工作表的 73 条 RB 文本行并非全部都是地图名称：其中 53 条才是
`data/maps/names.asm` 的名称，4 条是 Town Map UI，16 条属于 Gym 脚本。

### 5.2 地图名称设计原则

1.  以当前地图 ID / 逻辑 selector 为稳定身份键，不以裸 16-bit ROM
    地址当作唯一身份。
2.  同一地点可被 Town Map、Fly、Continue/Save、CGB 地名牌等多个 renderer
    消费；应共享地点身份清单，renderer 各自适配。
3.  字符串名称与 1bpp 图形地名牌必须分开设计，但使用同一地点身份映射。
4.  特殊地点、楼层、洞窟、屋顶、Seafoam West/Route 20 West/Route 19 East
    等别名必须逐项映射。
5.  跨 Bank 调用要记录寄存器输入/输出契约；`farcall`/`Bankswitch`
    可能改写寄存器，不能把易失寄存器中的 map ID 当作仍然有效。
6.  任何修复必须覆盖 Town Map、Fly、Continue、Save、Pokedex AREA 和 CGB
    sign，不再做只改一个页面的补丁。

**ROM-1.42C 的 ROUTE 17 固定显示问题不属于本轮方案。** C
补丁已撤销；此处仅将其作为跨 Bank 参数契约的负向测试案例，不复用其代码。

## 6. 同一页面多文本来源矩阵

`BILINGUAL_SCREEN_COMPONENT_MATRIX.tsv` 是本轮最重要的防混乱清单。例如：

-   Continue：固定标签已双语；当前地点来自 Town Map
    名称表；玩家名/数量/时间来自动态数据。
-   Save：固定信息标签已双语；当前地点来自 Town Map 名称表；BOX
    名称来自另一条字形替换规则；选择盒子提示含动态 `<PKMN>` token。
-   Hall of Fame：PLAY TIME/MONEY 已双语；HALL OF FAME/LEVEL/TYPE1/TYPE2
    仍有独立中文入口；Seen/Owned/Rating 又属于图鉴评价系统。
-   Pokédex：列表菜单、物种名称、151 条目说明、分类/身高/体重、AREA
    地图位置和评价标签属于不同来源。
-   Battle：命令框、引擎消息、招式名、物品名、属性名、训练家名不能合并成一个"战斗文本"补丁。
-   Bag/PC/Mart：物品名称、菜单提示和 79
    个自定义短说明块是不同入口，但短说明块被三个场景共用。

只有同一画面中的所有文本槽位都通过对应模块验收，才可标记该画面完整双语化。

## 7. 其他独立文本表面

  ----------------------------------------------------------------------------------
  独立表面              数量/规模     当前判断
  ------------------ ---------------- ----------------------------------------------
  自定义道具短说明   79 个唯一块 / 83 CHS 字节数据；Bag/PC/Mart 共用；需人工英文方案
                        个指针槽位

  Pokédex 说明             151        `dex.xlsx` 导入，未接全局 LANGUAGE

  Pokédex 元数据           151        `dexEntry.xlsx` 导入，需与说明文本分开

  CGB 地名牌图形           107        独立图形资源

  Save/PC BoxNames      12 个槽位     两条前缀字形替换规则；未见英文 LANGUAGE 分支

  特殊地点硬编码名          2         Celadon Mart Roof / Fly Power Plant short name

  Credits                   65        当前英文为主；专有姓名与栏目标题需分别决定范围
  ----------------------------------------------------------------------------------

## 8. 更新后的开发路线

1.  **P0：冻结 ROM-1.42B；C 已撤销。**
2.  **P0：把 `data.xlsx` 导入器的 stale
    key、重复键和条件失配列为质量门。** 先定义检查规则，不马上改工具。
3.  **P1：完成地图名称系统的地点身份交叉表。** 将 52 TownMap
    selectors、外部/内部地图映射、13 Fly selectors、7 特殊别名、53
    名称、107 图形标签关联起来。
4.  **P2：名称系统。** 先明确 LANGUAGE 与 Names
    的职责、旧存档、自定义昵称和动态名称读取。
5.  **P3：Pokédex 剩余列表/条目/AREA。**
6.  **P4：Battle 引擎消息与战斗命令 UI。**
7.  **P5：主菜单、PC、Bag、Poké Mart、Save/Box 等通用 UI。**
8.  **P6：事件、Game Corner、Link、Field Move、图形文字等独立系统。**
9.  **P7：全局集成验收；用户验收后才进入正式清理。**

共用 YES/NO 选择框继续暂缓，除非用户重新授权。

## 9. 项目交付/构建约束

本轮是审计报告，不是代码开发交付，因此不生成 `.patch` 或 ROM。

后续代码开发必须遵循
`RPP_PROJECT_CONTEXT/03_PROJECT_REQUIREMENTS.txt`： - 开发阶段只交付一个
ZIP，内部是增量补丁和全量补丁；两份补丁只能二选一，不能叠加。 -
未验收前不制作正式提交日志/反向隔离补丁。 - 正式清理按项目规定的 A/B
模式拆分游戏代码与工具/审计脚本。 - RGBDS
1.0.4；由维护者在项目根目录执行 `make red`、`make blue`。 - AI
不编译/链接 ROM，不伪造 MAP、ROM SHA 或实机结果。 - 每次 Bank
修改都要检查维护者提供的新 MAP；尽量不占 ROM0。 -
不新建重复的双语生成器；优先审查是否扩展现有
`generate_bilingual_dialogue.py` / 导入流程。

## 10. 本轮结论与进度口径

-   阶段0：已完成已知翻译标签、主要导入工作簿、图鉴数据、地图名称数据和屏幕组件的第一轮盘点；仍需逐项确认
    5 个孤立标签及少量 inline literal。
-   阶段1：地图名称的数据源和主要消费者已经定位，尚未完成所有地图
    ID/别名/图形 label 的最终一对一交叉验收。
-   标签清单的地图双语覆盖不能代表全游戏覆盖率；它只代表
    `text_far`/翻译标签这一个数据集。
-   全项目完成率不宜用单一百分比：当前可报告"地图标签集已大范围接入"，但
    `data.xlsx` 的 612 条 RB 活动文本指令、486 个非地图引擎标签、151
    条图鉴说明、151 条图鉴元数据、名称表、79 个道具说明块和 107 个 CGB
    图形标签仍需分模块处理。

### 时间记录

-   本轮开始：2026-11-07 05:38:13 UTC。
-   本轮耗时：约 33.9 分钟。
-   从首次接手项目（2026-11-07 04:54:09 UTC）到本次记录：约 77.9 分钟。
-   阶段0第一轮盘点：约 90%（剩余人工核对孤立标签及未索引 inline
    literal）。
-   全项目进度：仍以约 25%
    的项目管理粗估为参考；没有统一权重分母，不作为验收百分比。
-   本轮未修改任何游戏源码、工具源码或 Git 历史。
