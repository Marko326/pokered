# RPP 参考分支移植台账：第 04 批（091～120）

> **CHS 源码基线**：`ROM-1.21.zip`，已提交 `CHS_Mod` HEAD `70549f631b187d2062a3b952a0d26426804d38b1`。
> **参考来源**：`CHS_Mod_QOL-1.14_已提交版交接资料包_无嵌套.zip` 内 RPP 参考工程的 `individual/091～120`，**30 笔均找到原始补丁**。
> **本批范围**：逐笔对照参考补丁差异与 CHS 真实源码、历史；本批只有文档审核，未移植 ASM、未重编译 ROM，也未在模拟器复现问题。

## 第四批的依赖链与判断边界

1. **#091～099 的地图/特殊飞行链**：多数补丁延续前一批 #086～090 引入的访问旗标、特殊地图坐标、Fly 落点。CHS 已有通常意义上的城市飞行，但**没有 RPP 这套特殊 Fly**，不能误标为“现有 Bug 未修”。#094 的 Surf 图标切换则与 CHS 通用加载路径可能相交，特列“待核验”。
2. **#104～113 的 Summary 新状态机**：#104 先把信息页改成左右切换，#105 添加上下即时换宝可梦，后续 #106～110/#113 又修复由新特性引出的叫声、地图和调色板问题。CHS 仍是分开的 `StatusScreen`/`StatusScreen2`，没有实时切换；故不能把后续修复看成 CHS 现有故障。
3. **#114～120 的图鉴/电脑扩展**：#114 是新图鉴详情浏览；#115 为之优化；#116～118 依赖 PC 连续操作及实时 Summary；#119 的列表光标问题在 CHS 也有类似通用代码，因此单列“待核验”，不能全盘跳过；#120 依赖完整新 Summary 资源复用体系。
4. **真实修复不等于必定复现**：#095（图鉴地图返回残留）、#100（冲浪音效）、#111～112（PC 画面返回）、#119（列表光标）与 CHS 有相近业务路径，但未取得 CHS 的实际触发证据，**均非已确认的 CHS Bug**。
5. **已覆盖与差异**：#096 的一代冲浪精灵外观 CHS 已用 `SeelSprite`；#099 的基本 Town Map 导航已有，新增快捷定位尚未实现；#101 的饮料机回到购买菜单/声音缩短是与 CHS 真实存在的体验差异，不是必须修复的错误。

## 状态统计

- **依赖暂缓：15 项**（#092、#093、#098、#105、#106、#107、#108、#109、#110、#113、#115、#116、#117、#118、#120）。
- **已实现：1 项**（#096）。
- **当前不适用：1 项**（#091）。
- **待核验：6 项**（#094、#095、#100、#111、#112、#119）。
- **部分实现：1 项**（#099）。
- **需评估：6 项**（#097、#101、#102、#103、#104、#114）。

## 逐笔评估（保持参考原始顺序）

| 编号 / Commit | RPP 原始标题 | 目标类别 | CHS 判定 | 当前源码/历史依据 | 移植建议 | 复杂度 / 置信度 |
|---|---|---|---|---|---|---|
| **#091** `7ef6b8c846` | fix(town-map): 调整月见山广场地图显示位置 | 参考特殊地图坐标修复 | **当前不适用** | RPP 只把 `MT_MOON_SHOP` 的地图标点 y=56 调至 52；CHS `src/data/maps/town_map_entries.asm` 没有 `MT_MOON_SHOP`，使用原有月见山/4号道路定位。 | 该特殊地图没有对应目标项，跳过；不因此断言 CHS 普通月见山图标有 Bug。 | 低 / 高 |
| **#092** `3a4f983360` | feat(fly): 新增玉虹百货楼顶特殊飞行地点 | 特殊飞行地点追加 | **依赖暂缓** | 为此前 #086～090 的特殊 Fly 列表增补 `CELADON_MART_ROOF`、访问位、落点及城市回退；CHS 有百货楼顶地图，但 `src/engine/items/town_map.asm` 仍只有普通城市 Fly 流程。 | 只在决定完整移植特殊飞行体系后统筹；不能单拿楼顶落点补丁。 | 高 / 高 |
| **#093** `ef36f660f1` | feat(town-map): 优化双子岛地图位置并同步飞行显示 | 双子岛特殊地图美术与定位 | **依赖暂缓** | 参考调整双子岛特殊 Fly 点、地图 PNG/KMP、局部 palette 与特殊地标坐标；CHS 不具有 RPP 的双子岛特殊地图节点及对应多色美术。 | 不能以 RPP 地图图案修复视为 CHS 缺陷；需连同特殊 Fly 地图数据整体评估。 | 高 / 高 |
| **#094** `8d128d1be6` | fix(town-map): 修复 Surf 状态在地图切换中的丢失问题 | 飞行地图 Surf 图标保护 | **待核验** | 参考在 Fly Town Map 强制 `hTilesetType=0` 时另行加载 Surf 图标，避免出图后显示步行；CHS `src/engine/items/town_map.asm` 也在 `LoadTownMap_Fly` 调用 `LoadPlayerSpriteGraphics`，而原地图 Surf 状态在 `wWalkBikeSurfState`。未复现 CHS 出错。 | 这是可共通的触发路径，优先做小范围 Surf→Fly Map→取消/飞行后的显示复现；确认有 Bug 才设计汉化适配修复。 | 中 / 中 |
| **#095** `e2d5f4d8d0` | fix(pokedex): 修复捕获地点返回图鉴后的角色残留 | 图鉴地区图返回时的 NPC/OAM 残留 | **待核验** | 参考在 `ShowPokedexMenu` 会话期间禁用 overworld sprite 更新并入栈恢复；CHS `src/engine/menus/pokedex.asm` 入口调用 `UpdateSprites`，没有同样的会话禁用/恢复包装。CHS 曾做 START NPC 残影修复，不能等同图鉴此路径已修。 | 用图鉴→栖息地地图→返回列表在 DMG/CGB 试一次；只有确见角色叠图才动图鉴 OAM，避免重复破坏 DFS。 | 中 / 中 |
| **#096** `380d7cff42` | fix(surf): 恢复一代冲浪精灵图标 | 一代冲浪外观图块 | **已实现** | 参考恢复 Seel 风格冲浪图块，避免改过的 Lapras 别名占用；CHS `src/home/overworld.asm` 的 `LoadSurfingPlayerSpriteGraphics` 直接使用 `SeelSprite`，已有同类一代图形。 | 无需复制参考 sprite 指针换位或图像资源；只记录效果已有。 | 低 / 高 |
| **#097** `e89e14868a` | fix(surf): 添加冲浪皮卡丘支持 | 冲浪皮卡丘特色外观 | **需评估** | 参考识别携带 Surf 的 Pikachu、保存本次冲浪使用者，并选择 SurfingPikachu 图像；CHS `LoadSurfingPlayerSpriteGraphics` 固定 `SeelSprite`，物品使用走原 `ItemUseSurfboard`。 | 新增视觉功能而非 CHS Bug；如果想做，应先审计存档空闲位、派对技能判断、图块 Bank 与强制 Surf 兼容。 | 高 / 高 |
| **#098** `0b82c8487c` | fix(town-map): 统一 Route19/20 与双子岛地图定位 | 19/20 号水道与双子岛导航分离 | **依赖暂缓** | 参考把 Route19/20 切为伪地图选择器，并按双子岛上岛锚点决定 Town Map 区域；依赖特殊 Fly 数据和新绘图索引；CHS `town_map_order.asm` 保留标准地图顺序。 | 先整体验证 #086～#093 的需求，不能移植伪地图 ID 和访问表到现有 CHS。 | 极高 / 高 |
| **#099** `829f64fc5f` | feat(town-map): 添加地图快捷定位并优化按键触发 | Town Map 选择与快捷定位 | **部分实现** | CHS `src/engine/items/town_map.asm` 已支持普通地图与 Fly 上下逐项浏览/首尾循环；但输入只监听 A/B/上下，不含参考新增的 START/SELECT 快捷定位入口。 | 已有基本导航，缺的只是新增快捷键，可按需单独设计（不要搬特殊 Fly 双轴逻辑）。 | 中 / 高 |
| **#100** `95b1274995` | fix(overworld): 优化冲浪碰撞音效触发 | 冲浪碰撞音效误重复 | **待核验** | 参考把 Surf 与障碍碰撞时的声音播放判定从音效编号改为声道 flags；CHS `src/home/overworld.asm` 仍有 Surf 状态/碰撞路径，但目前无同一现场的音效重复证据。 | 低优先级复现项；先用冲浪撞障碍听是否连续重叠，再按 CHS 自身音频引擎定位，不套参考音频声道地址。 | 低 / 中 |
| **#101** `3148a7c783` | fix(vending-machine): 优化饮料机购买流程 | 饮料机连续购买及节奏缩短 | **需评估** | 参考把取货动画从 60 次改成 30 次，成功后返回饮料选择而不是结束；CHS `src/engine/events/vending_machine.asm` 仍执行 60 次短循环并完成后 `jp DisplayTextBoxID`，没有连续购买循环。 | 真实的 QoL 差异；建议独立低/中复杂度候选，验证金钱、背包满、按 B、中文 DFS 与返回画面。 | 中 / 高 |
| **#102** `47a4b0c801` | fix(item-lists): 统一道具列表操作后的光标与返回行为 | 买卖/PC/道具列表操作后游标位置 | **需评估** | 参考新增统一 `RestoreItemListPosition` 与删除物品时列表保留位置的帮助例程；CHS `src/home/list_menu.asm`、`engine/menus/swap_items.asm` 和 `engine/menus/players_pc.asm` 有滚动及部分复位处理，但无该统一恢复函数。 | 列为 UX 候选而非已复现 Bug；先抽查最后一项删除、背包满、堆叠合并、PC 存取光标，再决定是否做统一助手。 | 中 / 中 |
| **#103** `6151c20df9` | feat(elevator): 缩短建筑电梯等待并定位当前楼层 | 建筑电梯时间与当前楼层光标 | **需评估** | 参考为建筑电梯缩短摇晃 100→40 次，同时保留渡船原 100 次并根据 warp 选中当前楼层；CHS `src/engine/overworld/elevator.asm` 仍有 100 次循环，楼层菜单 `engine/events/elevator.asm` 保存基础光标但没有匹配 warp 的查找。 | 独立 QoL 候选；有感的等待减少，但需要校验电梯音效循环、中文菜单、电梯楼层/warp 和船只脚本。 | 中 / 高 |
| **#104** `1243dbc826` | feat(summary): 重构宝可梦信息页左右切换机制 | Summary 信息页左右切换重构 | **需评估** | 参考将 StatusScreen A/B 确认式页面切换改为单会话左右切换及双 BG Map/页面构造；CHS `src/engine/pokemon/status_screen.asm` 仍以 `StatusScreen`、`StatusScreen2` 分开绘制并等待按键。 | 大型新交互，需先由用户决定是否改状态页；涉及汉化字形、DMG/CGB 传输，切勿直接复制 RPP 代码。 | 高 / 高 |
| **#105** `a909672b44` | feat(summary): 重构宝可梦信息页切换机制 | Summary 上下实时换宝可梦 | **依赖暂缓** | 参考建立在 #104 多页状态机之上，新增当前宝可梦导航、权限位、战斗/PC/START 不同调用端的返回；CHS 没有该整套实时切换状态机。 | 必须先有 #104，再决定上下切换；高依赖且风险涉及 WRAM 与用户输入。 | 极高 / 高 |
| **#106** `f6d104d4df` | feat(summary): 切换宝可梦时不再播放叫声 | 实时切换时跳过重复叫声 | **依赖暂缓** | 参考在 #105 的上下切换中删除额外 PlayCry；CHS 未引入 Summary 上下实时切换，故没有这一特定重复叫声触发路径。 | 不能把 RPP 后续表现修正列为 CHS 现有 Bug，随 #104/#105 一起评估。 | 低 / 高 |
| **#107** `4e649e600d` | fix(summary): 稳定宝可梦信息页切换与野外恢复 | 实时状态页切换后野外恢复 | **依赖暂缓** | 参考修 #104/#105 的状态页退出地图残留、CGB 调色板 VBlank 提交；CHS 没有该新 Summary 切换链，虽独立有地图返回修复，也不等于此新增问题。 | 依赖实时状态页；不要把其恢复调用替换进当前 CHS 已测试的地图/Party 路径。 | 高 / 高 |
| **#108** `b290d95b00` | perf(summary): 优化宝可梦信息页实时切换体验 | Summary 实时切换首轮性能优化 | **依赖暂缓** | 参考涉及 VBlank picture attributes、双调色板和分段画面传输；CHS 的 VBlank/DFS 机制与 RPP 参考不同，未实现 #104/#105 基础。 | 若未来选择信息页重构再看此性能补丁及后续修复；当前暂缓。 | 极高 / 高 |
| **#109** `51fb7ce3fd` | perf(summary): 优化宝可梦信息页实时切换体验 | Summary 预加载 palette 与画面 | **依赖暂缓** | 参考在 #108 上进一步把 palette 准备与 commit 分开、延迟刷页；CHS 现有 StatusScreen 并无这些准备/提交接口。 | 依赖 #104～108，不独立移植到 CHS 汉化的 VBlank。 | 极高 / 高 |
| **#110** `e128b16c55` | fix(summary): 修正实时切换宝可梦时 HP 血条颜色残留 | 新实时状态页 HP 血条颜色残留修复 | **依赖暂缓** | 参考修 #109 提前准备 palette 时，血条颜色没有跟随新宝可梦的问题；CHS 没有其新版实时切换/延迟 palette 数据流。 | 不是已确认 CHS 当前 HP 颜色 Bug；将来引入实时切换时应把 #110 作为完整修复链一并考虑。 | 高 / 高 |
| **#111** `5855eba254` | fix(summary): 修正电脑宝可梦信息页返回后的地图显示残留 | Bill PC 状态页返回地图图块残留 | **待核验** | 参考在 `engine/menu/pc.asm` 增加地图 `RedrawMapView` 解决 Summary 返回 PC 时图块残留；CHS `src/engine/pokemon/bills_pc.asm` 已有专用 `ClearBillPCMenu..._CHS`、`ClearListView_CHS`，不能直接判定有无同类残留。 | 低优先级单点检查：PC→查看 Stats→退出 PC→地图，若有残留再查 CHS 的已存在清理路径；不直接套补丁。 | 中 / 中 |
| **#112** `2e0b182b66` | fix(pc): 修正电脑菜单回退时的短暂闪白问题 | PC 菜单返回短暂白闪 | **待核验** | 参考在新版 Summary/PC 的返回路径去掉 `ReloadMapData` 以消除一帧白闪；CHS 有专门的白屏修复历史和中文 DFS 窗口重绘，但 PC 自身是否相同仍需观察。 | 若用户看到 PC 退出白闪，再逐帧看 CHS 代码；不把 RPP 现象自动视为现有 Bug。 | 中 / 中 |
| **#113** `53c33dc3cf` | fix(summary): 修正实时切换宝可梦时前图 Palette 数据残留 | 实时切换前一个 palette 残留 | **依赖暂缓** | 参考继续在 #104～110 新 Summary 动态 palette 路径中等待 StaticPaletteMapChanged 提交；CHS 不使用该动态实时页面链。 | 属于前置重构引发的 Bug 防护；只有选做实时状态页才连同验证。 | 高 / 高 |
| **#114** `52a776c3ae` | feat(pokedex): 支持图鉴详情页上下浏览已发现宝可梦 | 图鉴详情中上下浏览已发现宝可梦 | **需评估** | 参考使 Pokédex 详情无需退出到列表就能切换相邻已发现宝可梦，并保留列表入口；CHS `src/engine/menus/pokedex.asm` 使用列表→SideMenu→Data/Nest→返回列表，未见详情内上下换种逻辑。 | 实用新增功能，可独立列项，但需先核验中文图鉴资料、已见位、列表光标、状态页等共享输入。 | 高 / 高 |
| **#115** `7f74523ea1` | perf(pokedex): 优化图鉴详情页实时切换与局部刷新体验 | 图鉴详情实时切换优化 | **依赖暂缓** | 参考在 #114 详情连续切换后修输入防连发、箭头、Window/Tilemap 提交；CHS 没有 #114 详情切换路径。 | 作为 #114 的后续配套改进，不独立移植到当前图鉴。 | 高 / 高 |
| **#116** `d2a19899a6` | feat(bills-pc): 完成 Deposit Stats 实时切换与原子返回 | Bill PC Deposit Stats 实时换队伍 | **依赖暂缓** | 参考在 #073～076 连续存取及 #104/#105 Summary 实时切换基础上，Deposit→Stats 支持上下换宝可梦与列表位置回写；CHS PC 当前只有单条 Stats 进入及主菜单返回。 | 必须把 PC 连续存取和 Summary 实时切换整体设计；当前不宜直接套 RPP 菜单栈/权限位。 | 极高 / 高 |
| **#117** `51fea8137d` | feat(bills-pc): 完成 Withdraw Stats 实时切换与最终目标同步 | Bill PC Withdraw Stats 实时换盒子 | **依赖暂缓** | 参考在 #116 后支持 BOX_DATA 的详情上下切换与列表重建；CHS 的盒子 StatusScreen 单次进入且现有滚动/容量逻辑不同。 | 强依赖 #104～116，暂缓；需审查 Box 数据和退出索引同步。 | 极高 / 高 |
| **#118** `74df9eb5cf` | perf(bills-pc): 优化 Withdraw Stats Box Pokémon 实时切换性能 | 实时 Box Summary StatExp 计算加速 | **依赖暂缓** | 参考优化 #117 中频繁重算盒子属性的 StatExp 平方根，查表/二分保持数值；CHS ROM-1.21 已迁移 CalcStats 至 Bank `$2D`，但没有参考连续 BOX 切换高频调用。 | 避免因“性能优化”修改已验收能力值公式；若将来引入 BOX 实时切换再做数值等价测试和性能分析。 | 高 / 高 |
| **#119** `84af724964` | fix(cursor): 统一放生与道具合并后的列表光标恢复行为 | 放生与物品堆叠合并后光标恢复 | **待核验** | 参考补强 #102 的统一列表游标：放生后连续浏览、两个堆叠合并后定位剩余堆叠；CHS `src/engine/menus/swap_items.asm` 有独立交换/合并代码，`bills_pc.asm` 仍有释放处理，但并无相同的 RestoreMerged... helper。 | 可在当前 CHS 单独测试最后一只/堆叠合并/滚动边界；若有体验缺陷再独立设计，不照搬连续 PC 路径。 | 中 / 中 |
| **#120** `f8582e1d88` | perf(summary): 缩短 Pokémon Summary 初次加载白屏时间 | Summary 首次进入白屏缩短 | **依赖暂缓** | 参考在 #104～119 双 BG Map/实时切换基础上复用 HP/状态 Tile、按需延期构造隐藏页面；CHS 现有信息页也有白化延时，但没有这套一次性 shared-tiles hint/state。 | 性能方向有价值但本补丁高度依赖前序新 UI；若只是优化 CHS 页面速度，应独立测帧，改 CHS 正式流程而非照搬。 | 极高 / 高 |

## 建议优先讨论与暂缓内容

- **较小的独立体验候选**：#101 饮料机连续购买/缩短动画、#103 电梯等待和当前楼层定位、#099 Town Map 快捷定位（脱离参考特殊 Fly，独立设计）。这些需要用户选择，非 Bug 紧急修复。
- **值得做一次复现而非立刻套补丁**：#094 Surf→Fly Map→返回后的角色图标；#095 图鉴栖息地地图返回的角色/NPC 残留；#100 冲浪撞障碍音效重复；#111/#112 PC 状态页返回残留/白闪；#119 列表合并/放生后的光标。没问题则维持原实现。
- **中期功能整体评估**：#102 列表位置保留；#104/#105 实时 Summary；#114/#115 图鉴详情浏览。只在有具体使用需求时规划中文 DFS、WRAM、VBlank 与调用约定。
- **暂缓依赖链**：#091～#093/#098 的参考特殊地图/飞行系统，#106～#110/#113 的新 Summary 后续修复，#116～#118 PC/Box 即时浏览及加速，#120 依赖新 Summary 页面资源重用。绝不把 RPP 功能链新增的 Bug 当成 CHS 已有故障。

## 证据清单和局限

- **CHS 文件**：`src/engine/items/town_map.asm`、`src/data/maps/town_map_order.asm`、`src/data/maps/town_map_entries.asm`、`src/home/overworld.asm`、`src/engine/items/item_effects.asm`、`src/engine/menus/pokedex.asm`、`src/engine/pokemon/status_screen.asm`、`src/engine/pokemon/bills_pc.asm`、`src/engine/events/vending_machine.asm`、`src/engine/overworld/elevator.asm`、`src/engine/events/elevator.asm`、`src/engine/menus/players_pc.asm`、`src/engine/menus/swap_items.asm`、`src/home/list_menu.asm`、`src/engine/gfx/palettes.asm`，以及 `docs/CHS_ACCEPTANCE_HISTORY.md`。
- **参考文件**：原始独立补丁 `091～120` 的 diff hunk、新增辅助文件、Section/WRAM/音频依赖；提交原题和 Hash 以参考目录为准。
- 文件未找到只说明**当前源码没有同名的参考实现**，不保证类似效果完全不存在；“待核验”仅是存在共用触发可能，不代表复现失败/已修复。运行、编译、MAP、红蓝版本均未进行本批新验证。
- 本台账不是可直接应用到 CHS 的功能 Patch。选定功能后必须另行审计完整依赖与中国化显示/数据兼容，并按项目规范制作独立测试候选。

**下一批**：121～150。#269 等参考缺号留待轮到对应批次核对，不提前推断。
