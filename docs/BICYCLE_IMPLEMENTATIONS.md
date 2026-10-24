# 自行车实现对照与 SELECT 快捷操作

本文件记录当前 CGB 项目、Red++ 参考项目与 PureRGB 的自行车差异。功能状态以源码为依据；CGB-1.13A 的快捷键和自行车店提示文本仍待手机实测。

## 三方差异

| 项目 | 普通步行 | 按住 B 步行 | 自行车 | SELECT 功能 |
|---|---:|---:|---:|---|
| 本项目 CGB-1.13 基线 | 16 帧/格 | 8 帧/格 | 自动 4 帧/格 | 原本没有快捷骑车 |
| Red++ 参考项目 | 16 帧/格 | 8 帧/格 | 自动 4 帧/格 | SELECT 骑车；还有更复杂的钓鱼/杆子路由 |
| PureRGB | 16 帧/格 | 8 帧/格 | 普通 8 帧/格，按 B 达到 4 帧/格 | SELECT 快捷骑车/钓鱼入口；包含额外场景功能 |

帧数表示稳定连续移动时每走一格所需的游戏帧数。17 号道路、剧情移动、跳台、冲浪等特殊路径另有保护。

## 相关源码

- 本项目速度实现：`engine/overworld/player_speed.asm`，由 `home/overworld.asm` 调用。
- 本项目自行车限制：`home/overworld.asm:IsBikeRidingAllowed`、`DoBikeSpeedup`。
- Red++ 快捷路由：`engine/overworld/bike_shortcut.asm:TryRideBike`、`TryFishOrRideBike`；它会复用原本的 `UseItem` 流程，并处理提示框/清理。
- PureRGB 快捷路由：`engine/overworld/select_button_functionality.asm:CheckForRodBike`；音效在 `engine/items/item_effects.asm:ItemUseBicycle` 中接入。
- PureRGB 上车音符：`audio/sfx/press_ab_1.asm`、`press_ab_3.asm`。
- PureRGB 下车音符：`audio/sfx/teleport_enter2_1.asm`、`teleport_enter2_3.asm`。

## CGB-1.13A 测试方案（R5：修复对话翻页，不另加上下车音效）

- SELECT 只负责骑上/收起自行车；不加入 SELECT 钓鱼、钻地或其他快捷功能。
- 保留本项目自动 4 帧/格自行车与 8 帧/格 B 键跑步，不引入 PureRGB 的按 B 骑车加速规则。
- 快捷实现放 ROMX；ROM0 只增加必要的输入分流，尽量不挤占 Bank 0。
- 使用现有自行车状态、精灵加载、音乐切换例程；不新增 SRAM/WRAM 状态字段。
- SELECT 快捷骑车不另播放上/下车专用音效；保留自行车 BGM 和背包原有提示。
- 自行车不存在、当前冲浪、脚本控制、跳台/钓鱼、强制骑行或不允许骑车的地图时，不应切换状态。
- 不增加首次/后续骑车判定及 SRAM 标记；交车时保留原文不加提示，持有自行车后再次与老板交谈才显示 SELECT 快捷说明，沿用原对话的 A/B 翻页。
- R4 已移除 R2/R3 新增音符与其音乐 Bank 腾位调整；保留原有音频布局。

## 手机验收清单

1. 普通道路 SELECT 上车，再 SELECT 下车；确认人物图块、移动速度和 BGM 正常。
2. 不应出现专门的上车铃声、下车短音效；自行车 BGM 正常切换。
3. 已拥有自行车后与老板交谈，SELECT 说明须按 A/B 翻页，不应自动跳出下一段；首次兑换不再额外插入提示。
4. 没有自行车时 SELECT 不应改变状态。
5. 室内/禁止骑车地图、冲浪、剧情控制、跳台/钓鱼状态不应切换。
6. 17 号道路强制骑行不能被 SELECT 取消。
7. 测试红版、蓝版各一次，确认人物配色没有回归。

当前状态：代码与文档补丁候选已制作；没有编译 ROM，也没有模拟器实测。测试通过前保留 `CGB-1.13A`。
