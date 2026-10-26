# CHS_Mod 主菜单版本号正式清理与验收记录

## 范围

- 工程基线：`CHS_Mod` HEAD `90d215cc045437517b86019e95591aaf994505dc`，已包含增量构建修复。
- 参照 `QOL-1.18F` 的 `GameVersionText` / `DrawMainMenuVersionText`，但移除 Options 显示，只保留主菜单绘制和进入其他页面前的清理。
- `src/data/game_version.asm` 统一维护正式标识 `VER-1.0`（由测试标识 `CHS-1.0A` 规范化），ROM0 与 Bank 1 的读取路径对应；不改变 SRAM/WRAM。
- 未修改翻译 Excel、构建脚本、ROM 复制流程以及现有 `src/_build.command`。

## 验收边界

- 清理范围：版本字符串及注释、维护说明、TODO、验收记录；菜单显示位置、清除逻辑及 Options 行为均保持不变。
- 增量补丁以前次已交付的 `CHS-1.0A` 主菜单版本号补丁为前置；全量补丁基于本轮用户提交的干净 HEAD `90d215cc`。两者不可叠加。
- 补丁正反向、字节一致性、权限、静态符号与引用：交付前检查。
- AI 未编译 ROM、未做模拟器测试；本项目 ZIP 未附带与 CHS 当前 HEAD 匹配的 MAP，因此 ROM0/ROMX 最终空间以用户本地链接为准。
- 待用户本地核实：Red/Blue 链接、主菜单有/无存档显示、Options 不显示、Continue 信息页无残留、返回主菜单后重新显示。
- 所有 Git Commit/Push 操作由用户在 RPP Mobile 完成。
