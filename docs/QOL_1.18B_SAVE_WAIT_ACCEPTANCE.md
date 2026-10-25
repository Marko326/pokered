# QOL-1.18B：缩短存档完成等待（用户反馈测试通过）

## 基线与来源

- 原始正式基线：`CGB-1.17`，HEAD `9c1d66a5356479675d318d957cc62b15ff224f69`。
- 前置已测工作状态：`QOL-1.18A`，包含战斗受击闪烁 6→4 与普通对话字体预加载；用户已反馈这两项测试通过。
- 本次测试版：`QOL-1.18B`。
- 参考来源：参考项目 `individual/020`，Commit `16f6a942110c91868eccd73be3b10dcb8cdd2681`，提交主题“缩短游戏保存时间”，说明为删除 `Now saving...` 文本并加快存档速度。

## 本次改动

在主项目 `engine/menus/save.asm:SaveMenu` 中，`SaveGameData` 返回后直接显示 `GameSavedText`。移除原先的 `ClearScreenArea`、`PlaceString`、`NowSavingString` 以及固定 `DelayFrames` 120 帧等待。

保留：

- 原版是否保存的 Yes/No 确认；
- 旧存档覆盖确认；
- `SaveGameData` 实际存档路径；
- `GameSavedText` 保存成功提示；
- `SFX_SAVE`、`PlaySoundWaitForCurrent`、`WaitForSoundToFinish` 与之后 30 帧等待。

未增加快捷键、未绕过确认、未改变 SRAM/存档布局。实际节省的时间取决于原有存档写入耗时；移除的是额外固定的 120 帧等待，不代表 SRAM 写入本身变快。

## 用户测试反馈

- 用户反馈“没问题”，确认本项测试通过。未提供逐项测试场景，因此本文不扩大表述为所有存档边界均已覆盖。

## 静态检查与待验收范围

- 已检查 `NowSavingString` 在该文件中仅用于原保存流程，删除后无残留引用。
- 未新增符号、WRAM、HRAM、SRAM 字段或 Bank 调用。
- 尚待用户本地构建及 ROM 运行验证；本环境未编译 ROM，未产生新 MAP。
- 建议至少测试：新存档首次保存、已有存档覆盖确认与取消、保存成功提示/音效、保存后继续移动、完全退出后重新载入存档。
