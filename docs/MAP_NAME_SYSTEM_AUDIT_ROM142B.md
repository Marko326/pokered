# ROM-1.42B 阶段1地图名称系统只读审计

**审查日期：** 2026-11-07\
**基线：** 用户上传的 ROM-1.42B 源码
ZIP；项目当前已应用计划文档整合补丁\
**性质：** 只读源码、数据表、现有 MAP 和调用链审计\
**本轮源码修改：** 无\
**ROM 编译/链接：** 未执行\
**新 ROM/MAP/SHA：** 未生成\
**ROM-1.42C：** 已撤销；本报告不复用 C 版代码

## 1. 结论摘要

地图名称并不是一张表、一个页面或一个简单的语言开关。ROM-1.42B
至少有三层身份：

1.  **物理地图 ID**：当前实际加载的地图，例如
    `ROUTE_20`、`SEAFOAM_ISLANDS_B1F`。
2.  **逻辑 Town Map selector**：地图列表、Fly
    和图鉴区域为了地理显示而使用的别名，例如 `$F1/$F2/$F3` 和虚拟
    `$FD`。
3.  **CGB 地名牌身份**：以实际物理地图 ID 解析到具体楼层/区域的图形
    label，例如 S.S. Anne 1F、Silph Co. 8F。

它们不能混成一个裸地址，也不能按 Continue、Save、Town Map、Fly
四个页面分别复制四套地点判断。

### 本轮已建立的完整清单

  ------------------------------------------------------------------------------
  项目                                          数量 说明
  --------------------- ---------------------------- ---------------------------
  原始地图 ID                                    248 `$00-$F7` 全部常量

  城镇/城市 ID                                    11 `$00-$0A`

  道路 ID                                         25 `$0C-$24`

  室内/地牢 ID                                   190 `$25-$F7` 中实际命名地图

  未使用 ID                                       22 包含被逻辑 selector 复用的
                                                     `$F1-$F3`

  ExternalMapEntries                              37 通过 map ID 直接索引

  InternalMapEntries                              60 60 条上界阈值范围

  TownMapOrder                                    52 52 个列表 selector，输出 49
                                                     个不同名称身份

  `names.asm` 名称                                53 53 个英文原文，XLSX 有 53
                                                     个中文替换

  LoadTownMapEntry                                 7 7 个 selector 分支，含虚拟
  特殊分支                                           `$FD`

  Fly 特殊目的地                                  13 13 个

  Fly 当前玩家位置                                13 13 个坐标入口
  override

  CGB map-id 映射                                109 36 个城市/道路直映 + 73
                                                     个室内/楼层映射

  CGB 图形 label 资产                             71 41 + 47 + 19 = 107

  CGB 已引用唯一 label                           105 105 个

  CGB 未引用 label 资产                            2 MAP_NAME_SIGN_MT_MOON,
                                                     MAP_NAME_SIGN_ROCK_TUNNEL
  ------------------------------------------------------------------------------

完整逐项对应关系见本包中的 TSV；其中
`BILINGUAL_MAP_IDENTITY_CROSSWALK.tsv` 有 248 行，覆盖每个物理 map ID。

## 2. `LoadTownMapEntry` 的真实解析规则

源码：`src/engine/items/town_map.asm:822-891`；数据：`src/data/maps/town_map_entries.asm`。

### 2.1 外部地图

-   `$00-$24` 使用 `ExternalMapEntries`，以 map ID 直接索引。
-   表长为 37，覆盖城市、`UNUSED_MAP_0B` 和 Route 1--25。
-   `$0B` 是 unused placeholder，表项仍指向 Pallet Town 名称及 `(0,0)`
    坐标；不应把它当成正常可见地点。

### 2.2 内部地图

-   `$25-$F7` 使用 60 条 `InternalMapEntries` 上界范围。
-   `internal_map X, x, y, Name` 的宏将 `X+1`
    写入阈值；运行时选择第一个大于当前 map ID 的阈值。
-   因此它是**范围映射**，不是"每个室内 map ID 都有一条独立名称记录"。
-   60 个范围和各自坐标、名称已写入 `MAP_NAME_INTERNAL_RANGES.tsv`；248
    个 ID 的最终解析结果在主 crosswalk。

### 2.3 必须先处理的特殊 selector

`LoadTownMapEntry` 在普通外部/内部表查找之前有 7 个特殊分支：

  -----------------------------------------------------------------------------------------------------
  Selector                                                 值 显示名称         说明
  ------------------------------------- --------------------- ---------------- ------------------------
  `DIGLETTS_CAVE_ROUTE_2`                               `$2E` Diglett's Cave   实际地图 ID，但覆盖普通
                                                                               Route 2 范围结果

  `DIGLETTS_CAVE_ROUTE_11`                              `$55` Diglett's Cave   实际地图 ID，但覆盖普通
                                                                               Route 11 范围结果

  `CELADON_MART_ROOF`                                   `$7E` Celadon Mart     硬编码 CHS 字节，不在 53
                                                              Roof             个名称表内

  `UNUSED_MAP_F1`                                       `$F1` Seafoam Islands  Town Map 西侧逻辑
                                                                               selector

  `UNUSED_MAP_F2`                                       `$F2` Sea Route 20     Cinnabar 侧逻辑 selector

  `UNUSED_MAP_F3`                                       `$F3` Sea Route 19     Fuchsia 侧逻辑 selector

  `SPECIAL_FLY_SEAFOAM_WEST_SELECTOR`                   `$FD` Seafoam Islands  虚拟 Fly
                                                                               selector，不是物理地图
                                                                               ID
  -----------------------------------------------------------------------------------------------------

尤其 `$2E`、`$55`、`$7E`、`$F1-$F3`
都落在普通内部范围内；如果忽略特殊分支，就会显示错误地点。不能只扫描
`InternalMapEntries` 就认为映射完成。

## 3. TownMapOrder、Fly 和 Pokédex AREA 共享的逻辑地点

### 3.1 TownMapOrder

`src/data/maps/town_map_order.asm` 有 52 项。每项都是一个
selector，并非全都等同于物理地图 ID：

-   Diglett's Cave 有 Route 2 / Route 11 两个入口 selector。
-   Seafoam 西侧使用 `$F1`，东侧使用 Seafoam 物理地图 selector。
-   Route 19/20 的西东侧水域使用 `$F3/$F2` 逻辑 selector。
-   Celadon Mart Roof 使用特殊名称分支。

52 个 selector 解析后得到 49
个不同名称身份；重复不是重复翻译，而是不同地图入口共享同一地点名称。

另有 5 个 `names.asm` 名称没有作为 TownMapOrder 直接 selector
出现，但被内部地图范围使用： - `PokemonLeagueName` -
`PokemonMansionName` - `RocketHQName` - `SilphCoName` -
`UndergroundPathName`

它们仍然是有效地图名称，不得从英文名称表中遗漏。

### 3.2 Fly

Fly 有两组不同的关系，不能混为一谈：

-   11 个普通城市目的地列表；
-   13 个 `SpecialFlyEntries` 特殊目的地；
-   13 条 `FlyTownMapPlayerOverrides`，用于根据当前地图及坐标，把玩家
    marker 定位到洞窟/地标；
-   13 个保存解锁 bit，其中 Rock Tunnel 两个入口共用 bit 5，Seafoam
    西/东入口分别通过 Route 20 warp index 0/1 设置 bit 9/10。

`SpecialFlyEntries` 的第二个参数是 TownMapOrder 地理锚点 index，不是地图
ID；例如 Victory Road 1F Fly selector 的锚点指向 TownMapOrder 的 Victory
Road 3F selector，但两者共享 Victory Road 名称。

### 3.3 Route 20 / Seafoam 是坐标相关逻辑

`GetFlyTownMapPlayerMap`（Bank `$34`）先调用
`ClassifyRoute20SeafoamTownMap`：

-   Route 20 非冲浪时，按两个岛屿的坐标范围识别 Seafoam
    西/东岛；其他区域默认 `$F2`。
-   Route 20 冲浪时，按 Y 区间选择 X 边界 62/64/65/66，将水域分成 `$F2`
    Sea Route 20 和 `$F3` Sea Route 19。
-   Seafoam 内部地图则依据从 Route 20 哪个入口进入，返回 `$F1` 西侧或
    Seafoam 物理 selector 东侧。

Pokédex AREA 另有自己的列表归一化： - 野生数据中的 Route 20 被替换成
`$F2`，并在需要时追加 `$F3`； - Seafoam 1F/B1F--B4F 被归到
`$F1`，并在需要时追加东侧 Seafoam selector； - 玩家 marker 使用
`GetFlyTownMapPlayerMap`。

这些规则已逐条记录在 `ROUTE20_SEAFOAM_LOGICAL_CLASSIFICATION.tsv`。

## 4. 同一"当前地点"在不同界面中的语义并不完全相同

这是实施前必须明确的边界：

  --------------------------------------------------------------------------------------------------
  界面                    当前地图身份来源           当前行为
  ----------------------- -------------------------- -----------------------------------------------
  Continue                原始 `wCurMap`             直接 `LoadTownMapEntry`

  Save                    原始 `wCurMap`             与 Continue 共用同一入口

  Town Map 玩家 marker    `GetFlyTownMapPlayerMap`   Route 20/Seafoam 使用坐标/入口逻辑 selector

  Fly 玩家 marker         `GetFlyTownMapPlayerMap`   与 Town Map 相同

  Pokédex AREA 玩家       `GetFlyTownMapPlayerMap`   使用逻辑 selector
  marker

  CGB 地名牌              原始物理 map ID            显示实际支持的楼层/区域身份；普通室内中转地图
                                                     neutral
  --------------------------------------------------------------------------------------------------

例如 Route 20 的同一物理地图 `$1F`： - Continue/Save 直接使用
`Route20Name`（Sea Route 20）； - Town Map/Fly 可按坐标返回 `$F2` 或
`$F3`，在 Fuchsia 侧显示 Sea Route 19； - CGB 地名牌仍按物理 Route 20
map ID 显示 Route 20。

这属于既有显示语义差异，不是单纯语言问题。实现时不能为了"统一英文"擅自改变玩家已经习惯的地图归属。建议先保留每个
renderer 的身份语义，只统一其本地化名称数据；若要把 Continue/Save
也改成坐标逻辑，需作为单独行为变更验收。

## 5. CGB 地名牌是独立图形系统

源码： - `src/engine/overworld/cgb_map_name_sign.asm` -
`src/engine/overworld/cgb_map_name_sign_bank_2e.asm` -
`src/engine/overworld/cgb_map_name_sign_bank_2f.asm` -
`src/gfx/map_name_sign/`

当前结构：

  资源组                  label 数量 存放 Bank
  --------------------- ------------ -----------
  `labels.1bpp`                   41 `$3D`
  `labels_ext_a.1bpp`             47 `$2E`
  `labels_ext_b.1bpp`             19 `$2F`
  **总计**                   **107**

-   36 个基础 label 对应 11 城市 + Route 1--25。
-   5 个基础 landmark label 中，Viridian Forest、Diglett's Cave、Power
    Plant 当前有 map table
    引用；`MAP_NAME_SIGN_MT_MOON`、`MAP_NAME_SIGN_ROCK_TUNNEL`
    两张旧的通用 bitmap 当前没有被 `MapNameSignSpecialMapTable`
    引用，实际运行使用楼层专用图。
-   71 个 special label ID 中有 69 个被当前 map table
    使用；另外两个正是上述 Mt. Moon / Rock Tunnel 通用图。
-   特殊 map table 有 73 行、69 个唯一 label；4 个别名地图复用既有
    label：Celadon Mansion Roof House，以及 S.S. Anne 1F/2F/B1F Rooms。

CGB 地名牌不是 `names.asm` 字符串，也没有找到对应的 LANGUAGE 分支或英文
bitmap。以后必须单独处理其 1bpp 图形数据，不能只给 `LoadTownMapEntry`
加英文指针就宣称全地图名称完成。

## 6. 名称来源和 UI 字符串分类

`src/data/maps/names.asm` 有 53 个英文原文；`data.xlsx` 的 `Townnames`
工作表对这 53 项逐一导入中文。所有 53 个 label 都能在
`town_map_entries.asm` 或特殊 selector 分支中找到引用。

但同一工作表还包含另外两类内容：

**4 个 UI 字符串（不是地点名称）：** - Fly 的 `To` → 飞往 - Pokédex Nest
的 `'s` → 的 - Nest 短后缀 `nest` → 分布 - Pokédex AREA 空状态
`AREA UNKNOWN` → 栖息地不明

**16 个 Gym 脚本静态字符串（不是地图名称表）：** - 八个 Gym
脚本各自的城市名和馆主名。 - 它们是 `scripts/*Gym.asm`
的脚本文字，应归入脚本/UI 文本模块，不应塞进地点身份表。

另有两条硬编码 CHS 名称： -
`CeladonMartRoofName`：百货屋顶，缺少普通英文字符串源。 -
`FlyPowerPlantShortName`：Fly 专用短名称，完整英文 `POWER PLANT`
虽存在，但 7 列 Fly 名称栏需要单独短名。

## 7. Renderer 宽度：不能把一份英文全名原样塞进所有界面

从当前源码布局确认的可用字段：

  -----------------------------------------------------------------------------
  Renderer                                  字段宽度 源码依据
  --------------------- ---------------------------- --------------------------
  Town Map 名称行                              10 列 `DisplayTownMap` 清 11
                                                     列（x=0..10），文字从 x=1
                                                     开始

  Fly 名称行                                    7 列 `LoadTownMap_Fly` 清
                                                     x=4..10，并从 x=4 写名称

  Continue/Save 地点行                         13 列 `TextBoxBorder` 的 c=13
                                                     是内部宽度；左右边框另加

  CGB 地名牌                  18 tile 列 × 2 tile 行 每个 label 资源固定 18×2
                                                     tiles
  -----------------------------------------------------------------------------

对 `names.asm` 53 个英文源做字符宽度初筛： - 10 列 Town Map header：约
27/53 可直接容纳； - 7 列 Fly header：约 10/53 可直接容纳； - 13 列
Continue/Save：约 45/53 可直接容纳； - 18 列 CGB 字符候选：53/53
普通名称源在字符数层面可容纳，但 CGB 楼层 label 候选另有 7 项超过 18
列。

以上是字符单位初筛，不是最终像素验收。`#` 会由 `PlaceString` 展开为
POKé，`<PKMN>` 会展开为 PK/MN 特殊字形；Save/Continue 当前代码还会将这些
token 缩短为 `P`，因此必须专门审查语义和宽度，不能只按 Python
字符串长度截断。

**实施要求：** - Town Map 需要 10 列名称 variant
或明确的省略/滚动策略。 - Fly 需要 7 列短名称
variant，覆盖普通城市、特殊 Fly 目的地和当前 marker。 - Continue/Save
可以使用 13 列全名/安全截断，但必须保持双字节字形完整，并审查
`#`、`<PKMN>`。 - CGB label 需要 18 列内的英文 bitmap/renderer；至少 7
个候选需人工缩写或重新排版。

## 8. ROM-1.42C 固定 ROUTE 17 的根因已由源码和 MAP 交叉确认

ROM-1.42C 已撤销，不复用其代码。根因不是"读取了 Bank
地址字符串"，而是**跨 Bank 调用时 A 寄存器参数被 Bank number 覆盖**。

ROM-1.42B 当前代码： - `LoadTownMapEntry` 与
`PrintCurrentMapOnSaveScreen` 都在 ROMX Bank `$1C`。 - Continue/Save 从
`main_menu.asm` farcall 到 `PrintCurrentMapOnSaveScreen`，入口无 A
参数。 - `PrintCurrentMapOnSaveScreen` 内部使用普通
`call LoadTownMapEntry`，因此 `A=[wCurMap]` 在同 Bank 调用中仍是 map
ID。

ROM-1.42C 候选曾把英文 renderer 放在 Bank `$70`，然后执行：

``` asm
ld a, [wCurMap]
ld de, wTownMapCoords
farcall LoadTownMapEntry
```

但 `farcall` 宏先执行 `ld b, BANK(LoadTownMapEntry)`；`Bankswitch`
在跳入目标前执行 `ld a, b`。所以 `LoadTownMapEntry` 入口收到的是目标
Bank `$1C`，而不是当前 map ID。`ROUTE_17` 在 `map_constants.asm`
中恰好为 `$1C`，于是每次都解析成 Route 17。

**ABI 规则：** `farcall` 会在 callee 入口前用目标 Bank 覆盖
A；它只在目标返回时恢复调用者 A。不能把 A 当作跨 `farcall`
的输入参数。以后需要跨 Bank 传 map ID
时，必须使用明确的稳定参数通道（例如 WRAM/DE 协议），或先在 Bank `$1C`
完成 `LoadTownMapEntry`，再把返回的名称身份交给另一个 Bank 的
renderer。不要从 Bank `$70` 直接 `farcall LoadTownMapEntry` 并假设 A
保留。

## 9. Bank 空间证据（仅 ROM-1.42B 随附 MAP 快照）

  Bank      MAP 记录剩余空间
  ------- ------------------
  `$1C`            229 bytes
  `$2E`          2,799 bytes
  `$2F`         10,863 bytes
  `$3D`          3,524 bytes
  `$62`          8,409 bytes
  `$70`         15,382 bytes

这不是本轮重新构建结果，只是 ZIP 中 MAP 的快照证据。

每张 CGB label 图为 18×2 tiles、1bpp，共 288 bytes。105
个当前被引用的唯一 label 若全部另存英文 bitmap，粗略需要 30,240
bytes（不含指针表/代码）。这无法塞进 Bank `$3D`
的现有剩余空间；必须在多个 Bank 之间规划，或评估动态英文字体
renderer，不能直接把 107 张图复制进同一 Bank。

## 10. 建议的统一实施架构（本轮仅设计，不改代码）

1.  **身份层**：保留 physical map ID、TownMap logical selector、CGB
    effective label 三种不同 key；使用本轮 crosswalk 作为唯一来源表。
2.  **字符串数据层**：53 个标准英文名称 + Celadon Mart Roof 特例；按
    Town Map 10 列、Fly 7 列、Continue/Save 13 列维护 renderer
    variants。中文仍由现有 XLSX 导入数据提供，不改原译文。
3.  **字符串 renderer 层**：Town Map/Fly/Continue/Save
    共享地点身份/本地化名称数据，但各自使用符合宽度的
    variant。`LoadTownMapEntry` 继续负责坐标和 CHS label identity，不跨
    Bank 返回不可访问的 ROM pointer。
4.  **Bank-safe bridge**：若英文数据放在 Bank `$70`，Bank `$1C` 先用普通
    `call LoadTownMapEntry` 解析身份，再将名称 pointer/key 通过 DE 或
    WRAM 传给 Bank `$70` helper；helper 在 Bank `$70` 内把文字复制到
    WRAM buffer，返回后调用者只使用 WRAM，不持有 Bank `$70` ROM
    pointer。
5.  **Pokedex UI**：`To`、Nest suffix、Area Unknown 作为独立 UI
    槽位登记；物种名继续由 Names 设置管理，地图 marker 继续使用逻辑
    selector。
6.  **CGB renderer**：独立增加 English bitmap/动态字体路径；先做 18×2
    tile 样张和空间实验，再决定静态资产或动态 renderer。不要把 CGB
    图形文字误当作 `names.asm` 普通字符串。
7.  **导入/生成流程**：扩展现有 `prepare_build.py` / 导入流程保存
    English 源与 CHS 导入数据的对应关系；不再新增 Continue-only
    页面生成器。

## 11. 进入代码实施前仍需确认的两个范围决策

1.  **Continue/Save 的 Route 20 当前地点语义**：保留 ROM-1.42B 的原始
    `wCurMap` 显示（Route 20 就显示 Sea Route 20），还是改为与 Town
    Map/Fly 相同的坐标逻辑 selector（可能在 Fuchsia 侧显示 Sea Route
    19）？建议第一轮只做语言覆盖、保留现有物理地图语义，避免把语言修复变成地点归属行为变更。
2.  **Fly 7 列短名策略**：为 11 城市 + 13
    特殊目的地建立经确认的短名，还是把名称栏改为两行/滚动显示？建议第一轮使用明确的短名表，保持现有布局和操作。

CGB 英文地名牌另列为独立 renderer 子阶段；本轮没有改变其视觉或显示范围。

## 12. 下一步

-   本轮已完成阶段1的首轮只读 crosswalk 与消费者审计。
-   下一步先确定字符串 renderer 的名称 variant 方案和 Fly 短名表，再设计
    CGB 英文 bitmap/动态 renderer。
-   在上述设计评审完成前，不写 Continue-only 或 Save-only
    的英文分支，不生成 ROM-1.42C 修复补丁。
-   本轮没有修改游戏源码、XLSX、生成器、测试脚本或 Git 历史。

## 13. 本包文件索引

-   `BILINGUAL_MAP_IDENTITY_CROSSWALK.tsv` --- 248 个物理 map ID 的完整
    Town Map/Fly/CGB 对照。
-   `TOWNMAP_ORDER_CROSSWALK.tsv` --- 52 个 TownMapOrder selector。
-   `MAP_NAME_INTERNAL_RANGES.tsv` --- 60 条内部地图上界范围。
-   `FLY_DESTINATION_CROSSWALK.tsv` --- 13 个特殊 Fly 目的地。
-   `FLY_PLAYER_MARKER_OVERRIDES.tsv` --- 13 条地图/坐标到逻辑 selector
    的规则。
-   `FLY_UNLOCK_CONDITIONS.tsv` --- 13 个特殊 Fly 解锁 bit。
-   `ROUTE20_SEAFOAM_LOGICAL_CLASSIFICATION.tsv` --- Route 20 / Seafoam
    的坐标和入口逻辑。
-   `CGB_MAP_SIGN_MAP_ID_CROSSWALK.tsv` --- 109 条 CGB map-id 到 label
    映射。
-   `CGB_MAP_SIGN_LABEL_ASSETS.tsv` --- 107 个 CGB 图形 label。
-   `MAP_NAME_STRING_SOURCES.tsv` --- 53 个英文/中文地图名称。
-   `MAP_NAME_UI_COMPONENTS.tsv` --- 4 个 UI 字符串及 2 个硬编码地点名。
-   `TOWNNAMES_GYM_SCRIPT_LITERALS.tsv` --- 16 条 Gym 脚本静态文字。
-   `MAP_NAME_DISPLAY_WIDTH_AUDIT.tsv` --- 不同 renderer 的宽度初筛。
-   `MAP_NAME_DISPLAY_CONSUMERS.tsv` ---
    每个画面的实际调用链与文本类别。
-   `MAP_NAME_SPECIAL_SELECTORS.tsv` --- 7 个特殊 selector 分支。
