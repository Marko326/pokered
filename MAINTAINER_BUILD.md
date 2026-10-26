# 可长期维护的 `make` 构建方式（CHS_Mod 红/蓝汉化）

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
- `make` 会检查整个 `src/` 的内容指纹；没有变更时跳过 Excel 导入，
  直接交给 `src/Makefile` 的 RGBDS 增量规则；变更时才重新生成 `buildRB/`。
- 预处理失败不会破坏现有 `buildRB/`。每次预处理重建时不保留原目录的
  目标文件（`.o`），以确保不会使用过期编译产物。

## Git 维护流程

补丁应用成功后，建议建立自己的维护分支并提交补丁：

```sh
git switch -c my-chs-maintenance
git add Makefile scripts/prepare_build.py MAINTAINER_BUILD.md .gitignore
git commit -m "Build CHS ROM via root Makefile"
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

**版本号显示是独立的配置问题**：该 CHS_Mod 项目没有
`data/game_version.asm`。如果 RPP 提示缺少此文件，应在 RPP
版本号设置中关闭版本识别或配置项目实际拥有的版本文件；
不要为消除提示而伪造游戏版本或擅自改动游戏汇编代码。
