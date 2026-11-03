## ROM-1.30 CGB 地名牌基础地标与 Warp 转场正式收口（2026-11-03）

- **基线**：本轮正式基线为用户 RPP 导出声明的 `CHS_Mod` HEAD `a8ac7a01a423b8a4e25de81e82a583ba60c23112`（ROM-1.29）。上传的 `ROM-1.29.patch` 是该 HEAD 上已实测 Worktree；全量补丁从 HEAD 重建，清理增量从该 Worktree 出发。
- **功能范围**：CGB 地名牌新增常青森林、月见山、岩山隧道、地鼠洞穴、无人发电厂五个基础物理地标；原 11 城镇＋Route 1～25、120 帧显示和 #215 连续刷新保持。楼层／中转身份仍留待 #217～#225 后续阶段。
- **Warp 行为**：完整 Warp 离开源地图前先回收地名牌，目标 `EnterMap` 按 Fly 的短延迟再显示；普通城市／道路的地图连接仍即时刷新。SAVE/Continue 仍使用原字号与 DFS，只把安全截断上限 6→8 格以完整容纳「无人发电厂」。
- **Rock Tunnel 暗场**：未使用 FLASH 时 `wMapPalOffset=$06`，退出室外前从当前 `FadePal2` 继续淡到黑，避免普通 `GBFadeOutToBlack` 先回亮造成闪白；FLASH 后 offset=0，保留原门口 fade。用户最终录像复测并反馈当前效果无问题。
- **版本与交付**：正式版本 `ROM-1.29 → ROM-1.30`，Options 保持 `(11,0)`。无工具／审计脚本修改，采用模式 B 三件套；增量和全量补丁互斥。Surf 按 B 加速只登记 TODO。本环境不运行 RGBDS、不生成 ROM/MAP/SHA，也不执行 Git Commit / Push。

# 可长期维护的 `make` 构建方式（CHS_Mod 红/蓝汉化）

## ROM-1.29 CGB 地名牌第一阶段正式收口（2026-11-02）

- **正式基线**：ROM-1.28FIX，用户最新 RPP 导出记录为 `CHS_Mod` HEAD `2ca225eaba041844c0e35eff9ce90fd7150a0a65`；本轮以该 HEAD 上的 `ROM-1.28FIX.patch` 已验收工作区为功能状态。
- **功能范围**：CGB-only 地名牌第一阶段支持 11 个城镇与 Route 1～25；地图连接、普通进图、Fly 落地后触发，显示 120 帧；DMG 路径不调用该模块。
- **启动定位**：New Game / Continue 第一次进入游戏时复用 Fly 的短延迟显示当前位置；普通城市建筑可借既有 Town Map 名称解析到当前已支持的城镇/道路，未纳入的洞窟/独立地标仍不显示。
- **连续刷新**：按 RPP #215 的 Window 所有权思路适配 CHS 8×16 中文字形。旧牌仍显示时先把新名字写入备用 VRAM Bank 1 字形区，再屏蔽中断等待一个全新的 VBlank，原子切换两行共 36 个 tile ID，避免外框闪烁和上下半字混合。
- **Window 交接**：START/对白入口与 BattleTransition 在接管 `$9c00` 前主动回收地名牌。该战斗入口修正解决了地名牌显示期间触发首场野战时，CHS 战斗调色板清黑 Palette 5 后出现 4-tile 高黑条的问题。
- **状态边界**：仅复用 `$cd61-$cd69` 既有 9-byte WRAM padding 中的 8 byte 运行期状态，不推动后续 WRAM 地址，不新增 SRAM/存档字段；Palette 5、VRAM Bank 1 与专用 Bank `$3D` 仅服务 CGB 地名牌。
- **验收**：用户实际复现并确认野战黑条最小修正有效；连续刷新首版曾出现中文上下半字混合，按 #215 的 fresh-VBlank 中断所有权修正后用户确认“没问题了”。该反馈不扩大为红/蓝、DMG/CGB 全矩阵验收。
- **版本与交付**：正式版本由 `ROM-1.28FIX` 正常递增为 `ROM-1.29`，恢复 8 字符版本显示与 Options `(11,0)` 右对齐。模式 B 三件套：已验收工作区清理增量、`2ca225e...` HEAD 累计全量、中文 `feat(map)` Conventional Commit 日志；两份补丁互斥。助手不执行 Git Commit / Push，也不运行 RGBDS 构建。

## ROM-1.28FIX SAVE / Continue 地点字形冲突修正（2026-11-02）

- **正式基线**：ROM-1.28，HEAD `f483b39a4d95aaa16dc3b2f906a02ec4dfc0e82a`。用户已验证其上的 `town_map.asm` 单文件修正无问题。
- **修正内容**：SAVE / Continue 地点行只显示地图名，不再绘制「当前位置」标签；保留完整中文字形边界截断和最多六格宽度。移除 `vChars2 $40-$5F` 的 `DFSStaticize`，避免固定 DFS 字形与户外地图图块编号冲突。
- **版本显示**：按维护者要求使用 `ROM-1.28FIX`，不递增 ROM-1.29；11 字符版本在 Options 从 `(8,0)` 开始，右边缘与既有正式版一致。
- **不变项**：地图快捷定位、Town Map 数据、玩家名右对齐、存档格式及 SAVE/Continue 流程均不改变；不修改工具、转换器或审计脚本。
- **交付**：模式 B 三件套——已验收工作区清理增量、`f483b39a...` 基线累计全量、中文 `fix(map)` Conventional Commit 日志。两份补丁互斥。助手不执行 Git Commit / Push，也不运行 RGBDS 构建。

## ROM-1.28 地图 QoL 正式收口与红版维护说明（2026-11-02）

- 正式版本从 `ROM-1.27` 递增到 `ROM-1.28`；游戏内 `GameVersionText` 为 8 个字符、Options 坐标 `(11,0)`。ROM-1.27A/B/C 为本次候选历史，不作为独立 Git 正式版本。
- 以用户本轮上传的 `ROM-1.27C.patch` 为严格工作区基线（RPP-BASE：`1b1fc3905302bdff9989f7fb29df9a551ee7909f`）；不自动纳入之后试验性的 D 版数字＋中文单位合并排版。
- #377/#378：普通/飞行地图 START 定位上次治疗地点、SELECT 定位真新镇；#089：普通地图初始化时定位当前地图；#025：SAVE 和 Continue 页面显示当前位置、中文标签及玩家名右对齐。
- SAVE/Continue 现有 13 格框宽不变。地图名称取已有表，使用 CHS 双字节字符宽度处理及显式字码；玩家名只用缓冲副本测宽，跨 Bank 字符串例程使用 `callfar`；SAVE 不清空 START 仍使用的 DFS 缓存。
- 用户已反馈 A/B 相关实测符合预期，并确认后续中文存档文字、姓名异常修复；尚有徽章/图鉴中文单位的细微视觉对齐偏差及部分模式/边界测试未逐项证明。收口不宣称 D 版排版实验已通过。
- 本轮没有改动工具/审计脚本，按模式 B 准备单笔功能提交。助手仅做静态补丁验证，不运行 RGBDS，不生成新 ROM、MAP 或 SHA；项目以红版构建/验收为主。

## ROM-1.27 正式清理与数量、光标、电梯体验收口（2026-11-02）

- **正式版本**：ROM-1.26 → ROM-1.27。`ROM-1.26E` 是同一轮开发候选，不作为额外正式版本；本轮未使用游戏内测试功能，正式版使用 8 字符 `ROM-1.27`，Options 起点 `(11,0)`。
- **功能范围**：数量选择框采用 Ruby 的 40/5 帧重复节奏及上下 ±1、左右 ±10；START 主菜单/Party 会话光标分离；野外背包保存绝对位置与滚动偏移并跨战斗保留；图鉴保存绝对编号；三处建筑电梯预选当前楼层并缩短摇晃；修复 START→ITEM 快速返回后 EXIT 最大索引多算一项。
- **用户验收**：用户表示此前 A～E 相关功能基本均已实测、未见问题；本轮 EXIT 空白行边界修复也已确认正常。该反馈不代表所有红/蓝、DMG/CGB/SGB 组合均逐项覆盖。
- **WRAM/存档边界**：会话记忆仅使用运行期 WRAM，不新增 SRAM 或存档字段；数量选择重复计时局部保存/恢复，不改变全局菜单速度表。建筑电梯以独立 `ShakeBuildingElevator` 使用 40 次循环，原 `ShakeElevator` 100 次路径保留。
- **基线与重建**：`CHS_Mod` HEAD 以本次项目导出记录声明的 `b003917d4ae9e898e96eaa69fae161ea3fdd180f` 为准；上传 ZIP 为含未提交 Worktree 的 `ROM-1.26E`。使用导出 `current_worktree.patch` 反向重建基线、再正向重放并完成逐文件 SHA-256 一致性核对。ZIP 不含 `.git`，因此 Hash 依据导出记录而非本地 Git 对象独立验证。
- **提交方式**：本轮未修改 `scripts/`、`tools/`、转换器或审计脚本，采用模式 B 单笔 `feat(menus)` 提交准备；不制造空工具提交。Git Commit / Push 由维护者自行执行。
- **交付**：一个 ZIP，严格包含清理增量补丁、HEAD 全量补丁和一份中文 Conventional Commit 日志；增量与全量互斥，不能叠加。
- **构建边界**：AI 未运行 RGBDS 编译/链接，不生成 ROM-1.27 MAP 或 ROM SHA。随包红版 MAP 属于 ROM-1.26E 候选，不冒充 ROM-1.27 新 MAP；用户本轮以红版为主，不要求蓝版 MAP 作为验收阻断。

## ROM-1.26 正式清理与道具列表、名人堂功能收口（2026-11-01）

- **正式版本**：ROM-1.25 → ROM-1.26。#102 道具列表操作后光标恢复、#119 连续放生/道具合并位置、#332 名人堂局部轮播已在正式源码收口。
- **验收边界**：用户明确反馈 T1～T5、T7、T8 PASS，并确认放生清空当前盒子后返回上级符合预期；原 T6 未逐场景记录，不扩大为所有放生边界均已验收。红版/蓝版全平台矩阵不作穷尽声明。
- **后续扩展**：START/Party、野外背包、图鉴会话光标和电梯功能在 ROM-1.27 中后续收口；不应把这些功能误记为 ROM-1.26 的原始提交内容。

## ROM-1.25 正式清理与 PC 功能收口（2026-11-01）

- **正式版本**：ROM-1.24 → ROM-1.25。早期曾使用 `ROM-1.25`、`ROM-1.26A/B/C` 作为同一轮未提交的开发候选标识；本轮没有使用游戏内测试功能，因此正式版使用 8 字符 `ROM-1.25`，Options 起点 `(11,0)`。
- **功能范围**：Bill's PC #073～076 连续存取 CHS 适配；卧室 PC #128 图鉴后完整菜单入口；图鉴获得后中文升级通知与正确分页；Bill's PC 模块放置在 Bank `$2D`。
- **提交方式**：本轮没有修改 `scripts/`、`src/tools/`、转换器或审计脚本，按模式 B 使用单笔 `feat(pc)` 提交；不制造空的工具提交。旧静态守卫的版本白名单保持原样，其已知限制记录在验收历史中。
- **补丁前置状态**：清理增量以用户已应用并确认正常的 `ROM-1.26C` 对白分页修正版为起点（不是分页错误的旧 ROM-1.26C）；HEAD 全量以重建的正式 HEAD 为起点。
- **交付**：一个 ZIP，严格包含清理增量补丁、HEAD 全量补丁和一份中文 Conventional Commit 日志，共三件；增量与全量二选一，不能叠加。
- **基线**：`CHS_Mod` HEAD `23b2d335183ab27a153ab6d7747260ed8a3ccd37`，根据 ROM-1.26B 导出信息与 `current_worktree.patch` 反向重建；ZIP 不含 `.git`，Hash 来自导出记录，未在本环境独立读取 Git 对象。
- **构建边界**：AI 未运行 RGBDS 编译/链接，不生成 ROM-1.25 MAP 或 ROM SHA；红蓝构建和最终 Bank 余量由维护者本地完成。用户已确认的具体场景以 `docs/CHS_ACCEPTANCE_HISTORY.md` 为准，不扩大为全平台验收。


## ROM-1.24 历史正式清理记录（2026-11-01）

- **正式交付三件套**：清理增量补丁从用户已应用 PC LogOff 与 Player's PC 闪动修复的 `ROM-1.23D` 工作区到正式 `ROM-1.24`；基线全量补丁从 `CHS_Mod` HEAD `122678e9f6c4b0289103065875241cc1b67382fe` 到 `ROM-1.24`；另附中文 Conventional Commit 日志。两份补丁二选一，不得叠加。
- **本轮收口功能**：START 菜单有效索引与 A/B 输入判别；PC 子菜单返回与按 B 退出地图的背景恢复；Player's PC 主菜单及下方提示框同步显示；Bill's PC 列表窗口遮挡原菜单文字。Bill's PC 首次进入中文字异常按用户要求暂缓，不纳入本轮。
- **版本**：本轮没有新增测试功能，正式标识为 `ROM-1.24`；Options 右上角从 9 字符测试候选位置 `(10,0)` 恢复到 8 字符正式位置 `(11,0)`。
- **提交方式**：没有工具、转换器、审计脚本或测试工具修改，采用单笔 Git 提交。用户自行执行 Git Commit / Push；本交付不代表已提交或推送。
- **验收边界**：用户确认当前候选版本已修好；具体红蓝版与 DMG/CGB 覆盖组合未逐项列明。遵守项目要求，本轮未由 AI 编译/链接 ROM，正式红蓝 MAP 与 ROM SHA-256 仍以维护者本地构建为准。

## ROM-1.21 正式收口与 ROM0 四轮优化（2026-10-31）

- **正式交付三件套**：增量为已有 ROM-1.20D 工作区 → ROM-1.21；全量为干净且已提交 `FLH-1.20` HEAD `dafddf27c96cef72adda49a329a88386a0312b2f` → ROM-1.21（一次包含 A+B+C+D）；另附中文 Conventional Commit `commit-message.txt`。两个补丁必须二选一，不得叠加，不使用历史 QOL-1.17 全量基线。
- **核心执行代码不变**：C/D 用户测试后的能力值/BCD/音乐/TM/HM/地图切换路径不做新的运行逻辑修改。`MapHeaderPointers` 248 项共 496 B 在 ROMX `$2D`；ROM0 在读表时临时切 `$2D` 并恢复地图 Bank 后才读取地图头。
- **验收**：D 红版 MAP 由用户提供、经独立报告核对 ROM0 剩余 1,087 B、最大连续 1,052 B、Bank `$2D` 剩余 13,754 B；用户反馈进出房门、普通对战返回、道路切换、飞行到其他城市正常。正式 `ROM-1.21` 版本号缩短后仍需实际编译取得新红蓝 MAP，蓝版来源尚未完全追溯；本交付未代为构建或 Commit/Push。
- **版本显示**：正式版本为 8 字符 `ROM-1.21`（文字末尾 `@` 为游戏字符串终止符），主菜单与 Options 共用；Options 起点 `(11,0)`。只有测试候选 D 使用过 `(10,0)`。

本补丁适用于 `TomJinW/pokeredCHS` 的 `CHS_Mod` 分支（宝可梦版红/蓝）。
不是 ROM 的 `.ips` 补丁，也不是给 `pret/pokered` 原版源码打的补丁。

## 初次安装

```sh
git clone https://github.com/TomJinW/pokeredCHS.git
cd pokeredCHS
git switch CHS_Mod   # 旧版本 Git 可以改为 git checkout CHS_Mod
# 将提供的 chs-direct-make.patch 放在仓库目录外或当前目录：
git apply --check /path/to/chs-direct-make.patch
git apply /path/to/chs-direct-make.patch
```

需要 `make`、`gcc`、Python 3、`openpyxl`、官方 RGBDS。该补丁依据的
源码快照（README.build.md）要求 RGBDS **1.0.4**。

在 Ubuntu/WSL 下，通常先执行：

```sh
sudo apt update
sudo apt install -y build-essential python3 python3-venv
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install openpyxl
# 另行安装官方 RGBDS 1.0.4，并用 rgbasm --version 检查版本。
make red
```

输出会同时保留在 `buildRB/pokered.gbc`，并复制到项目根目录的 `pokered.gbc`；蓝版使用 `make blue`，全部使用 `make`。
附加目标：`make red_debug`、`make blue_debug`、`make red_vc`、`make blue_vc`。
`make clean` 会删除生成的 `buildRB/`、根目录的 `.gbc` 和 `.patch`；`make rebuild` 会删除并全部重建。

## 维护约定

- `src/` 是唯一需要编辑、提交到 Git 的汇编代码及资源目录。
- 翻译表请编辑 `src/xlsx/*.xlsx`，因为生成时翻译导入会覆盖相应汇编文本。
- 不要在 `buildRB/` 内做长期修改；目录是自动生成的、被 `.gitignore` 忽略。
- `make` 会检查 `src/` 的内容及权限指纹。普通 ASM、图片及其他源码补丁仅同步
  有变化的文件到 `buildRB/`；未变化的文件维持原有时间戳，保留 `.o` 和 ROM。
- 修改 `src/xlsx/`、导入用 Python 脚本或导入器所管理的 ASM 时，会在临时目录
  重新生成汉化文件；**只有内容变化的输出**才复制到 `buildRB/`，不删除
  无关的 `.o`。导入程序报错时不会覆盖现有工作目录。
- `src/Makefile` 会通过依赖规则只重编引用了被改动内容的目标文件，并在必要时
  重新链接 ROM。公共 `includes.asm`、宏定义或 `src/Makefile` 等修改会令许多
  目标文件确实失效，此时大量重编是正确行为。
- 根目录 ROM 和 `.patch` 只有当编译生成的文件内容不同才覆盖，重复执行
  `make red` 不会无条件刷新根目录 ROM 的时间戳。
- **官方 RGBDS 编译请从仓库根目录运行 `make red`、`make blue` 或 `make`。**
  `_prepare.command` 的默认官方 RGBDS 路径也会委托给根目录 `make`；
  `src/_build.command` 保留旧版 `--always-make`：它支持切换不同 RGBDS 和
  字符参数，同名 `.o` 缓存不能直接跨编译模式复用。
  `_prepare-win32.sh` 和 `_prepare.command` 的 `option=2` 仍属于旧版单独导入
  路径，不保证增量构建。不要再手动删除 `buildRB/` 来“清理补丁”。
- 首次构建（没有历史 `.o`）及显式 `make rebuild` 仍会完整编译。旧版状态
  文件首次迁移时会重新导入汉化，但已有 `.o` 将保留。补丁应用到 `src/`
  后执行 `make red` 即可验证；不需要重新运行旧式导入脚本。

## 文档维护约定

- 历史版本变更、用户实测与静态验收统一追加至 `docs/CHS_ACCEPTANCE_HISTORY.md`，**不再为每个新版本新建一份验收文件**。
- 未完成事项只放根目录 `TODO.md`；构建说明保留在此文件。历史记录完整保留，不能把静态检查写成 ROM 实测。
- 版本更新时同步更新统一验收文档及 `TODO.md`，不改 `RPP_PROJECT_CONTEXT/` 下的自动导出索引。

## Git 维护流程

补丁应用成功后，建议建立自己的维护分支并提交补丁：

```sh
git switch -c my-chs-maintenance
git add -A -- TODO.md MAINTAINER_BUILD.md docs/  # 本次文档整理；功能代码变更应另行 add
git commit  # 使用交付的 commit-message.txt 中的中文提交日志
```

上游有更新时：

```sh
git fetch origin
git switch my-chs-maintenance
git rebase origin/CHS_Mod
make red
```

补丁在随提问提供的源码快照上验证过；若远端仓库已有新提交导致
`git apply --check` 失败，不应强行覆盖上游文件，应先检查冲突。

如果上游更新了翻译导入脚本及参数，需要同步检查
`scripts/prepare_build.py` 的 `COMMANDS`，因为这些命令目前按补丁对应
的 `CHS_Mod` 快照固定。切换到 `CHS_MOD_RGB` 分支不能直接沿用本补丁。

## RPP 手机编译工具与 ROM 输出

根目录 `Makefile` 会显式声明 `red: pokered.gbc` 等依赖，方便只解析
Makefile 的工具定位 ROM。`make red` 会先在 `buildRB/` 内编译，随后
把本次构建成功的 ROM 复制到仓库根目录 `pokered.gbc`。不要在
`buildRB/` 或根目录生成的 ROM 文件上进行长期修改。

**游戏内版本号**：在 `src/data/game_version.asm` 中统一编辑
`GameVersionText`（当前正式标识 `ROM-1.27`）。主菜单左下角和设置界面右上角
使用同一版本文字；进入 Options 或 Continue 前仍先清除主菜单底部版本号，
Options 自行绘制右上角版本标识。正式版长度为 8 字符，从 `(11,0)` 绘制；历史测试版 D 曾使用 9 字符、从 `(10,0)` 绘制。后续如增加
字符，须同时检查 Options 的显示起点与边框覆盖。该文件由 `src/main.asm`
引用并链接到 ROM0。修改版本后可由用户执行 `make red` / `make blue`
增量汇编；空间仍以本地链接得到的新 MAP 为准。

## ROM0 空间维护约定

- 新增低频、非中断、可跨 Bank 调用的功能，优先放在 ROMX；ROM0 尽可能只保留必要的入口、时序敏感代码与硬件中断例程。
- 迁移时核对调用方 Bank、返回寄存器、跳转/返回路径与数据所在 Bank，不能仅以补丁套用成功判定安全。
- 不要随意迁移高频中断代码；红蓝版都须以新生成的 MAP 和实际运行结果验收。
- QOL-1.15 空间收尾已将 `START Window Transfer Fast` 显式放到 ROMX Bank `$2D`（见 `layout.link`），同时用 ROM0 共享门控减少重复输入检测代码。用户提供的**红版** QOL-1.15 新 MAP：ROM0 剩余 321 B、Bank `$01` 剩余 165 B、Bank `$2D` 约 15.3 KB；相对 QOL-1.14，ROM0 减少 282 B、Bank `$01` 增加 77 B、Bank `$2D` 减少 154 B，净占用增加 359 B。红版数据来自用户本地构建，不代表助手已编译；**蓝版 MAP 仍待获取**。
- `ROM-1.3A` 候选 MAP 的 ROM0 剩余为红、蓝版各 884 字节；正式版 `ROM-1.3` 仅缩短了主菜单版本字符串，仍须以正式版 MAP 确定最终余量。

- **ROM-1.20A 测试候选**：`Yes No Dialog Helpers` 与 `Sprite Reset Helpers` 在 `src/layout.link` 固定于 ROMX `$2D`；ROM0 只保留无寄存器输入的 `farjp` 入口。最终 ROM0 与 Bank `$2D` 余量需要使用用户新构建的红/蓝 MAP 核实，不得将旧 FLH-1.20 MAP 当作迁移后结果。

- **ROM-1.20B 第二轮（仅测试）**：基于用户已测红版 A 的 ROM0 222 B，`CalcStats/CalcStat` 的 WRAM/HRAM 算术主体进一步迁往 `$2D`。两项 ROM0 保留输入寄存器及返回 AF/Bank 保真的入口；预计再省约 225 B。实际应重新编译红蓝 ROM/MAP 核实。不要把 A 的 MAP 误写为 B 的实测。

- **ROM-1.20B 本轮审查反馈（2026-10-30）**：随用户工作区 ZIP 的红版 MAP 已由独立审查读取：ROM0 447 B，Bank `$2D` 14,507 B；非本环境新编译。测试阶段仅交付以 FLH-1.20 最新 HEAD 为基线的单份 A+B 累计补丁；正式三件套只在验收确认后准备。保留两个既有 `verify_*_static.py` 的可执行权限。

- **ROM-1.20C 第三轮（仅测试）**：将 BCD 金额打印、训练家战前音乐分类（含本地类别表）和 TM/HM 名称合成（含前缀表）放在 ROMX `$2D`，ROM0 使用显式保存并还原 AF/BC/DE/HL 与调用方 ROM Bank 的入口；不使用可能改写返回寄存器的普通 `farjp`。C 红版 ROM0 余量静态估算约 608 B，Bank `$2D` 约 14,250 B；没有新 MAP 不得作为编译结果。旧版迁移静态守卫只放宽版本号到 C，不能削弱功能/Bank 断言。测试候选只交付 FLH-1.20 HEAD 到 C 的 A+B+C 单份累计补丁，不做正式 Commit/Push。
