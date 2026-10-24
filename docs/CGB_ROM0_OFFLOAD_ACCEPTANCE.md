# CGB-1.13 — ROM0 调色板主体迁移验收与交接

## 目的与准确来源

- 上一正式版：`CGB-1.12`，用户 ZIP 的 HEAD `2a7930684b82d7b000932929c0b0a5b31e335cd1`（干净源码）。
- 上轮测试增量：`rom0-cgb-palette-offload-112A-20261024-R1`，内测显示 `CGB-1.12A`。
- 本轮用户表示先前要求测试的常规场景均已完成，并明确要求制作正式清理三件套。
- 本轮仅将可见版本号正式更新为 `CGB-1.13`，清理新代码的测试后缀注释，增补长期资料；**不重写已测试的运行时代码**。

## 本次源码改动（从 1.12 到 1.13）

| 文件 | 调整 | 所在 Bank |
|---|---|---|
| `home/cgb_mode.asm` | 保留 CPU 速度管理、BGP/OBP 快速检测、OAM 属性修正；检测到调色板变化才远调用完整映射 | ROM0 |
| `engine/gfx/cgb_palette_bank.asm` | 新增默认红蓝配色初始化与完整 RGB555 映射 | ROMX 浮动 Section |
| `home/init.asm` | 初始化入口改为 `farcall InitCGBDefaultPalette` | ROM0 调用方 |
| `main.asm` | 定义 `SECTION "CGB Palette Compatibility", ROMX` 并 INCLUDE 实现 | ROMX |
| `home.asm` | 保留固定 Bank 包装代码 INCLUDE | ROM0 |
| `data/game_version.asm` | 从 `CGB-1.12` 经测试候选 `CGB-1.12A`，正式改为 `CGB-1.13` | ROM0 |

默认颜色表、原有跑步和自行车函数、CPU 1x/2x 决策、存档布局均未更改。

## 实测和证据边界

- 用户反馈：已经完成上一轮所要求的测试，常规场景没有报告问题。先前测试清单包括红/蓝版本启动配色、野外 NPC、菜单、战斗/渐变及战斗退出颜色、场景切换，以及持续跑步和骑车流畅度。
- 这是**用户反馈的汇总**，不代表在本环境重新运行模拟器，也不能把未提供的逐项帧率/KEY1 数值编造出来。
- 之前版本曾由游戏内临时诊断证明 CGB 野外 CPU 2x、战斗 CPU 1x、跑步 8 帧/格和自行车 4 帧/格；本轮 ROM0 迁移未改这些算法，但不替代新版寄存器专项重测。
- **未验证**：CGB-1.13 的新链接 MAP、最终 ROM0 真实释放空间及 ROMX 安放 Bank；按项目要求本环境不编译。

## 空间与安全性

- 旧版本 MAP：ROM0 记录剩余约 768 B；上轮静态估算测试版增加约 97 B 空间，正式字符串比测试版短一字节，因此约 98 B 是**估算**，不是新 MAP 结论。
- 保持 VBlank 检查在 ROM0，未变化则直接返回；有变化才 `farcall` ROMX 颜色映射。
- 仅在 `main.asm` 末尾增加独立浮动 ROMX Section，不移动地图、音频、存档数据。

## 后续交接

1. 用户在 RPP Mobile 自行提交本版后，以实际 Commit Hash 更新项目基线；未提交前仍以 `2a793068` 为最后已确认来源 HEAD。
2. 下次导出提供新的 MAP，核对 ROM0、ROMX 用量与版本字符串。
3. 后续基础功能先核对 `TODO.md`；新增任何 VBlank 跨 Bank 逻辑时检查本文件和 `RPP_DEVELOPMENT_PITFALLS.md`。
