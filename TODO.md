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
