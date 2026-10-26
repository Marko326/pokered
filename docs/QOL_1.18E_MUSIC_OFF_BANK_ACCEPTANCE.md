# QOL-1.18E：Music Off 音频 Bank 恢复（拟正式收口）

## 来源与基线

- 本次用户 ZIP：`QOL-1.18D.zip`，分支 `备份`，已提交 HEAD `c013f62c25ea2fac9a57a84569851a8beb6b6b25`；工作区已经包含 A1 修复。
- A1 是用户此前按 RPP 补丁应用并在 GBC 实机完成测试的最小改动；本轮是正式提交准备，不是重新开发另一版算法。
- 增量补丁以本次 ZIP 中已测 A1 工作区为起点；全量补丁以从该 ZIP 严格反向剥离 RPP `current_worktree.patch` 后的干净 HEAD 为起点。选择其一应用，不能叠加。

## 修复点

`home/audio.asm`，`PlaySound::.suppressMusic`：当 Music Off / 有效 BGM 静音过滤新音乐、取消 `wAudioFadeOutControl` 后，将 `wAudioSavedROMBank` 同步到 `wAudioROMBank`。这补回了原本只有 `FadeOutAudio` 自然完成才会执行的 Bank 恢复，防止用战斗音效表解释返回地图后的 SFX。

其余改动限于 `data/game_version.asm` 显示版本 `QOL-1.18E` 和长效文档。未改声音音符、声道处理、SRAM／WRAM 布局和硬件调色板；不修改历史提交。

## 验收边界

- **用户实际验证通过**：Music Off，1 号路遇到野生宝可梦后直接逃跑，先前异常的音效在 A1 修复版恢复正常；用户反馈“修好了”。
- **补丁静态校验**：本次收口阶段单独验证增量/全量正反套用、符号/寄存器/Bank 访问、文件权限和变更范围。
- **尚未验收**：本轮未编译 ROM、未生成新版 MAP，未重新覆盖蓝版、BGM 音量 0、连续胜利／训练师战、所有地图路径。
- **独立缺陷**：Music Off 入战画面闪烁前有瞬态“爆破音”。初步怀疑入战重置声音硬件的时序；本版不修改相关引擎代码，待单独设计测试补丁。

## 后续提交

使用本轮三件套中的 `commit-message.txt`。用户需在 RPP Mobile 自行 Git Commit/Push；ZIP 自身不构成提交事实。
