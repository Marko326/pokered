# 开发踩坑与防回归记录（version 项目）

本文件只记录可复用的工程经验，不照搬参考项目 Red++ 的地区形态、扩展招式和存档变更记录。

## CGB-1.12：原生 CGB 与 SGB/DMG 调色板不能混用

- CGB ROM 头、`hCGB` 判定、WRAM 清零后标志保存、CGB 调色板初始化必须配套检查；仅开启 `KEY1` 不等于完成显示兼容。
- 不能把 SGB 的分地图调色板当作原版 GBC 红版/蓝版的默认配色。红版 BG 红系、OBJ 绿系；蓝版使用对应版本配色。DMG 路径保持原本画面。
- DMG 精灵属性低位可能是游戏内部标记，CGB 会解释为调色板选择位；输出 OAM 前应只保留合法的 CGB 属性值。
- 游戏可见版本和模拟器选择的 CGB/DMG 模式不是同一件事；测试应明确 ROM 版本与实际硬件模式。

## CGB-1.12：不要把 CPU 2x 与显示 60 FPS 混为一谈

- CGB `rKEY1` bit 7 可确认当前 CPU 速度；录屏标称 60 FPS 不能证明硬件 2x，也不能证明每帧都更新游戏逻辑。
- 保留已经验证过的连续跑步 8 帧/格、自行车 4 帧/格逻辑；跨场景 CPU 1x/2x 切换需要核对战斗和返回野外。
- 临时诊断入口/计数器只能在测试补丁存在，收口必须撤销并逐字节核对；不能混进正式版本。

## CGB-1.13：ROM0/ROMX 调色板迁移

- `home.asm` 处于 ROM0 Section，直接 INCLUDE 的新例程默认占用固定 Bank。需要把大部分低频主体放在独立的 ROMX Section。
- `InitCGBDefaultPalette` 与 `UpdateCGBDmgPalettesBanked` 在 ROMX；跨 Bank 调用必须用 `farcall`，并检查当前 Bank 恢复和寄存器副作用。
- VBlank 高频路径先比较 BGP/OBP 缓存，仅变化时再跨 Bank 映射；不能为了省 ROM0 字节在每帧无条件切 Bank。
- CPU 速度切换、VBlank 调度和 OAM DMA 前的属性修正仍留 ROM0；不要未经时序测试全部移到 ROMX。
- `ROM0 slack`、静态指令长度估算、旧 MAP 不等于已链接的可用空间。旧 `CGB-1.12` MAP 报告 768 字节剩余；本次静态估算约净释放 98 字节（正式版本字符串缩短 1 字节），**必须用 CGB-1.13 新 MAP 核实**。
- 移动代码、红蓝版调色板数据、WRAM/SRAM 布局在本次优化中不得变化。

## BIKE-1.13A：固定音乐 Bank 可能因新增 SFX 溢出

- `layout.link` 将音效头、音效引擎和音乐分别集中在固定 ROMX Bank `$02` 与 `$1f`；这些不是可自由扩充的 ROMX Section。
- 新增自行车音效后，`Music 1` / `Music 3` 在链接时分别溢出 27 / 33 字节。补丁可套用、符号存在并不等于音乐 Bank 有空间。
- `audio/sfx/unused_cry_1.asm` 与 `unused_cry_3.asm` 的三个声道均注释 `unreferenced`，也未列在任何 SFX header；保留原始样本内容和符号，仅将两个 INCLUDE 转到浮动 ROMX Section，以释放每个音频 Bank 约 76 字节。
- 不移动实际在用的音乐、音效、音频引擎，也不扩展 ROM0；必须通过用户本地链接及手机实测确认音效和背景音乐正常。
- BIKE-1.13A R4：按用户需求撤回新增的上/下车专用音效，连同之前为音效迁移的 unused cry 一起还原原 CGB-1.13 音频布局；上述溢出问题保留作历史教训，不再是 R4 的待测项。

## 交付纪律

- 先核对用户 ZIP 和项目长期要求；补丁可套用不代表 ROM 一定能汇编链接或模拟器行为完全正常。
- 不修改历史文件权限、原本 ASM 对齐或非本次主题的源码；测试范围与未实测边界分开记录。

## BIKE-1.13A R5：连续 PrintText 不能替代对话翻页

- R4 在车店老板原有 `done` 文本后紧接调用第二个 `PrintText`，未等待玩家按 A/B，后续文本会自动覆盖上个对话框。
- R5 把 SELECT 快捷说明直接并入已持有自行车时的原有 `para` 分页文本；`para` 使用引擎的 `ManualTextScroll` 等待 A/B，避免第二次立即 `PrintText`。
- 首次兑换券交车路径不再追加 SELECT 说明，不额外占用 SRAM 或引入首次提示变量。
