# 可长期维护的 `make` 构建方式（CHS_Mod 红/蓝汉化）

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
`GameVersionText`（当前正式标识 `ROM-1.21`）。主菜单左下角和设置界面右上角
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
