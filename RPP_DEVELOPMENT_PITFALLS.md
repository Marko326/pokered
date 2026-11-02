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

## QOL-1.18D：音乐音量与软件声道交错

- 该工程独有三套固定音频 Bank；参考项目 Crysaudio 的 BGM 音量补丁不可以直接拷贝，统一的 NR50 是 SFX/叫声也用的主音量，不能用来独立调节 BGM。
- 通常音乐 CHAN1–4 直接写 envelope/NR32，音乐 CHAN4 鼓点却通过 `Audio*_PlaySound` 放到 CHAN8 播放；需要识别音乐触发的鼓点和真正的 SFX，不能仅凭 CHAN8 一概衰减。
- 主存档复用旧字节时必须查明新游戏清空范围、启动直接读取 SRAM 和主菜单重新加载存档的路径；只改 `wram.asm` 存储标签会丢设置。
- 固定音乐 Bank 2/1f 在 QOL-1.18C MAP 中已接近末端，新增引擎钩子需避开重复大例程；未引用 cry 音源可原样放浮动 ROMX，不能凭旧 MAP 宣称新链接一定成功。

## QOL-1.18D R2：数码显示与键盘长按

- `PrintNumber` 不会清除被省略的前导零位置：两位 `10` 改成个位 `9` 时，会留下旧的十位 `1`，视觉出现 `19`。绘制前必须主动擦除两格显示位置，不能据此判断音量逻辑越界。
- `JoypadLowSensitivity` 使用 `hJoy7` 决定首次按键或保持键；只针对音量行临时改为长按模式，退出调用立即恢复，并以 `hJoyPressed` 过滤非左右键重复，避免影响其他菜单。初始长按延迟为 30 帧，连续调整以 10 帧一档限速。

## QOL-1.18D R3：选项值的位置与参考布局

- 参考项目的音量数字不在选项文字尾部，而是画在第二框底行的固定两格（x=2–3, y=8）；只有 0–9 时十位必须显式绘空格，10 才占满两格。不要使用会留下残字的 `PrintNumber` 前导零省略模式。
- 参考项目 `Music Volume:` 后不带多余的按键提示；复用它的固定坐标时应同步清除旧文案，否则会产生多余 UI 和视觉错位。移除已无调用者的临时 WRAM 字节时维持保留区总长度不变。

## QOL-1.18E：Music Off 取消 Fade 时必须同步音频 Bank

- 音频 Bank 与背景音乐是否实际发声是两回事。地图 BGM 目标的 `wAudioSavedROMBank` 通常在跨 Bank 淡出完成后才复制到 `wAudioROMBank`。
- Music Off 拦截 BGM 并清零 `wAudioFadeOutControl` 会跳过 `FadeOutAudio` 的正常收尾；若没同步 Bank，野生战斗返回地图后会把地图音效 ID 按战斗音效表解析，导致存档、碰撞、跳台音异常，Start／菜单音可因两表同号音效而看似正常。
- 正式修复为 `home/audio.asm` 的 `.suppressMusic` 同步 `wAudioSavedROMBank`→`wAudioROMBank`；用户已在 GBC 验证 Music Off 战斗逃跑后的音效恢复正常；不要为了掩盖问题改动 SFX 音符。
- Music Off 入战闪烁前的瞬态爆破音属于**独立未解决问题**；`PlayBattleMusic` 调用 `SFX_STOP_ALL_MUSIC` 时会在声音引擎里重置 `rAUDTERM`、音量包络等硬件寄存器，可能是声道路由瞬态，不能未经实机验证就改变整个音频引擎。

## QOL-1.18F：音频问题收尾不能将不同症状当作同一原因

- 本轮工作区是 `e03f27ac`（QOL-1.18E）HEAD 加 `QOL-1.18F.patch`。后续讨论过的 G/H 测试方案不能未经确认就视为已包含在当前工作区。
- 用户仍报告**战斗结束返回野外时单点爆破**；此前测试里也出现过连续短脉冲。它与主菜单、入战或其他转场的爆音是否同源，目前没有充分运行时证据，不能用“已修复”概括。
- 用户仍报告**战斗后存档音异常**；飞空后曾恢复，START 开关 Music 不足以恢复，Music On 下亦可能出现。这提示排查应覆盖地图恢复、音频 Bank 和声道状态，但**不能仅凭现象断言根因是 Bank**，也不要未经验证改动原始 `SFX_SAVE` 音符。
- QOL-1.18E 已验证的是 Music Off 下**直接逃跑**后的一条 SFX 恢复路径；“击倒后返回野外、连续战斗、立即存档”属于不同场景，不能将前者的验收结果外推。
- 此次仅归档两项未解决缺陷并制作文档收尾补丁，不修改音频代码；后续应以完整当前工作区/补丁链及实机录音复现为基线重新定位。


## QOL-1.19：CGB 1x/2x 必须分流 OAM 属性转换时机

- `CGBFixOAMPalettes` 需要在 OAM DMA 前处理 `wShadowOAM`，但不能把所有 CGB 速度都固定放在同一个时机。
- CGB 战斗 1x 在 VBlank 中额外遍历 40 个 OAM 属性会增加敏感路径负担；将 1x 转换放到 `DelayFrame` 等待前，避免把这段工作留在 VBlank。
- CGB 野外 2x 必须保留 VBlank 内、DMA 前的转换路径；只把转换统一移到 `DelayFrame` 会造成野外 START 菜单人物精灵颜色回归。
- 用 `hCGB` 区分 DMG/CGB，再用 `rKEY1` bit 7 区分 1x/2x；DMG 跳过 CGB 专用转换。`CGBFixOAMPalettes` 会使用 B、DE、HL，`DelayFrame` 调用点必须保护这些寄存器；AF 本来就由等待逻辑改写。
- `VBlank`、`DelayFrame` 与 `CGBFixOAMPalettes` 均位于 ROM0/HOME；该调用不需要跨 Bank，也不访问调用方 ROMX 数据。
- 验收至少同时覆盖 CGB 战斗 Party 第一只图标、CGB 野外 START 玩家精灵、DMG 路径；单独修复其中一条路径不代表另一条路径正常。
