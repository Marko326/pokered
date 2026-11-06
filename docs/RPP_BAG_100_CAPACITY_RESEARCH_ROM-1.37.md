# RPP 背包 100 槽实现研究（ROM-1.37，2026-11-05）

> **仅研究，不改容量／存档。** 本研究依据用户交接资料中 `RPP参考工程_HEAD源码快照_只读` 的实际源码，与 2026-11-05 提供的 ROM-1.37 CHS 源码逐项比较。两份源码不同构，不能直接套用常量修改。

## RPP 到底怎样做到 100

1. RPP `constants/misc_constants.asm` 定义 `BAG_ITEM_CAPACITY EQU 100`，同时 `PC_ITEM_CAPACITY EQU 70`（是另一个参数）。
2. RPP `wram.asm` 定义 `wNumBagItems` 1 字节、`wBagItems` `ds BAG_ITEM_CAPACITY * 2`，后面再 `ds 1` 作 `$ff` 终止标记，即 **1 + 100×2 + 1 = 202 字节**。
3. `engine/items/inventory.asm` 的 `AddItemToInventory_` 用传入地址是否等于 `wNumBagItems` 判断是背包还是 PC；分别以 100／70 为可占用 **物品槽数量** 上限。每槽存 item ID + quantity 两字节。已有条目数量达到 100 时，该例程仍按每槽最多 **99 个**处理，超过 99 可分裂到新槽（有空位时）。因此“100 格”与“每件叠 100 个”是两码事。
4. RPP 的 5-Pocket 分类（#078～#082）在现有 `wBagItems` 之上使用 Slot Map 建立不同显示视图，**并没有把原始物品库存分成 5 份存储**。100 槽容量与是否采用分类 UI 是相互独立的概念。
5. RPP 已包含面向 100 槽的列表扫描和索引计算；例如 `engine/menu/bag_pockets.asm` 对最大 100 物品建立序号映射。参考 `#080 8f10d2186c78` 原始提交中的 100-slot ITEMLISTMENU 备注。

## 对照 CHS ROM-1.37

| 项目 | RPP HEAD | CHS ROM-1.37 |
|---|---|---|
| Bag 槽上限 | 100 | 20（`src/constants/menu_constants.asm`） |
| PC 槽上限 | 70 | 50 |
| 原始库存 | `wNumBagItems` + 2 字节/槽 + `$ff` | 相同结构，当前仅 20 槽 |
| 分类视图 | 5 Pocket + Slot Map | 无；传统单列表 |
| 每槽最大叠放 | 99 | 99（相同基础逻辑） |
| `wBagItems` 起始地址 | RPP `wram.asm` 注释 `$d32f` | CHS MAP `$d31e` |
| `wPlayerMoney` 地址 | RPP 注释 `$d3f8` | CHS MAP `$d347` |
| 主数据结束 | RPP 独立布局 | CHS MAP `wMainDataEnd = $da80`，紧接 `wBoxDataStart = $da80` |

## 为什么不能给 CHS 直接把 20 改为 100

- 现有 CHS 数据段 `wBagItems:: ds BAG_ITEM_CAPACITY * 2 + 1`，从 20→100 会**新增 160 字节**。`wPlayerMoney`、后续 WRAM 标签及 `wMainDataEnd` 均会顺延，牵涉依赖地址的原有代码和其他 WRAM 相邻段。
- `src/ram/sram.asm` 用 `ds wMainDataEnd - wMainDataStart` 配置主保存块；`src/engine/menus/save.asm` 用同一长度保存、读取和计算校验和。扩大后会改变 SR​AM 中紧随主数据的精灵、队伍及当前盒子偏移，**旧存档不能自然兼容**。
- CHS 当前 MAP 中 `wMainDataEnd` 与 `wBoxDataStart` 都在 `$da80`。若粗暴增加 160 字节，不同步重排内存布局便会产生越界／覆盖风险。不能据此宣称“参考 RPP 100 格证明 CHS 可以直接改常量”。
- 若未来确实想扩容，应单独设计新 WRAM/SRAM 布局或把物品移到专用存储区，确定旧存档迁移策略，并全面验证拾取、商店、PC、使用、丢弃、交换、保存读档及 RAM 上限。**这轮一项都不动**。

## 本轮结论

先实施独立于容量的 HM02 教学和 CHS 单列表物品描述；保留既有 20 格容量、没有分类菜单、也不新增 START 跳末项快捷键。RPP “100 槽”保留为独立的技术评估项，未得到维护者实施授权。
