# QOL-1.19：CGB 双速模式下 OAM 调色板转换时序验收

## 基线与范围

- 基线：用户本轮提供的 `QOL-1.18F.zip`，干净 HEAD `27e5fd06cfed9a8ae7c342a2265ed96f10ca4b57`。
- 参考测试状态：`QOL-1.18I`，由上述 F HEAD 加入双速 OAM 转换分流补丁；用户已反馈测试无异常。
- 正式收口版本：`QOL-1.19`。本次仅收口 CGB OAM 转换时序修复，不包含此前 G/H 音频试验候选。

## 问题与处理

- 原始 1.12 路径在 VBlank 中、OAM DMA 前无条件执行 `CGBFixOAMPalettes`；CGB 战斗运行 1x 时，队伍列表第一只宝可梦图标曾出现白色横线。
- 将转换统一移到 `DelayFrame` 虽能避开战斗 VBlank 的额外工作，但用户测试发现 CGB 野外 START 菜单中的玩家精灵下半身出现异常颜色。
- 最终采用 CPU 速度分流：CGB 2x 在 VBlank 的 OAM DMA 前执行转换；CGB 1x 在 `DelayFrame` 等待前执行转换；DMG 跳过 CGB 专用转换。
- 保留 `UpdateCGBDmgPalettes` 原有 VBlank 更新、`hDMARoutine` 与 `PrepareOAMData` 顺序，以及原有 CPU 速度策略。

## 验收状态

- [x] 用户反馈 `QOL-1.18I` 测试版本无异常；本轮针对的战斗 Party 图标白线与野外 START 玩家精灵颜色问题均已解决。
- [x] 正式收口时将游戏内版本标识与 ASM 注释从测试标记 `QOL-1.18I` 更新为 `QOL-1.19`。
- [x] 不修改音频逻辑、移动规则、WRAM/SRAM 布局或存档字段。
- [x] 静态符号、调用路径、寄存器保护及补丁双向套用检查通过；未编译 ROM。
- [ ] 用户在 RPP Mobile 中执行 Git Commit/Push；本文件不代表已提交。

## 未包含事项

- QOL-1.18F 记录的战斗结束后单点爆破与战斗后存档音效异常仍是独立遗留问题，未在本版本修改或验收；详见 `QOL_1.18F_AUDIO_OPEN_ISSUES.md`。
- 本轮未生成新 MAP，ROM0/ROMX 空间仍需由用户本地构建后核对。
