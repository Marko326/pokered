# ROM-1.3：ROM0 空间清理验收记录

## 修改范围

- 基线：`CHS_Mod` 已提交的 `SAV-1.2`，HEAD `1d7c62e530a4d0e2292eda814de0d08a651150dd`。
- 参考 QOL 工程两次独立的 ROM0 空间迁移提交：`6154ae4697`（列表/数量菜单）和 `9bae450394`（数字格式化）。
- 列表绘制主体移到 ROMX Bank `$0F`，数量选择与数字格式化主体移到 ROMX Bank `$2D`；ROM0 保留原调用入口。
- 沿用汉化版列表布局、数字字符编码、状态变量和菜单交互；不修改 SRAM、WRAM、存档格式及音频功能。
- 正式版只将主菜单标识 `ROM-1.3A` 清理为 `ROM-1.3`，并更新注释和维护记录；没有再次修改已测试过的功能逻辑。

## 用户测试与 MAP

- **用户实测**：已测试本轮移植的功能，反馈暂未发现问题。
- **候选版 MAP**：`all_maps.zip` 中 `buildRB/pokered.map` 和 `buildRB/pokeblue.map` 的 ROM0 均为使用 15500 字节、剩余 884 字节。
- 迁移符号已位于 ROMX：`PrintListMenuEntries_` 在 Bank `$0F`，`DisplayChooseQuantityMenu_` 与 `PrintNumber_` 在 Bank `$2D`。
- **正式版 MAP 待核对**：`ROM-1.3` 缩短了一个版本号字符；上述余量仅属于此前 `ROM-1.3A` 候选版，不直接冒充正式版新链接结果。

## 交付边界

- 本轮清理补丁的正反向应用、变更文件字节一致性及权限将单独校验。
- 未由 AI 编译 ROM；没有执行用户仓库的 Git Commit/Push。
- 日后新增功能优先考虑 ROMX，必须检查 Bank 引用和红蓝版 MAP。
