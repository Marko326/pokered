# 第一世代野外技能交互：CHS 实现与维护注意事项

## ROM-1.36 当前范围

- RPP #031：居合斩（Cut）面对树木按 A 的条件判断与询问。
- RPP #032：冲浪（Surf）面对水面按 A 的条件判断与询问。
- RPP #033／#034：怪力（Strength）面对巨石按 A 的询问及队伍菜单重复提示收口。
- RPP #036：挖洞／瞬间移动使用前确认（原始用户 Worktree 已包含）。
- RPP #035 野外头槌不适用于本项目第一世代 Field Move 系统；战斗招式 HEADBUTT 不等于野外撞树脚本。RPP #381～#385 钓鱼快捷操作另立专项。

## A 键分派顺序

1. 保留原隐藏物交互：未领取的隐藏物仍优先领取。
2. 对面前精灵先判断是否为巨石；巨石交互完成后直接回地图。
3. 普通 NPC／告示牌继续原 `DisplayTextID` 路径。
4. 没有精灵或告示牌处理时，才检查背景树木／水面。

已领取隐藏物不能继续吞掉同坐标的树木 A 键；但未领取隐藏物优先级不能被改变。

## 可复用的 CHS 陷阱

- **返回状态用 Carry，不要借用 `wWhichTrade`**：NPC 交易状态是独立业务数据。`HandleStrengthBoulderOnA` 以 Carry 表示“已处理巨石”，Overworld 分派器必须检查 `jp c`，否则对话结束后会落入 NPC 文本路径。
- **精灵索引语义必须按 CHS 核对**：本项目应从 `hSpriteIndexOrTextID` 取得前方精灵 ID，并直接索引 `wMapSpriteData`；不要照搬假设 `hSpriteIndex` 已指向目标精灵的参考实现。
- **`WriteOAMBlock` 的数据形状不是 `dbsprite`**：它读取四组 `(tile ID, attribute)`。砍树／怪力粉尘动画表应显式写出四对数据；不能使用会展开为屏幕位置记录的 `dbsprite` 宏。
- **CHS 中文文本使用 DFS 双字节字形 ID**：新提示直接按已核对的 DFS 编码写入；不要把 UTF-8 中文字面量直接塞入汇编文本。
- **Yes/No 与 Party 备份区**：队伍菜单已将画面保存到 Buffer1；不要在该路径盲用会覆盖同一备份区的 `YesNoChoice`。当前确认菜单使用两选项窗口并恢复原 Party 画面。
- **Surf 限制复用原函数**：使用 `IsNextTileShoreOrWater`、`TilePairCollisionsWater` 与 `IsSurfingAllowed`。后者可能已输出自行车道／双子岛水流限制提示，不要再追加重复滚动文本或绕过其状态位。
- **Cut 的两条执行路径不同**：队伍菜单继续使用 `UsedCut` 的原有白屏／地图重载流程；地图 A 键用 `Cut2` 跳过该重载，但仍保留宝可梦名字、成功文本、动画和音效。不要把两条入口合并成同一条而重新引入白闪。
- **文字速度与调色板**：居合斩成功提示不要强制设置 `wd730 bit 6` 为无延迟；动画 OAM 属性必须与 CHS 的 DMG/CGB OBJ1 语义一致。不要把 RPP 的专用绿色 OBJ6 直接映射到 CHS 的 OBJ0/OBJ1。
- **Bank／内存边界**：野外 A 键主要逻辑放在 ROMX Bank `$30`；ROM0 只保留必要分派入口。当前未新增 WRAM/SRAM/存档字段。最终空间余量必须由维护者本地 RGBDS MAP 确认，不能拿 ROM-1.35 MAP 代替最终构建结果。

## 回归最小集

- Cut：可砍树四象限、技能／徽章缺失、否／B、A 键无白闪、Party 菜单原路径、普通装饰树不误触发。
- Surf：有／无 Surf 宝可梦、否／B、原水岸碰撞与自行车道／双子岛限制。
- Strength：有／无 STRENGTH、彩虹徽章、否／B、是、已启用后再次调查、队伍菜单、普通 NPC／告示牌、推石／粉尘动画。
- Dig／Teleport：可用与不可用地图、是／否／B、原返回治疗点与 Party 菜单返回。

静态源码检查不等于 RGBDS 链接或手机实测；验收范围按维护者实际反馈记录，不扩大为全平台矩阵。
