# QOL-1.16 START 二级菜单进入 / 返回显示优化计划

状态：`QOL-1.16` 正式收口（A→F 候选已完成 CGB/DMG 集中回归）
基线：正式 `QOL-1.15` 交接包
参考实现：RPP 历史提交，重点为 `758cef5f`（328），并对照 065 / 121 / 122 / 130 / 131
策略：**先把 CGB 路径做稳并冻结，再只处理 DMG 专属差异；共用问题只改一次。**

## 1. 为什么要按“共用 / CGB 专属 / DMG 专属”拆

同一个 ROM 在 CGB 与 DMG 上有不同硬件时序：CGB 野外为 2x CPU，并有 CGB native palette 的 VBlank 提交；DMG 为 1x CPU，`rBGP/rOBP` 写入会直接影响当前扫描画面。项目历史也一直按这种方式收口：`QOL-1.14` 先做 CGB 双速 START 快路径，`QOL-1.15A` 再补 DMG / CGB 1x 路径。因此本轮不把每个菜单都写成“两套完整实现”，而是：

1. **共用恢复逻辑**只实现一次；
2. CGB 已通过的视频行为不再重复修改；
3. 只在最后的 Window / palette reveal 等硬件提交点增加 DMG 专属处理；
4. 每个菜单仍单独验收，避免一个公共大改同时影响六条路径。

## 2. 六个菜单：进入 / 返回问题归类

| 菜单 | 进入 | 返回 | 归类 |
|---|---|---|---|
| 图鉴 | CGB/DMG 都有原生白化；DMG 白化阶段更长 | 原 QOL-1.15 两边都会露地图；DMG 还会出现错误字形/分屏帧 | **共用返回结构问题 + DMG 专属 palette/扫描线问题** |
| 宝可梦 / Party | 两边都有白化，DMG 更长 | 两边都会白化后露地图；DMG 额外出现错误 START 字形/残片 | **共用返回结构问题 + DMG 专属错误帧** |
| 道具 | 两边都有约 2 帧 START 与道具界面的渐进覆盖 | 两边都会露地图，DMG 持续更久 | **共用问题；DMG 只是时长放大，暂未确认独有 bug** |
| RED / Trainer | 两边都有白化；DMG 进入明显更慢 | 两边都会白化后露地图；DMG 裸地图时间更长 | **共用问题；DMG 主要是 1x 时长放大** |
| 记录 / Save | 两边都在 START 上覆盖保存框 | 两边都按原逻辑关闭 START 回地图，不自动返回 START | **共用设计语义，不归入本轮“返回闪烁”** |
| 设置 / Options | 两边都有 DFS 动态字形覆盖导致的 START/Options 混合帧，DMG 稍更明显 | 两边都会露地图，DMG 更长 | **共用 DFS / Window 问题；DMG 时长放大** |

### 当前确认的 CGB 专属问题

**暂无确认的“只在 CGB 出现”的视觉 bug。** CGB 有自己的 2x Window 快传和 native palette 提交路径，但目前录像中的异常要么两边共用，要么 DMG 更严重/独有。

### 当前确认的 DMG 差异与验收优先级

1. 中文 DFS / Window 恢复未完成就露出画面时，DMG 更容易看见错误字形或残片；这类中间态仍是需要修复的真实 UI 问题。
2. `GBPalWhiteOut` / `LoadGBPal` 直接写 DMG `rBGP/rOBP`，精确的 160×144 帧捕获可能记录到单帧扫描线分割。但用户在 GBP 与 My OldBoy 正常播放时没有观察到明显异常，英文参考版也有类似现象；**本轮将其视为非阻断的扫描线/录屏表现，不增加专门等待，也不修改全局 palette 函数**。
3. DMG 1x + 3-VBlank START Window copy 会放大共用重建阶段的耗时；如果出现多帧裸地图、错误中文字形或不完整 Window，仍然需要修复。

## 3. 后续开发顺序

本轮沿用历史“先 CGB，后 DMG”的节奏，但不复制两套完整代码。

### 阶段 A：逐菜单把 CGB 行为做稳

RPP 是 CGB-only，最适合作为这一步的行为参考：

1. 图鉴返回；
2. Party 返回；
3. Trainer 返回；
4. Item 返回；
5. Options 返回；
6. Options 进入。

每一项 CGB 录像达到目标后，该 CGB 路径冻结，后续 DMG 修复不得改坏。

### 阶段 B：只修确实可感知的 DMG 专属问题

- 不为逐帧捕获才明显、在 GBP / My OldBoy 正常播放不可感知的单帧 palette split 增加同步等待。
- 保留 DMG 3-VBlank 安全 Window copy，不为了追平 CGB 帧数冒险。
- 如果 DMG 仍出现多帧裸地图、错误中文字形、半个 Window 或实际游玩可见的闪烁，再按具体菜单单独处理。

## 4. QOL-1.16A / V1：图鉴返回

### 4.1 V1 设计

图鉴退出利用原有白屏，把中文版 START 的完整重建藏在不可见阶段：

1. `ShowPokedexMenu` 退出；
2. `LoadScreenTilesFromBuffer2DisableBGTransfer`；
3. 在白屏下重新 `DrawStartMenu`，生成正确 DFS 中文字形；
4. `PrintSafariZoneSteps` + `UpdateSprites`；
5. `hWY=0`；
6. `CopyStartMenuWindowFast`：CGB 双速 2 VBlank，DMG/1x 3 VBlank；
7. 恢复 AutoBG；
8. 最后 `LoadGBPal`；
9. 直接进入 `StartMenuInputLoop`，不再经过 legacy `RedisplayStartMenu`。

公共 `RedisplayStartMenu`、Party / Item / Trainer / Save / Options 均未修改。

### 4.2 版本号规则

正式 `QOL-1.15` 之后的新测试候选按项目历史规则标记为：

- 游戏内版本：`QOL-1.16A`；
- 9 字符，因此 Options 右上角起点由 `(11,0)` 左移到 `(10,0)`；
- 只有用户验收通过并准备正式收口时，才去掉测试后缀并改为 `QOL-1.16`。

## 5. QOL-1.16A 用户录像测试结果与验收口径修正

### 已观察到的行为

- 用户澄清 `1.16A图鉴退出到菜单.mp4` **只有 DMG**，因此不能用该录像宣称 QOL-1.16A 的 CGB 已通过。
- 直接 160×144 帧捕获中，图鉴开始白化及白屏结束时可以看到单帧水平 palette split / START 中间态；但原 QOL-1.15 的多帧裸地图已经消失。
- 后续 My OldBoy 手机内录中，白屏结束直接出现完整 START；用户反馈在 GBP / My OldBoy 正常播放时没有观察到明显异常。
- 英文参考版 `1.18F` 的直接帧捕获也出现类似单帧扫描线分割，说明这不是中文 DFS 独有问题。

### 当前验收决定

**单帧 palette scanline split 降为非阻断观察项**：不增加 VBlank 等待、不修改全局 `GBPalWhiteOut` / `LoadGBPal`，也不为此单独做 DMG 版本。正常游玩可感知的多帧裸地图、错误中文字形、缺边框或不完整 Window 仍然属于必须修复的问题。

CGB 对应的 QOL-1.16A 专项录像仍未收到；后续仍需通过 QOL-1.16B 的 Party 往返录像分别验证 CGB / DMG。

## 6. QOL-1.16B：Party 返回 START

本轮不再修图鉴的单帧 palette split，转到第二项：**宝可梦 / Party → 返回 START**。

### 6.1 修改边界

- Party 入口 `DisplayPartyMenu` 与 Party 内的选择/操作逻辑保持不变。
- 继续使用原有 `GBPalWhiteOutWithDelay3`、`ReloadTilesetTilePatterns`、`RestoreScreenTilesAndReloadTilePatterns`，以恢复被 Party 覆盖的 tileset、地图精灵、玩家图形、文本框与 DFS 字形。
- 关键变化是：恢复阶段结束后不再先 `LoadGBPal` 再进入 `RedisplayStartMenu`。改为在白色覆盖下统一调用 `RestoreStartMenuFromWhite`，重画完整中文 START、传输完整 Window，最后才恢复 palette，并直接进入 `StartMenuInputLoop`。
- 公共 `RedisplayStartMenu` 不修改；Item、Trainer、Save、Options 仍保持原样。
- 不增加 DMG 专用 palette 等待；逐帧捕获中的单帧 scanline split 已降为非阻断项。

### 6.2 验收标准

- CGB / DMG 均测试完整往返：打开 START → 进入 Party → 按 B 返回 START。
- 返回时不出现多帧裸地图、错误中文、缺边框/半个 Window；恢复后光标与方向键操作正常。
- Party 为空时的原有分支不变；有 1 只与多只宝可梦都应可正常进入和退出。
- CGB 与 DMG 分别录屏；正常速度观感优先，逐帧截图用于定位，不把单帧 palette raster effect 自动判成失败。

## 7. 版本号规则

- 本候选游戏内版本：`QOL-1.16B`（9 字符），Options 右上角起点保持 `(10,0)`。
- 补丁累计包含 QOL-1.16A 的图鉴白屏返回结构，并新增 Party 返回；以正式 `QOL-1.15` 为基线的累计候选补丁只可整体应用，不能与旧的 A 补丁叠加。
- 只有用户验收通过并准备正式收口时，才将测试标识改为 `QOL-1.16`。

## 8. 交付规则

本项目测试候选交付只提供 **一个补丁压缩包**。不再同时交付整项目 ZIP 和裸 `.patch` 两份文件。补丁以正式 `QOL-1.15` 项目包为基线，包含本候选的源码、版本号、计划文档和验收记录变化；静态可套用性检查不等于 ROM 编译或运行验收。


## 9. QOL-1.16B 运行验收结论

用户分别提供 `1.16Bparty到start菜单CGB.mp4` 与 `1.16Bparty到start菜单DMG.mp4`。按正常速度与逐帧抽查：

- CGB：Party → 白屏 → 完整 START，未见多帧裸地图、错误中文或残缺 Window。
- DMG：同样未见上述结构性异常；只保留此前已降级为非阻断项的单帧 palette scanline 特征。
- 因此 Party 返回按当前验收口径记为 **PASS**，后续不再为了 DMG 单帧 raster effect 改动该路径。

## 10. QOL-1.16C：同版处理两个菜单

为减少迭代次数，从本版开始每个测试候选尽量同时处理两个相邻 START 子菜单；仍保持每条返回路径独立，避免一个公共大改影响全部菜单。

### 10.1 道具 / Bag 返回

Bag 没有天然白屏，不能照搬 Party/Trainer 的白屏恢复。当前实现利用进入 Bag 前已经保存的完整 START：

1. `LoadScreenTilesFromBuffer2` 恢复父 START；
2. 不再进入 `RedisplayStartMenu`，避免随后把 Window 移出屏幕并露出地图；
3. 不重新 `DrawStartMenu`，避免 Bag 仍可见时再次 churn 中文 DFS；
4. 只由 `RestoreStartMenuInputStateFromSaved` 重建 `HandleMenuInput` 所需的菜单变量、光标地址和实心光标；
5. 直接进入 `StartMenuInputLoop`。

此方案保持 Bag 原来的**无白屏返回**语义。若实测出现 1～3 帧渐进替换，则后续只对 Bag 做专用提交策略，不把白屏强加给它。

### 10.2 RED / Trainer 返回

Trainer 本来就有 `GBPalWhiteOut`，因此复用已经在图鉴/Party 验证过的白屏恢复框架：

1. 保留 Trainer 原有字体、保存画面、默认调色板和 `ReloadMapData` 恢复；
2. 保留原 DMG 防垃圾画面的 `Delay3` 条件；
3. 不再 `LoadGBPal → RedisplayStartMenu`；
4. 改为 `RestoreStartMenuFromTrainerWhite`，在白屏下完整重建/传输 START，最后恢复 palette；
5. 直接进入 `StartMenuInputLoop`。

### 10.3 版本与验收

- 游戏内版本：`QOL-1.16C`，9 字符，Options 起点继续 `(10,0)`。
- 1.16C 是 **1.16B → 1.16C 增量候选**；交付只提供一个补丁压缩包。
- CGB / DMG 各测试：START → 道具 → B 返回；START → RED → B 返回。
- 阻断项：多帧裸地图、错误中文、残缺 Window、返回后光标/方向键失效。
- DMG 单帧 palette scanline split 继续按既定口径非阻断。

## QOL-1.16D — Options 进入/返回 DFS 安全切换

- 1.16C 用户 CGB/DMG 视频初步确认 Bag 与 Trainer 返回无明显裸地图、错字或半窗口，转入 Options 收尾。
- Options 与 START 共用中文 DFS 动态字形槽；旧 START 仍可见时生成 Options 字形会把旧 tile ID 对应图案提前改写，形成混合字/乱码。这是 Options 入口独有的共用问题，不归因于 CGB/DMG 单一模式。
- 本候选先以短白屏覆盖 DFS 重建：START→Options 在白屏下完成 Options tilemap/字形及原有三帧 BG 传输后再恢复 palette；Options→START 同样先白化，再恢复父菜单并走已验证的白屏安全 START helper。
- 不修改公共 `RedisplayStartMenu`、全局 `GBPalWhiteOut/LoadGBPal`、Save 行为或已通过的 Pokédex/Party/Bag/Trainer 返回路径。
- 游戏内版本：`QOL-1.16D`，9 字符，Options 右上角继续从 `(10,0)` 绘制。

## QOL-1.16E — Bag 道具交互后的 DFS dirty 分支

- QOL-1.16D 的 Options CGB/DMG 往返由用户确认正常，先记通过。
- 新问题仅在 Bag 内**实际选择过道具**后出现：USE/TOSS 及“现在不能使用”等中文提示会重用 DFS 动态字形；1.16C 的 tilemap-only 快速恢复因此可能把正确的 START tile ID 指向已经被提示文字替换的 glyph。
- 继续保留“只打开 Bag、没有选择道具”的无白屏快速返回。
- 一旦进入 `.choseItem`，本次 Bag 会话记为 DFS dirty；退出时 dirty 分支用短白屏覆盖完整 START 重画/Window 传输，最后恢复 palette。直接关闭 START 的道具成功路径会先清除 dirty 标志。
- 本候选版本：`QOL-1.16E`。验收时 CGB/DMG 都分别测试 clean Bag exit 与 unusable-item prompt 后的 dirty Bag exit。


## QOL-1.16F — Bag dirty 返回改为无白屏后台重建

- QOL-1.16E 已修复“道具提示污染 DFS 后 START 文字变形/乱码”，但用户实测指出 dirty 分支会额外出现约 12 帧白闪；该观感不符合 Bag 的界面结构。
- 与 Pokédex / Party / Trainer / Options 不同，Bag 不是切到一个独立全屏页面，而是在原有地图/START 视觉上下文中继续叠加列表、USE/TOSS 与底部提示框。因此 Bag 返回应保持视觉连续，不应借用全屏子菜单的白化遮罩。
- 1.16F 保留 1.16E 的 dirty latch：未选择道具仍走 1.16C 的 tilemap-only 快返；选择过道具/提示可能污染 DFS 时，退出前关闭 AutoBG，把父 START tilemap 恢复到 RAM，并在当前 Bag 仍显示时重新 `DrawStartMenu` 生成正确 DFS 字形。
- 完整 START、光标、Safari 信息和 DFS 字形准备完成后，再用既有 `CopyStartMenuWindowFast` 提交窗口；全程不调用 `GBPalWhiteOutWithDelay3` / `LoadGBPal`，预期视觉为 Bag 直接切回完整 START。
- 本版只改 Bag dirty 返回，不改 clean Bag 快返、其他子菜单、公共 palette 函数或 `RedisplayStartMenu`。
- 游戏内版本：`QOL-1.16F`。验收重点：CGB/DMG 各测试“不能使用道具→提示→回 Bag→B”，不得出现白闪、START 乱码、裸地图或残缺窗口。


## QOL-1.16 正式收口

- 最终候选：`QOL-1.16F`。用户提供最新项目工作区与全菜单回归录像，并确认本轮改过的路径在 CGB / DMG 两种模式下均未再发现明显问题。
- Pokédex / Party / Trainer 使用已有白屏阶段完成父 START 的 DFS、Window 与输入状态恢复；Options 用短白屏避免 START/Options 共用 DFS 时暴露中间字形。
- Bag 保持覆盖式菜单语义：clean exit 直接恢复保存的 START；发生 USE/TOSS / 结果提示后通过 dirty latch 在 Bag 仍可见时后台重建父 START 与 DFS，再一次提交 Window，不使用额外白屏。
- DMG 精确逐帧捕获中的单帧 palette scanline split 与英文参考版/原 DMG 路径一致，且用户在 GBP / My OldBoy 正常播放未观察到明显异常，正式版按非阻断项接受。
- Save/记录没有改成返回 START，继续保持原有关闭菜单语义。
- 正式清理仅将游戏内 `QOL-1.16F` 改为 `QOL-1.16`、Options 版本号绘制起点从 `(10,0)` 恢复到 `(11,0)`，并整理维护文档/静态守卫；A～F 已通过的二级菜单执行逻辑不再修改。
- 用户最新工作区中缺少中间测试脚本 `scripts/verify_start_return_v5_static.py`；该脚本不被 Makefile/ROM 运行引用，对功能无影响。正式收口删除已过期的 v3/v4 候选守卫，改为单一 `scripts/verify_qol116_static.py` 检查最终结构。
- 最新包的 `build-check.log` 记录用户 Termux 环境成功复用 `buildRB/pokered.gbc` 并复制红版 ROM；这属于用户侧构建记录，不代表 AI 在当前环境独立编译。蓝版及新 MAP 仍待用户按需补验。
