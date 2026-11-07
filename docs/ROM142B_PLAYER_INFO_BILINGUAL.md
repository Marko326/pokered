# ROM-1.42 玩家资料界面双语标签（ROM-1.42B 开发记录）

> ROM-1.42B 是本功能开发候选；2026-11-07 已正式清理为 ROM-1.42。导出记录声明 Git HEAD `608a85501b97174401367f544427aaac60639e54`，ZIP 含未提交 Worktree patch，不能把快照冒充干净 HEAD。正式版号清理只改版号字符串与 Options 对齐，不改本模块运行行为。

## 1. 本轮范围

仅处理三个已有玩家资料界面的固定标签：

| 界面 | 中文模式（由现有 data.xlsx 导入） | English 模式 |
|---|---|---|
| 继续游戏／保存信息 | 主人公、持有徽章、图鉴、游戏时间 | PLAYER、BADGES、POKéDEX、TIME |
| Trainer Card | 主人公、零花钱、游戏时间、徽章 | NAME、MONEY、TIME、BADGES |
| 名人堂最终玩家统计 | 游戏时间、零花钱 | PLAY TIME、MONEY |

不处理主菜单的 CONTINUE／NEW GAME／OPTION，不处理共用 YES／NO，不处理宝可梦／技能／道具名称、战斗文字或图鉴条目。

## 2. 实现方式

- 三处均沿用已保存的 `wOptions` bit 5：0 选 CHS，1 选 English。
- 继续游戏与保存信息共用 `GetSaveScreenInfoText`，避免两个入口语言行为不同。
- Trainer Card 在原 `DrawTrainerInfo` 中分别选择名称／金钱／时间行和徽章行。
- 名人堂在原玩家统计绘制位置分别选择 PLAY TIME 与 MONEY 标签。
- 中文标签仍由现有 `src/xlsx/data.xlsx` 和 `src/tools/_importTextData.py` 生成；不修改 XLSX，也不复制或重写中文译文。
- 英文备选字符串有意拆分为相邻的 `db` 字符串片段（例如 `"PLAY","ER"`），避免现有 XLSX 导入器按完整英文源字面量进行替换时误改英文副本。
- Continue/Save 的英文图鉴标签写作 `POKéDEX`，不用 CHS 特殊扩展字符 `#`，避免调用 `PlacePOKe` 中文扩展。
- 玩家名字、徽章数量、Seen/Owned 数量、游戏时间、金钱数值的读取和绘制代码不变；只切换静态标签。
- 不新增 WRAM、SRAM、存档字段、文本 opcode 或 ROM0 代码；保留 ROM-1.42A 已通过实机测试的图鉴评价与名人堂动态统计双语 wrapper。

## 3. 修改文件

- `src/engine/menus/main_menu.asm`
- `src/engine/menus/start_sub_menus.asm`
- `src/engine/movie/hall_of_fame.asm`
- `src/data/game_version.asm`（ROM-1.42A → ROM-1.42B 开发候选 → ROM-1.42 正式版）
- `src/engine/menus/options_bilingual.asm`（仅更新 9 字符版本号对齐注释）
- `scripts/verify_rom141_bilingual_dialogue_static.py`（更新当前候选版号断言）
- `scripts/verify_rom142_pokedex_rating_static.py`（更新当前候选版号断言）
- `scripts/verify_rom142b_player_info_static.py`
- `tests/test_player_info_bilingual.py`
- `TODO.md`、`MAINTAINER_BUILD.md` 与本说明文档

## 4. 验证记录

- `python3 scripts/prepare_build.py`：退出码 0；完成 2,587 个文件的导入／同步；原有地图对白生成器仍输出 1,942 条引用／1,941 个英文标签，图鉴生成器仍输出 19 个英文标签。
- 构建树检查：三个目标 ASM 文件均保留原有 CHS workbook replacement，新增英文备选标签未被导入器改写。
- `python3 -m unittest discover -s tests -v`：22/22 PASS（原有 17 项 + 本轮 5 项）。
- `python3 scripts/verify_rom141_bilingual_dialogue_static.py`：PASS。
- `python3 scripts/verify_rom142_pokedex_rating_static.py`：PASS。
- `python3 scripts/verify_rom142b_player_info_static.py`：PASS。
- 上述是源码、XLSX 导入及静态检查，不是 RGBDS 编译或手机实测。
- 正式清理后，三个相关静态守卫已更新为校验正式版号 `ROM-1.42`；Pokedex 守卫同时校验 8 字符版号在 x=11 对齐。正式清理复测：22/22 单元测试 PASS，`prepare_build.py` 成功同步 2,587 个文件，地图对白／图鉴／玩家资料专项静态守卫 3/3 PASS。项目全部 17 个 `verify_*.py` 为 5 PASS／12 FAIL；12 项均为历史版号／Options 对齐守卫限制（其中 QOL-1.17 的 11 项功能断言通过），未修改旧守卫。负向移除 English selector 后，本专项守卫按预期失败。

## 5. ROM 空间规划

按随包 ROM-1.42A MAP 的当前 section 末端估算：

| ROMX Bank | 原 MAP 剩余 | 本轮新增估算 | 预计剩余 |
|---|---:|---:|---:|
| `$01`（main menu） | 533 bytes | 约 48 bytes | 约 485 bytes |
| `$04`（Trainer Card） | 478 bytes | 约 48 bytes | 约 430 bytes |
| `$1C`（Hall of Fame） | 265 bytes | 约 36 bytes | 约 229 bytes |

ROM0 不新增运行代码；WRAM／SRAM 不变。正式清理把 9 字符候选版号缩为 8 字符 `ROM-1.42`，Options 版本起点恢复 x=11；不改变游戏功能。以上只是源码长度估算，不能代替维护者重新构建后的红／蓝 MAP。

## 6. 用户实机验收

English 模式分别检查：

1. 主菜单选 Continue 后的信息框：PLAYER、BADGES、POKéDEX、TIME；玩家名、徽章数、图鉴数和时间仍正确。
2. 保存画面：同样四个英文标签；保存动作和存档内容不变。
3. START → Trainer Card：NAME、MONEY、TIME、BADGES；名字、金钱、时间和徽章图标／数量正确。
4. 进入名人堂最终玩家统计：PLAY TIME、MONEY 为英文；POKéDEX Seen／Owned 和博士评价继续保持英文，数字正确。

中文模式重复上述界面，确认继续显示现有中文。切换语言后重新进入界面，并测试保存／重启后设置仍生效。

## 7. 用户反馈更新与范围边界

用户反馈：按此前测试清单检查的其他项目没有发现明显问题，包括玩家资料固定标签及相关界面。Continue／Save 页面中的当前地点名称仍显示中文。该地点名称来自地图名称数据/独立 renderer，不属于本模块已完成的固定标签；因此本模块不把整个 Continue／Save 页面标记为完整双语。

随后尝试的 `ROM-1.42C-current-location-fix.patch` 已按用户要求撤销。C 候选实测固定显示 `ROUTE 17`；源码核对确认跨 Bank `farcall` 后 A 被 `Bankswitch` 改写，Bank `$1C` 与 `ROUTE_17` map ID `$1C` 撞值。该试验补丁不应用、不叠加；地点名称问题改由 `docs/BILINGUAL_PROJECT_PLAN.md` 阶段1统一盘点处理。

## 8. 未完成与限制

- 用户已按上一轮建议抽测相关界面，并反馈除当前地点外，其他已查看项目没有发现明显问题；该反馈是局部实测，不是完整红／蓝、DMG／CGB 矩阵。
- ROM-1.42B ZIP 附带的红／蓝 MAP 标记为 ROM-1.42B，但导出日志说明 MAP 自动生成/校验，构建检查日志存在缓存复用；它们是随包导出证据，不等于本轮重新执行 RGBDS 的全新链接证明。当前没有可对应本轮的最终 ROM SHA；正式构建仍由维护者本地完成。
- 其他主菜单命令、YES／NO、战斗、宝可梦／技能／道具名称、图鉴条目及其他 UI 仍属于后续独立分类。
- AI 不运行 RGBDS／`rgblink`，不伪造 ROM／MAP／SHA，不执行 Git Commit／Push。
