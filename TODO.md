# CHS_Mod 工程待办

## 增量构建修复（待用户收口）

- [x] `buildRB/` 按文件同步，保留不相关 `.o` 编译缓存。
- [x] Excel 导入先在临时目录完成，仅同步内容变化的输出。
- [x] 根目录 `make` 在每次调用时检查内部依赖，避免无意义覆盖 ROM。
- [x] 保留旧版多 RGBDS 模式的强制重编行为及 RPP 手机 ROM 导出。
- [x] 静态检查补丁正反向应用、源码一致性、文件权限；不编译 ROM。
- [ ] 用户在 Termux 完成两次连续 `make red` 和普通 ASM 修改后的增量编译测试。
- [ ] 用户确认后在 RPP Mobile 自行 Git Commit/Push，并更新已提交 HEAD。

验收记录：`docs/CHS_INCREMENTAL_BUILD_ACCEPTANCE.md`。

## 主菜单版本号（VER-1.0 正式版清理）

- [x] 添加单一 ROM0 版本字符串，在主菜单左下角显示。
- [x] 将测试标识 `CHS-1.0A` 规范为正式标识 `VER-1.0`（去掉字母后缀）。
- [x] 从 Options、Continue 入口清除该标签；Options 不显示版本号。
- [x] 补丁及符号引用静态检查，不编译 ROM。
- [ ] 用户用官方 RGBDS 1.0.4 验证红版、蓝版链接和主菜单显示。
- [ ] 用户验证无存档/有存档、进入/返回 Options、Continue 后无文字残留。
- [ ] 用户确认游戏内显示及 RPP 手机 ROM 导出功能正常后再正式提交。
