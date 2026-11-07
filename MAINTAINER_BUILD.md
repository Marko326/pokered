## 当前双语项目总控（ROM-1.42；2026-11-07）

双语化总计划与范围控制以 `docs/BILINGUAL_PROJECT_PLAN.md` 为唯一入口；阶段0盘点见 `docs/BILINGUAL_PROJECT_AUDIT_ROM142B.md`，阶段1地图名称系统只读证据见 `docs/MAP_NAME_SYSTEM_AUDIT_ROM142B.md`。

- **当前正式版本目标**：ROM-1.42；由 ROM-1.42B 开发候选清理，正式版号为 8 字符 `ROM-1.42`，Options 版本起点恢复 x=11。
- **Git 基线**：分支 `CHS_Mod`；导出记录声明 HEAD `608a85501b97174401367f544427aaac60639e54`。ROM-1.42B ZIP 是含未提交 Worktree 修改的源码快照，不是干净 HEAD；本轮全量补丁以可重建的 608a8550 内容树为基线。
- **已接入范围**：地图脚本对白、图鉴统计／博士评价 19 个标签、Continue／Save 固定信息、Trainer Card、Hall of Fame 玩家统计均已有双语实现；LANGUAGE 仍沿用 `wOptions` bit 5。
- **未完成问题**：Continue／Save 当前地点仍显示中文；需与 Town Map、Fly、Pokédex AREA、CGB 地名牌统一进入地图名称系统，不做单页补丁。
- **阶段1审计**：248 个物理 map ID、52 个 TownMap selector、60 条内部范围、13 个特殊 Fly 目的地、13 条 marker override、109 条 CGB map-id 映射、107 个图形 label 已建立首轮交叉表；renderer 名称变体和 Bank-safe ABI 仍待设计评审。
- **质量风险**：`data.xlsx` 导入器的 stale key、条件上下文失配和 MISSINGNO 重复键冲突仍待设计质量门；优先扩展现有导入流程。
- **范围决定**：公共 YES／NO 选项框继续暂缓；LANGUAGE 与 Names 两个设置不擅自合并；不修改存档布局／自定义昵称兼容规则。
- **构建边界**：按项目要求使用 RGBDS 1.0.4，由维护者在项目根目录 `make red`、`make blue` 并保存新 MAP／ROM SHA；AI 不自行编译／链接 ROM，不伪造 MAP／SHA，不执行 Git Commit／Push。

### 维护文档更新顺序

1. 每轮先读项目生效要求、`TODO.md`、本总计划、相关模块说明和验收历史。
2. 盘点阶段更新覆盖主表、屏幕组件矩阵和模块专用台账。
3. 实施模块时更新对应技术说明、总计划阶段状态和 `TODO.md` 顶部当前待办。
4. 只有收到用户明确实测反馈，才向 `docs/CHS_ACCEPTANCE_HISTORY.md` 追加验收记录；静态 PASS、链接 PASS、实机 PASS 分开写。
5. 不直接编辑 RPP 自动生成的 `RPP_PROJECT_CONTEXT/` 文件；长期项目要求在 RPP 原始要求编辑位置维护后重新导出。


---

## ROM-1.42 — 图鉴评价与玩家资料双语正式清理（2026-11-07；模式 A 提交准备）

- **实现范围**：Continue／Save 信息（PLAYER、BADGES、POKéDEX、TIME）、Trainer Card（NAME、MONEY、TIME、BADGES）、Hall of Fame 玩家统计（PLAY TIME、MONEY）。
- **语言机制**：继续使用 `wOptions` bit 5；中文文本仍由现有 XLSX 导入，English 备选字符串与中文替换键隔离；动态玩家名、数量、时间、金钱读取不变。
- **正式清理**：`GameVersionText` 从 `ROM-1.42B` 改为 8 字符 `ROM-1.42`；Options 版本绘制起点从 x=10 恢复 x=11。除版号和对齐外，不改已接入的运行逻辑。
- **用户反馈更新**：用户表示按此前要求抽测的其他界面未见明显问题；Continue／Save 当前地点仍为中文。固定标签与动态地图地点是不同组件，整页尚不能标记双语完成。
- **审计与下一阶段**：首轮只读 crosswalk 覆盖 248 个物理 map ID、52 个 TownMap selector、60 条内部范围、13 个特殊 Fly 目的地、13 条 marker override、109 条 CGB map-id 映射和 107 个 label；名称 variants 与 renderer ABI 待评审。Continue／Save 地点仍显示中文。
- **ROM-1.42C 教训**：试验补丁因跨 Bank `farcall` 后把 A 中的 map ID 当作仍然有效，导致 Bank `$1C` 被误读为 `ROUTE_17`，已撤销。后续必须显式保存／重载参数并检查 Bank／寄存器 ABI，不复用 C 的实现。
- **验收边界**：用户已对玩家资料相关界面进行局部抽测并反馈未发现明显问题；图鉴评价录像覆盖 Oak's Lab 与 HOF 所展示场景。尚无本轮 ROM-1.42 红／蓝新 MAP／ROM SHA；静态检查不等于链接或全平台手机验收。
- **本轮静态复核**：22/22 单元测试 PASS；`prepare_build.py` 成功导入／同步 2,587 个文件；地图对白、图鉴评价、玩家资料专项静态守卫 3/3 PASS。全部 17 个 `verify_*.py`：5 PASS／12 FAIL；11 个历史脚本只因旧版号白名单失败，`verify_qol116_static.py` 的 11 项功能检查 PASS、旧版号／Options 对齐两项 FAIL。没有修改／弱化旧守卫；负向移除 English selector 后玩家资料守卫按预期失败。

---

## ROM-1.42A — 图鉴统计／博士评价双语接入（开发候选）

> 当前开发基线：用户最新 `ROM-1.41.zip` 的干净 `CHS_Mod` HEAD `608a85501b97174401367f544427aaac60639e54`，游戏版本 ROM-1.41。测试候选 ROM-1.42A，不代表正式版或实机验收通过。
> 补丁基线：导出记录标记 Worktree clean、无未提交 patch；增量与全量补丁因此从同一快照起算，文件内容相同，是二选一的替代补丁，不得叠加。ZIP 不含 `.git` 对象，本轮对导出源码快照执行正向／反向 `git apply` 验证，不声称已在用户真实仓库提交。

> **后续用户验收补充**：用户提供 `1.42A.mp4` 与 `名人堂评价.mp4`；English 下 Oak's Lab 图鉴评价、Hall of Fame Seen／Owned／Rating 均显示英文，Seen／Owned 为 151／151，评价正文与研究所相同。用户确认中文模式正常。此为录像所示范围，不扩张为全平台矩阵验收。

- **构建入口**：继续使用项目根目录 `_prepare.command`／根 `Makefile`；也可先运行 `python3 scripts/prepare_build.py` 做 XLSX 导入、源码同步和静态英文数据生成。不要直接从 `src/` 编译。
- **双语入口**：`src/engine/events/pokedex_rating.asm` 中 `DexCompletionText` 和 16 个 `DexRatingText_Own*` wrapper 改用 `text_bilingual`；同一 LANGUAGE bit 5 选择 CHS／English。`src/engine/movie/hall_of_fame.asm` 中 `DexSeenOwnedText` 与 `DexRatingText` 两个名人堂统计 wrapper 也使用相同命令。
- **英文来源**：复用 `src/text/pokedex_ratings.asm` 的同代英文原文，以及 `src/data/text/text_2.asm` 的 `_DexSeenOwnedText`／`_DexRatingText`；不手工重写 19 段英文。构建前置生成 `buildRB/data/english_text/generated_pokedex_ratings.asm`。
- **特殊字形／动态值**：只在英文字符串字面量内将已确认的 `#` 扩展转换成普通 `POKé`，使 `#DEX`／`#MON` 不再进入 CHS `PlacePOKe`；`text_decimal` 的 seen／owned 动态计数命令原样保留。16 档阈值、计数逻辑、声音、事件标志和 YES／NO 选择逻辑不改。
- **静态测试结果**：17/17 单元测试通过；`prepare_build.py` 首次完成 2,587 文件导入／同步，后续生成器更新只同步 2 个生成文件；再次运行可复用已有构建对象。地图对白静态检查与本轮 `verify_rom142_pokedex_rating_static.py` 均通过；`git diff --check` 通过。
- **历史检查器结果**：本轮运行项目全部 16 个 `verify_*.py`：4 PASS／12 FAIL。11 个历史脚本因版号白名单不认识 ROM-1.42A 而提前失败；`verify_qol116_static.py` 的功能检查项通过，但旧正式版号／Options 坐标断言不接受 1.42A。没有修改或弱化旧检查；本轮新增的图鉴静态检查及既有地图双语静态检查均 PASS。
- **ROM 空间**：19 个英文标签估算 1,661 bytes，固定在 ROMX `$70`；地图对白生成器明确封顶 `$6F`，避免以后扩容时与图鉴数据重叠；ROM-1.41 MAP 显示该 Bank 空余 16,384 bytes。17 个 `Pokédex Rating` wrapper 在 Bank `$11` 增加 51 bytes（旧 MAP 空余 3,397 → 投影 3,346）；2 个 Hall of Fame wrapper 在 Bank `$1C` 增加 6 bytes（271 → 投影 265）。ROM0 不增加运行代码，只有 `ROM-1.42A` 版号字符串增加 1 byte（旧 MAP 空余 431 → 投影 430）。这些只是基于 ROM-1.41 MAP 的静态投影，最终必须由维护者用 ROM-1.42A 红／蓝新构建 MAP 确认。
- **Hall of Fame 兼容**：`DisplayDexRating` 原有 Hall of Fame 分支把选中的 rating wrapper 复制到 `wDexRatingText`，直到 `TX_END`。`text_bilingual` wrapper 为 8 bytes（opcode＋两根 far pointer＋terminator）；它使用现有 180-byte WRAM union，不扩展 WRAM 或改变存档布局。
- **静态验收**：运行 `python3 -m unittest discover -s tests -v`、`python3 scripts/prepare_build.py`、`python3 scripts/verify_rom141_bilingual_dialogue_static.py`、`python3 scripts/verify_rom142_pokedex_rating_static.py`、`git diff --check`。新检查器覆盖 19 个标签、16 个阈值、动态 decimal、`#` 特殊扩展、名人堂 wrapper copy 和固定 Bank `$70`。
- **实机验收**：Oak's Lab 同一次完整对话 English 下开场／seen／owned／博士评价全英文；中文下全中文；分别重新进入、切换语言及保存重启。若可到达名人堂，再检查 Seen／Owned 和评价文字。实测范围只按用户实际展示记录。
- **边界**：本轮不接入图鉴列表／条目／地点，不修改共用 YES／NO、战斗、名称表或其它 UI；不改 `DisplayDexRating` 统计／阈值／声音／事件行为。AI 不运行 RGBDS／`rgblink`，不生成 ROM／MAP／SHA，不执行 Git Commit／Push。

---

## ROM-1.41 — 第一阶段地图脚本对白双语正式清理（2026-11-07；模式 A 提交准备）

> 本轮正式基线为 `CHS_Mod` HEAD `bd091a28bf2e1f87de59c44be694b35d7d8b4405`（ROM-1.40）。用户提供的 ROM-1.41B Worktree 通过其 `current_worktree.patch` 重建；ROM-1.41C 全量补丁＋HF1 与 ROM-1.41B Worktree＋C 增量补丁＋HF1 两条路径已核对得到相同文件树。正式版号由测试候选 `ROM-1.41C` 清理为 `ROM-1.41`。

- **正式版本清理**：`src/data/game_version.asm` 从 `ROM-1.41C` 改为 8 字符 `ROM-1.41`；Options 右上角版本绘制起点由 x=10 恢复 x=11，右边缘仍为 x=18。只做正式版号与对齐清理，不改变语言位、存档结构或 Options 操作。
- **功能范围**：保留 `TX_BILINGUAL`（`$18`）双 far-pointer 命令，按既有 `wOptions` bit 5 选择 CHS／English；地图脚本 1,944 条 `text_far` 中接入 1,942 条、1,941 个唯一标签，另 2 条既有 English pilot wrapper 保持原样。英文源自同代源码及独立人工补充；8 条人工英文不是上游原文。`#` 特殊扩展共处理 579 处；保留动态姓名、RAM／数字命令；未知 token、未知命令和嵌套 far-text fail-closed。
- **HF1 运行时修复**：首版 C 的 CHS 分支读取 3-byte 中文 far pointer 后未跳过 3-byte 英文 pointer，导致 `NextTextCommand` 从英文地址数据中间继续读取，实机出现空白对话框／卡死。HF1 修正 CHS 分支完整消费 6-byte payload；English 分支跳过 CHS pointer 后读取 English pointer；普通 `text_far` 路径不变。两条分支均有单元测试及专用静态守卫。
- **用户视频验收记录**：`1.41C.mp4` 记录 HF1 前空白对话框／卡死；HF1 后 `1.41C优化.mp4` 显示 Viridian City 英文提问与英文 YES／NO 分支正常，切回中文后中文对白正常。YES／NO 选项框仍显示「是／否」，这是用户明确暂不修改的独立共用菜单系统，不算本阶段失败。`1.41C，其他三位NPC测试.mp4` 显示 Fly House 与 Fishing Guru 的英文／中文对白均有对应画面；测试只覆盖录像中实际出现的分支，不扩张为全地图 1,942 条逐条实测。
- **图鉴范围外问题**：同一视频中，大木博士的地图开场对白显示英文，随后 `DisplayDexRating` 的动态数量／评价文字仍显示中文。源码路径是 `src/scripts/OaksLab.asm` → `predef DisplayDexRating` → `src/engine/events/pokedex_rating.asm`／`src/text/pokedex_ratings.asm`；这是地图脚本生成器范围外的独立图鉴引擎文本，已登记 `docs/ROM141_NEXT_PHASE_POKEDEX_RATING_SCOPE.md`，本次不修改。
- **静态验证**：`python3 -m py_compile ...` 通过；`python3 -m unittest discover -s tests -v` 为 9/9 PASS；`python3 scripts/prepare_build.py` 成功生成 1,942 references／1,941 English labels；`python3 scripts/verify_rom141_bilingual_dialogue_static.py` 通过，检查所有 CHS／English 目标、14 个 ROMX section `$62-$6F`、6,818 行可见文本及 18/18 最大行宽；`git diff --check` 通过。旧 14 个历史 `verify_*.py` 仍为 2 PASS／12 FAIL：失败主要是旧版本白名单，`verify_qol116_static.py` 的功能项 PASS 但旧版号／Options 对齐断言失败；未修改旧守卫，不宣称全量审计 PASS。
- **MAP／构建边界**：用户提供的 `MAP_20261107_080844.zip` 内红／蓝 MAP 版本标为 ROM-1.41C，但时间为 08:07／08:08，早于 HF1；因此只能作为 HF1 前的历史链接证据，不能用于 HF1 后 ROM-1.41 的最终 Bank 空间证明。用户随后提供 HF1 后测试视频，但尚未提供 HF1＋正式版号清理后的红／蓝 MAP 与 ROM SHA。AI 未运行 RGBDS／`rgblink`，未生成正式 ROM／MAP／SHA。
- **提交拆分**：本轮相对正式 HEAD 同时修改游戏 ASM／文本资源和构建生成器、测试、静态验收工具，按项目模式 A 拆为两笔：① `feat(text): 批量接入地图脚本中英文对白`（全部 `src/` 功能代码与正式版号）；② `test(tool): 增加双语对白生成与回归检查`（生成器、构建集成、静态检查、单元测试及配套审计／TODO／维护文档）。交付 ZIP 固定 5 件：清理增量、工具反向隔离、HEAD 全量、功能日志、工具日志。增量与全量互斥。
- **尚未关闭的验收**：必须由维护者用正式 ROM-1.41 源码重新构建红／蓝，保存新 MAP／ROM SHA，检查 ROM0、Maps Banks、英文 `$62-$6F` 和 ROM 总容量；再继续完成剩余地图测试计划、保存重启和必要的 DMG/CGB 检查。图鉴评价、YES／NO 菜单、战斗、名称和其它 UI 不纳入本阶段。
- **Git 边界**：本次交付为可提交的补丁和两份日志；未对远端执行 Push。项目当前输入是导出 Bundle／Worktree，不是用户实际连接的 Git 工作区；正式 Commit／Push 由维护者在自己的仓库按两笔日志执行。

Version: ROM-1.40 → ROM-1.41

---

## ROM-1.41C-HF1 — 双语对白指针推进修复（历史修复记录；已纳入 ROM-1.41）

> 依据用户 2026-11-07 上传的 `1.41C.mp4` 录像及 ROM-1.41C 源码／MAP 核查。原 ROM-1.41C MAP 只能证明成功链接，不能证明双语命令运行时指针推进正确。应用本节热修补丁后，必须重新构建红／蓝 ROM 并重新生成 MAP；此前 MAP 不再代表热修后的二进制。

- **用户实测现象**：首次地图对话弹出空白文本框并卡住。录像可确认空白框；录像显示的是 Options 第 1 页，未直接展示 LANGUAGE 第 2 页的选择状态，因此不能单凭录像确认 English 位是否确实置位。
- **已确认根因**：`text_bilingual` 在脚本中连续存放 6 字节数据：CHS far pointer（3 字节）＋ English far pointer（3 字节）。旧版 `TextCommand_BILINGUAL` 在中文分支读完第一根 CHS 指针后，没有跳过后面的 English 指针；外层 `NextTextCommand` 因而从第二根指针中间继续读取，把地址字节误当成文本命令。该错误可导致空白框、读取错位或卡死。
- **修复方式**：中文分支读取第一根 CHS 指针后，额外跳过 3 字节 English 指针；英文分支仍先跳过 3 字节 CHS 指针，再读取 English 指针。两条路径都在调用文本处理器前把外层脚本指针推进到 6 字节 payload 之后；普通 `text_far` 继续走原有读取路径。
- **回归测试**：更新 `tests/test_generate_bilingual_dialogue.py`，分别断言 CHS 和 English 两条路径都会跳过未选中的 3 字节指针；更新 `scripts/verify_rom141_bilingual_dialogue_static.py`，防止以后只检查 English 分支而漏掉 CHS 分支。
- **本轮验证**：`python3 -m unittest discover -s tests -v`：9/9 通过；`python3 scripts/prepare_build.py`：成功生成 1,942 条引用／1,941 个英文标签；`python3 scripts/verify_rom141_bilingual_dialogue_static.py`：通过。以上均为源码／构建前置静态验证，不等于 RGBDS 编译或实机通过。
- **维护者必须重新构建**：对热修后的源码重新执行 `make red` 和 `make blue`，生成新 ROM 和新 MAP。旧 ROM-1.41C 二进制及旧 MAP 不可继续作为验收依据。
- **用户最小复测**：先用中文模式与 Viridian City 提问“两种毛毛虫宝可梦”的男孩对话，检查首次对话、YES、NO 三条路径；再到 Options 第 2 页明确选择 English，退出菜单后重复测试。最后 English → 中文切回，并保存／重启确认。若 English 仍失败，先记录 Options 第 2 页的实际光标位置及 ROM 文件校验值，不要继续扩展测试范围。

---

## ROM-1.41C — 地图脚本对白批量双语接入（历史开发候选；已由 ROM-1.41 正式清理）

> 本节描述源码候选和构建前置步骤，不代表 ROM 已经编译、链接或通过手机验收。正式版本仍为 ROM-1.40；ROM-1.41A/B/C 都是同一轮测试候选。

- **基线**：`CHS_Mod` HEAD `bd091a28bf2e1f87de59c44be694b35d7d8b4405`；当前 ROM-1.41B Worktree 由上传 ZIP 中的 `RPP_PROJECT_CONTEXT/patches/current_worktree.patch` 重建。`RPP_COMMIT_RESTORE/manifest.json` 的 `exact_restore_allowed=false`，不重放 mbox。
- **生成入口**：使用项目根目录的 `_prepare.command`／根 `Makefile`，不要直接从 `src/` 编译。也可单独运行 `python3 scripts/prepare_build.py` 生成 `buildRB/`；该命令只做 XLSX 导入、源码同步和双语对白生成，不调用 RGBDS。
- **双语数据**：XLSX 导入后，`scripts/prepare_build.py` 调用 `scripts/generate_bilingual_dialogue.py`。它从同代英文源 `src/text/`、`src/data/text/text_1..7.asm` 及 `src/data/english_text/manual_dialogue_overrides.json` 生成 `buildRB/data/english_text/generated_dialogue.asm`，并在 `buildRB/scripts/` 中把可路由的 `text_far` 改为 `text_bilingual`。源脚本和 XLSX 不被改写。
- **语言选择**：`text_bilingual` 携带 CHS／English 两个 far pointer；ROM0 的 `TextCommand_BILINGUAL` 读取 `wOptions` bit 5，选择指针后复用原 `TextCommand_FAR`。新增 ROM0 指令静态估算 18 bytes；不新增 WRAM/SRAM/存档字段。
- **生成结果**：1,942 条脚本引用、1,941 个英文文本标签；英文数据估算约 164,395 bytes，14 个 ROMX 段固定在 `$62-$6F`。旧 ROM-1.41B MAP 显示 `$62-$7F` 30 个空 Bank。地图脚本指针额外增加 5,826 bytes；旧 MAP 投影最紧张 Bank `$13` 仍余约 86 bytes。最终空间必须以新 MAP 为准。
- **自动检查**：`python3 -m unittest discover -s tests -v`（9 项）；`python3 scripts/verify_rom141_bilingual_dialogue_static.py`（须先生成 `buildRB/`）；`git diff --check`。旧 14 个历史 `verify_*.py` 在本轮为 2 PASS／12 FAIL，失败原因是旧版号／Options 坐标断言；见 `TODO.md`，不要把它们写成全量通过。
- **维护者最终验收**：在根目录分别执行 `make red` 与 `make blue`；检查新 MAP 的 ROM0、Maps Bank `$06/$07/$11-$18/$1D`、英文数据 `$62-$6F` 和 ROM 总容量。手机抽查 Route 1、Viridian City、Oak's Lab、Fly House、Fishing Guru、Safari Zone Gate、Viridian Mart、Pokémon Fan Club、训练家战斗前后对白；重点检查 `#` 展开、7 字符玩家／劲敌姓名、运行时 RAM 文本、18 列行宽、分页、语言切回与保存重启。
- **人工文本**：8 条英文人工补充（7 条新增教学／重复对白，1 条卧室电脑升级通知）不是上游英文原文，必须由维护者／用户确认措辞。3 条原版英文只调整换行；词句不变。
- **未覆盖范围**：511 个未被地图脚本 `text_far` 调用的翻译标签、战斗引擎直接文本、菜单、图鉴、名称表及其它 UI 入口仍未接入；English 不能宣称为全游戏英文版。
- **禁止事项**：本轮 AI 不运行 RGBDS／`rgblink`，不生成 ROM/MAP/SHA，不执行 Git Commit/Push。测试版号保留 `ROM-1.41C`；正式收口必须等待用户验收，并按要求去掉字母、递增正式版本号。

---

## ROM-1.41B — 修正英文样本中的特殊文字扩展（2026-11-07；开发候选）

- **基线／前置状态**：Git 基线 `bd091a28bf2e1f87de59c44be694b35d7d8b4405`；增量补丁前置为用户已应用的 `ROM-1.40.patch` 与 ROM-1.41A 增量补丁。测试版号 `ROM-1.41B`，不是正式 ROM-1.41。
- **用户实测证据**：用户上传录像显示 English 模式下 Viridian City 对话仍显示“宝可梦 BALLs / 宝可梦 MON”。ROM-1.41A 不通过验收。
- **根因**：`src/home/text.asm` 将 `#` 分派至 `PlacePOKe`，再调用共享 `PlacePOKeText`；CHS 构建的共享扩展会输出中文。`src/tools/_importText.py` 明确包含 `#MON`、`#` 与“宝可梦”的替换规则。A 版英文副本沿用了原版 `#MON`，所以仍调用 CHS 扩展。
- **修正**：英文静态副本将 `#MON`／`# BALLs` 写为普通英文 `POKéMON`／`POKé BALLs`，避开特殊命令；中文源文本、中文 far-text 指针和原共享扩展不改。英文文本最长行 17 字符，实际字宽与分页仍待手机复测。
- **特殊 token 风险**：`<PC>`、`<ROCKET>`、`<TM>`、`<TRAINER>`、`<PKMN>` 等扩展仍需逐项审计；玩家名／对战名和 `<CONT>`／`<PAGE>` 等控制语义不得被简单字符串替换。见 `docs/ROM141B_SPECIAL_TOKEN_AUDIT.md`。
- **构建边界**：不新增 WRAM/SRAM、不改存档结构；本轮不运行 RGBDS、不链接 ROM、不生成 ROM/MAP/SHA，不执行 Git Commit/Push。
- **最小复测**：English 下确认 `POKé BALLs`、`POKéMON` 完整显示且不再出现中文“宝可梦”或残留 `MON`；检查换行分页、切回中文、保存重启。再检查 Route 1 样本不受影响。

---

## ROM-1.41A — 双语静态 NPC 文本读取原型（历史候选；实测发现特殊文字扩展错误，已由 ROM-1.41B 修正）

- **基线**：本轮核实的 `CHS_Mod` 干净 HEAD 为 `bd091a28bf2e1f87de59c44be694b35d7d8b4405`，正式版本 `ROM-1.40`。测试版号按项目要求使用 `ROM-1.41A`；尚未获得本轮手机验收，不得去掉 A 或视为正式 ROM-1.41。
- **功能范围**：把既有 Route 1 第二位 NPC 的语言选择改为共享 `bilingual_text` 宏；新增 Viridian City 第一位 NPC 的中英文样本；A 版后来发现其中 `#` 是动态特殊指令，并非普通静态字符，已由 B 版修正。宏读取原有 `wOptions` bit 5，0 走原 CHS far-text，1 走 English far-text。两处 CHS 文本标签和 XLSX 翻译不改。
- **英文资源**：把 `_Route1Text2English` 从 Options Bank `$45` 移到 `src/data/english_text/english_pilot.asm`；新增 `_ViridianCityText1English`。两段英文数据由 `src/main.asm` 的 ROMX Bank `$46` 独立收录，避开 CHS XLSX 工作表实际写入的输出路径。Bank `$46` 在 ROM-1.40 随包 MAP 中为空。
- **代码／空间边界**：共享宏在 `src/macros/scripts/text.asm`，展开位置分别属于 Route 1 脚本 Bank `$07` 和 Viridian City 脚本 Bank `$06`。ROM-1.40 参考 MAP 中这两个 Bank 分别有 0x0B9D／0x15D4 bytes 空闲；Options Bank `$45` 有 0x3A50 bytes 空闲。ROM0 无新增执行代码，只有测试版号字符串由 8 字符增为 9 字符（+1 byte）；不增加 WRAM/SRAM、不改存档结构。以上均为旧 MAP 参考值，最终空间必须看维护者本地 ROM-1.41A 新 MAP。
- **文本类型限制**：A 版原先误判 Viridian City 对白为无动态占位符，实际 `#` 会调用特殊文字扩展；B 版已改为普通英文拼写；Route 1 赠药 NPC、Route 1 路牌、Viridian City 其它 NPC、剧情动态文本、战斗／图鉴／菜单仍未接入。English 仍不是完整英文版。
- **静态验证边界**：执行宏／标签／far-text 指针／英文原文逐行一致性检查、`git diff --check` 和补丁正反应用验证；不运行 RGBDS、不链接 ROM、不生成 ROM/MAP/SHA、不 Git Commit/Push。静态检查不代表编译或手机实测通过。
- **开发阶段交付**：按要求只交增量补丁、HEAD 全量补丁及一个只含这两份补丁的 ZIP；两份补丁二选一，不叠加。没有工具／审计脚本改动，不制作提交日志或工具反向隔离补丁。
- **最小实机验收**：LANGUAGE=中文和 English 分别检查两位 NPC；切换回中文、保存重启后复查；确认 `POKéMON`／`POKé BALLs` 普通英文字符、换行分页正确，且未接入文本仍保持原 CHS。红／蓝和 DMG／CGB 的完整范围由维护者按项目矩阵验收。

---

## ROM-1.40 — ROM-1.39D 双语 Options 正式收口（2026-11-06；清理候选）

- **基线**：RPP 导出记录声明 `CHS_Mod` 已提交 HEAD `04324e16a071d4a9972eb4d7b69d03d11ba26bcb`（正式 ROM-1.39）。累计全量补丁从该 HEAD 重建；清理增量从用户已确认无问题的 ROM-1.39D 开发候选工作区开始。ROM-1.39A/B/C/D 均为同一轮开发候选，不作为额外正式版本或独立提交。
- **用户验收**：用户对 ROM-1.39D 回复“没问题了”，据此记录本轮 Options 页脚残影修正及对应界面效果已获用户确认；不扩大为红／蓝版、DMG／CGB 的完整平台矩阵全部通过。
- **正式清理范围**：`src/data/game_version.asm` 将 `GameVersionText` 从 `ROM-1.39D` 改为正式 `ROM-1.40`；正式版号为 8 字符，因此 `src/engine/menus/options_bilingual.asm` 的 Options 右上角版本绘制起点从 x=10 调回 x=11，右边缘仍为 x=18。除版本常量和该显示坐标外，不再改动运行逻辑。
- **功能保持**：保留 Options 中英文页均不显示 `B:BACK`／`B:返回`、首次进入默认选中 PAGE、A／左右翻页、B／START 退出、两处用户特意保留的「中文」选项原字码，以及页脚清理区域 x=11..18、y=15..17。LANGUAGE 位、WRAM／SRAM 和存档格式不变。
- **LANGUAGE 范围限制**：本轮仍是第一阶段试点，仅 Options 与 Route 1 一位 NPC 使用语言切换；English 模式不代表全游戏对白、战斗、菜单和图鉴均已英文覆盖，后续待办继续保留。
- **提交拆分**：累计差异包含 LANGUAGE 资源盘点脚本及其报告／TSV，按项目模式 A 分为 `feat(menus)` 游戏功能提交与 `test(tool)` 审计提交；工具部分由反向隔离补丁单独撤回／恢复。
- **交付五件套**：①ROM-1.39D→ROM-1.40 清理增量补丁；②最终状态→仅保留游戏功能的工具反向隔离补丁；③`04324e16...` 正式 HEAD→ROM-1.40 累计全量补丁；④功能提交日志；⑤工具／审计提交日志。共 3 份补丁＋2 份日志。增量与全量互斥。
- **构建与提交边界**：由维护者本地运行官方 RGBDS `make red`／`make blue`，检查新 MAP、Bank 空间和红蓝 ROM。本环境不运行 RGBDS、不生成 ROM／MAP／SHA，也不执行 Git Commit／Push。补丁可逆应用与静态核对不等于 ROM 构建或完整平台实测。

---

## ROM-1.39D — 修正 Options 中文页脚「返回」上半字残留（2026-11-06；开发候选历史，用户已确认本项正常）

- **实测证据／根因**：用户的 ROM-1.39C 中英文 Options 第二页截图中，中文页码右侧仅有「返回」的上半字笔画。中文 DFS 的 8×16 双行字形上半部实际位于 tile y=15；C 版仅清除 x=11..18、y=16..17，因此遗漏 y=15。英文页脚不存在相同残影。
- **最小修复**：保留 CHS `PAGE 1/2   B:BACK@` / `PAGE 2/2   B:BACK@` 翻译匹配键不变；绘制中文页码后，统一清空右半部 x=11..18 的 y=15、16、17 三行，不触及左侧页码、光标或边框。英文也经过相同清除路径，但仅清空既有空白区。English 模式刻意设计的两处「中文」字码原样保持。
- **版本和限制**：候选 `ROM-1.39C → ROM-1.39D`，9 字符右对齐起点为 x=10；逻辑只在 Options Bank `$45`，ROM0 只变更版本常量，不增加 WRAM/SRAM/存档字段，不改变 A/左右翻页、B/START 退出、默认 PAGE 光标。用户随后反馈“没问题了”，仅记录本轮页脚问题已确认，不代表红蓝／DMG/CGB 全矩阵通过；ROM-1.40 正式版改回 8 字符并将 Options 起点恢复 x=11。

## ROM-1.39C — Options 只保留翻页提示（2026-11-06；开发候选）

- **基线与版本**：RPP 导出声明 `CHS_Mod` 的正式 Git HEAD 为 `04324e16a071d4a9972eb4d7b69d03d11ba26bcb`，在已纠正中文标签的 ROM-1.39B 开发状态上追加更改；游戏内 `ROM-1.39B → ROM-1.39C`，不是正式提交。
- **改动**：删掉 English 两页 `B:BACK` 提示；CHS 页码保留原始翻译匹配键，在绘制完成后清空 x=11..18、y=16..17 的所有返回提示图块（DFS 双行汉字也覆盖），保留页码以及选项值的两处「中文」。Options 入口默认光标从第一项 y=3 调到 PAGE y=16，x=1；正常翻页、选项更改和 B/START 退出逻辑不改。
- **工程边界**：Bank `$45` 内更改绘制/初始光标，ROM0 仅更改 9 字符版本数据；无 WRAM/SRAM、存档结构、翻译表、脚本/审计工具改动。此源码快照未提供生成中文所需 XLSX，故保留旧 CHS 翻译字符串，编译后仍需实机验证字形和翻页。按项目要求不进行 RGBDS ROM 编译／链接，也不 Git Commit/Push。

## ROM-1.39B — OPTIONS 页脚 B 提示与 ENGLISH 起点对齐（开发测试候选；待手机验收）

- **源码基线**：本轮输入为 ROM-1.39A 的完整 Worktree；RPP 导出声明分支 `CHS_Mod`、正式 HEAD `04324e16a071d4a9972eb4d7b69d03d11ba26bcb`。A 是该 HEAD 上的开发候选；开发增量补丁以 A Worktree 为基线，全量补丁从声明 HEAD 累计重建。
- **用户确认的设计**：English 模式下「宝可梦名称」和「LANGUAGE」两处语言选项故意显示「中文 / ENGLISH」，不是汉字残留，必须原样保留。早期 B 候选误将「中文」改为 `CHINESE`，本次已按 A 源码恢复原 DFS 字码 `$18,$C6,$11,$70`，并纠正错误说明。中文模式及所有其他选项文案保持不变。
- **页脚修正**：录像显示上方 `ENGLISH` 的 E 位于 tile x=12，而 A 版页脚 `B:` 位于 x=13。English 第一页／第二页页脚改为从 x=12 显示 `B:BACK`；中文页脚清除 x=12..18 后从 x=12 绘制 `B:返回`。不再改变选项文字。START 与标题 Options 入口共用此 Bank `$45` 路径。
- **测试版号**：按测试候选 A/B 规则，游戏内版本由 `ROM-1.39A` 递增为 `ROM-1.39B`。9 字符 Options 右上角继续从 x=10 绘制；主菜单版本位置不变。
- **空间与兼容**：不新增 ROM0 运行代码；Options 代码留在 Bank `$45`。不增加 WRAM/SRAM、不修改存档结构、LANGUAGE 位、翻页、光标或输入行为。版本文字长度与 A 相同。
- **验证边界**：A 版录像用于定位对齐需求；本次只进行源码静态检查、补丁重放与文件一致性比对。未运行 RGBDS 编译／链接，未生成 ROM/MAP/SHA，未作 B 版手机实测。最小复测：English 两处选择仍为「中文 / ENGLISH」，两页中英文 B 起点 x=12，不出现页脚残字或边框覆盖；测试 START/标题 Options 两种入口及 DMG/CGB。

---

## ROM-1.39 — 当前工作区功能收口、商店箭头位置修正（2026-11-06；待维护者 Commit）

- **正式起点**：`CHS_Mod` ROM-1.38 已提交 HEAD `537e0ddcce101936495ecedb0140413d1825a253`。用户新提供的 `ROM-1.38(1).patch` 是这笔 HEAD 上未提交的工作区差异，不是新的正式 HEAD；本轮使用其 11 个变更文件的 Git blob SHA-1 精确重建，并追加已测试的商店箭头修正。
- **功能收口**：沿用 ROM-1.38 的 START 道具说明与 HM02 教学；新增玩家 PC 存入／取出／丢弃，以及商店 BUY/SELL 中文道具说明；常规可得道具细化，两行共用说明覆盖进化石；商店保持四行商品、金钱框原位。延迟恢复 OAM 以避免人物叠在列表和返回界面上。
- **箭头专项**：商店向下箭头绘制在 y=11，旧闪烁探针按共用描述标志查 y=10；仅在商店会话状态 2 时让探针查 y=11，START／PC 仍 y=10。`光标修复(1).mp4` 实测画面可见正常 ▼ 亮灭及滚动。本版不引入 RPP #042 的左右 ±4 翻页。
- **保留范围**：用户已决定 PASS 商店退出购买列表时的少量 BG 过渡帧，不重新引入此前的商店 BG 离屏/底部优先试验；不修改 `pokemart.asm`／`tilemap.asm`、任何现有 `jr`/`jp`、存档、背包容量、翻译数据或工具脚本。正式游戏版号仅从 ROM-1.38 升至 ROM-1.39。
- **补丁模式**：模式 B，计划由维护者单笔功能提交。交付三件套为：当前工作区（已包含箭头修复）→ ROM-1.39 的清理增量、正式 `537e0ddc` → ROM-1.39 的累计全量、中文提交日志。两种补丁仅择一应用。补丁静态验证与实际编译是两回事。
- **构建/运行证据**：本轮没有由 AI 编译、链接、运行 ROM 或生成新 MAP；用户的视频证明商店箭头在该录像场景下修复，不能据此宣称全平台回归完成。Bank `$01`／ROM0 等最终余量由维护者按 RPP 正式脚本确认，Git Commit/Push 由维护者自行执行。

---

> **ROM-1.38 清理候选（2026-11-06）**：最新 `ROM-1.37.zip` 导出标识 `CHS_Mod`、正式 HEAD `536601748713d0656e23834e1533851c0000eee5`（ROM-1.37）及有未提交 Worktree 改动。本轮仅从该实际 Worktree 升正式游戏版号至 ROM-1.38 并归档清理说明；**尚未有 ROM-1.38 Git 提交或构建证据**。以下旧“Worktree 干净”仅描述 ROM-1.37 HEAD 当时状态。

## ROM-1.38 — 背包道具短描述与 HM02 教学清理说明（待维护者 Commit）

- **功能来源**：用户当前 Worktree 含 HM02 赠送者领取后的 ↑↓ 城镇、A 确认、←→ 特殊地点教学；START→Bag 下方两行道具说明（83 个普通物品 ID、TM50/HM5 动态招式名）及上下框紧贴布局。上框与名称、数量、Cancel、光标、滚动箭头同步整体上移，底部说明框保持独立；PC、商店、战斗列表不套用此布局。
- **刷新与 OAM**：原说明只在外层菜单重新绘制时更新，普通上下移动可能被内层输入处理而显示旧字；候选在内部光标变化时强制刷新说明。原地图人物精灵可能盖住下方框体，START Bag 入口暂时隐藏地图 OAM、退出恢复先前状态。保留 SELECT 交换、USE/TOSS、20 格背包、原始存档布局。
- **清理边界**：保持当前 Worktree 运行代码，包括已存在的 JR/JP，均不作新功能改写；只将 `src/data/game_version.asm` 中正式版本号 ROM-1.37 升至 ROM-1.38，并整理 TODO、维护说明和验收状态。83 条中文短说明的数值细化延后，需先核对 CHS 实际效果；测试版号与 XLSX 均不改。
- **提交/复测**：相对 `53660174` 无工具脚本修改，模式 B 单笔 `feat(menus)`：当前 Worktree 清理增量、该正式 HEAD 累计全量、中文提交日志。两补丁互斥。先前视频揭示过超框、Cancel 后残字、说明不实时刷新和 OAM 覆盖；当前候选尚待用户复测首尾/Cancel/TM/HM/菜单返回及 HM02 对话。按项目规则不由 AI 编译/链接，不运行 Git Commit/Push；Bank 余量及 ROM/MAP/SHA 由维护者本地构建确认。

> **ROM-1.37 当前正式导出校准（2026-11-05）**：项目 `CHS_Mod` 已正式提交 `536601748713d0656e23834e1533851c0000eee5`，工作区干净。下方“提交准备／待 Git Commit”属于历史阶段；RPP 442 项现行进度统一见 `docs/RPP_REFERENCE_PORT_CURRENT_STATUS_ROM-1.37.md`。随包红版 MAP 标注 ROM-1.37，相关 Bank 余量为导出证据，不是本次新编译结果。

## ROM-1.37 — 钓鱼专项清理及维护要点（2026-11-05）

- 本版基于 `CHS_Mod` 正式 HEAD `b24357fdb4dd4e5c6715c4475da5fb4edb8ca53b`（ROM-1.36）累计整合 RPP #084、#381～#384 和 Continue 地名牌初次战斗返回修复；不直接移植 #385。已验收候选只做版本与文档收口，不改运行行为。
- 钓鱼准备延迟在 `src/engine/items/item_effects.asm` 的 `FishingInit` 内为 **20 帧**（当前用户工作区值）；后续随机等待在 `src/engine/overworld/player_animations.asm` 为 `Random & $7f + 36`，每次 36～163 帧。调节两处时需分别验证，不更改原咬钩概率。
- 连续钓鱼时不要调用完整 `LoadPlayerSpriteGraphics` 覆盖 `$8800` DFS 中文字形；当前只恢复玩家第一组图块和钓竿 OAM。冲浪钓鱼走单独结果入口，不套用陆地钓竿姿势。更改文本窗口复用须同时检查「是／否／B」及中文逐字显示。
- 三位赠竿 NPC 的自行车说明只看 `EVENT_GOT_BICYCLE`（车店交车事件），而非背包 BICYCLE；临时模拟该事件的测试补丁不得合入正式分支。HM03 重复对话的教学由维护者确认正常。新增教学是 Bank `$30` 的独立 DFS ASM 字形码文本，原 XLSX 不涉及本轮改动。
- 模式 B 正式清理：只交清理增量、`b24357fd` HEAD 全量、中文提交日志，二选一应用。禁止助手自行 RGBDS 编译或 Git Commit／Push；最终 Bank 空间、ROM/MAP/SHA 请维护者本地归档。随包旧 MAP 标记不匹配，不可作为新版余量证明。

## ROM-1.36 — 第一世代野外技能交互正式收口（2026-11-05；待维护者 Commit）

- **Git 基线**：用户 `ROM-1.35(1).zip` 的 RPP 导出记录声明 `CHS_Mod` 最近已提交 HEAD `42d7e6744b631f6adb5bf5c3167dc680a8bed297`（ROM-1.35）。导出是 HEAD 上的 Worktree；其 `current_worktree.patch` 已包含 #036 Dig／Teleport 确认修改。ROM-1.36 全量补丁从该 HEAD 累计包含 Worktree 原有修改及本轮 #031～#034 改动；增量从最终怪力对话修正版候选出发。
- **功能范围**：#036 挖洞／瞬间移动确认；#031/#032 面前树木／水面 A 键交互；#033/#034 面前巨石怪力确认、队伍菜单重复文本收口及 NPC 对话返回修复。#035 野外头槌不属于第一世代 CHS 既有 Field Move 系统，按维护者决定不移植。
- **关键实现**：背景交互主体放入 ROMX Bank `$30`；A 键只在原隐藏物／NPC／告示牌路径未处理时检查背景树／水。Cut 使用四象限判断和 `Cut2` 无白屏路径，Party `UsedCut` 保持原流程；OAM 表恢复为四组 `(tile, OAM_OBP1)`；成功文本遵循 Options 文字速度。Surf 继续调用原水岸／碰撞／地图限制。Strength 使用 Carry 返回标志避免巨石对白结束后落入 NPC 文本；Party 菜单只显示推动巨石提示。未新增 WRAM/SRAM/存档字段。
- **用户反馈**：冲浪有／无技能两类对话正常；砍树调色板最终纠错后用户反馈无问题；怪力是／否后额外 NPC 对话修复后用户反馈无问题；Dig／Teleport 确认此前有通过反馈。没有将这些具体反馈扩大为所有地图、红蓝版与 DMG/CGB 的穷尽矩阵。
- **提交方式**：无工具／审计脚本修改，模式 B 单笔 `feat(overworld)`。清理增量、HEAD 全量、中文 Commit 日志共三件；增量与全量二选一。维护者自行 Git Commit／Push。
- **静态审计**：本轮运行 14 个原有 `scripts/verify_*.py`，2 PASS／12 FAIL；11 个旧入口在历史版本白名单处失败，`verify_qol116_static.py` 的功能项通过但正式版本／Options 坐标守卫不接受 ROM-1.36。不宣称全量审计通过。没有运行 RGBDS，不生成 ROM-1.36 MAP／ROM SHA；Bank `$30` 在 ROM-1.35 随包 MAP 中为空，最终空间余量由维护者本地构建确认。

## ROM-1.35 — Fly 顶部显示与四类短菜单单按（2026-11-04；历史正式版本）

- **正式基线**：最新完整导出 `ROM-1.34(3).zip`，分支 `CHS_Mod`，记录的已提交且已 Push HEAD 为 `35581b43f8d7ae55ea91178723375ad911c66e8f`，正式游戏版本 `ROM-1.34`，导出时无未提交补丁。ZIP 不含 `.git` 对象，以上 Git 身份来自导出声明。本轮为其上的 Fly 顶部显示及四类短菜单输入修改正式收口；目标游戏版本 `ROM-1.35`，不更新游戏内测试功能版本。
- **Fly 顶部界面**：只在 Fly 目的地标题上将 `POWER_PLANT` 显示为「发电厂」；通用地图名称「无人发电厂」在 Town Map、SAVE/Continue、地点牌等仍保持原样。Fly 名称栏从原本 `x=4..18` 的 2 行宽清空改为 `x=4..10` 的两行清空，保留 DFS 汉字上/下半部残影防护，不覆盖 `x=11` 起的右上框体；移除右侧 `▲/▼` 覆盖、对应空白图块及已不使用的箭头资源加载，原始底图边框得以显示。键盘 ↑/↓/←/→ 导航能力与 13 个特殊 Fly 地点列表保持不变。
- **菜单单按输入**：START 主菜单、非战斗的 START→Pokémon Party（含 SWITCH 目标）、Bill's PC 的 12 盒选择、图鉴 DATA/CRY/AREA/QUIT 右侧菜单各在局部菜单输入调用前临时设 `hJoy7=0`，并在退出/返回后恢复。Up/Down 每次新按下一项，持续按住不自动连移；原有 A/B、菜单首尾新按键回绕、Party SELECT 换队首及会话光标记忆不变。背包、商店、图鉴主列表、Town Map/Fly 等普通长列表保留原有长按连续移动，数量选择器的独立 40/5 帧调节规则也不变。
- **用户验收**：维护者已明确回复这轮四类短菜单长按改动“测过了，没问题”。Fly 顶部白底与名字残影曾由用户截图反馈，经过专用简称、2×7 清空和去右侧箭头的递进修正；最新截图与完整多平台组合不在本轮声称已穷尽验证。此前 Fly 最近候选、13 地点浏览、解锁/落点等保持 ROM-1.34 已正式收口的实现。
- **文件/提交界线**：本轮相对 HEAD 改动 `src/engine/items/town_map.asm`、四个菜单 ASM、`src/data/game_version.asm` 及本次维护文档；不修改工具／转换器／审计脚本、地图素材、存档字段、Bank 归属。按照模式 B，单笔 `feat(menus)` 提交准备，提供最新已测试候选→文档/版本清理增量、正式 HEAD→全部源码/文档累计全量，以及中文 Conventional Commit 日志。两份补丁互斥。
- **证据边界**：按项目要求不由助手运行 RGBDS 编译／链接、不生成 ROM/MAP/SHA，也不执行 Git Commit/Push。补丁正反应用、最终文件 SHA 和本轮静态检查结果见交付日志。本轮在完整 ROM-1.35 目标源码上实际运行 14 项 `scripts/verify_*.py`：2 项 PASS（`verify_hp_damage_speed_static.py`、`verify_qol115e_static.py`），12 项 FAIL；抽查 `verify_dor117b_static.py`、`verify_dor119_static.py`、`verify_rom120d_static.py` 证实包含旧版本号断言，`verify_qol116_static.py` 的功能核验输出 PASS 但最终版本/Options 白名单失败。不将全部 12 项一概归类为版本守卫，也不宣称总审计 PASS。原 ROM-1.34 历史章节属于当时的状态记录，现由本条覆盖“待开发”描述。

## ROM-1.34 地图专项与特殊 Fly 左右选择正式清理（2026-11-04；待维护者提交）

- **正式基线**：RPP 项目 ZIP 声明 `CHS_Mod` 的最近正式 HEAD 为 `e4b6ee0cbae6fe0ab7e5f1f34b302a569bbd9bce`（ROM-1.33）。上传的 `ROM-1.34(1).zip` 为含未提交地图修改的 ROM-1.34 Worktree；其后独立追加了“城市轴进入特殊地点选最近地理候选”的已测试增量。游戏内版本保持 `ROM-1.34`，本次不进一步升级或更改测试功能版本。ZIP 不含 `.git` 对象，HEAD 来自 RPP 导出声明；本次通过补丁逆向重建和重放验证源码，不虚构 Git Commit/Push。
- **地图位置与野生栖息地**：TownMapOrder 扩为 52 项，Route 19/20 与双子岛按逻辑 selector 区分不同水域/东西入口；常青森林及 Route 19 等地图位置和底图资源已调整；图鉴地点列表去掉同一野生分组的重复记录以保留四个玛瑙水母闪点。Route 20/Seafoam 的分类仅影响 Town Map/Fly/图鉴位置，不更改实体地图连接、碰撞或实际落点。
- **Fly 与地标**：保留 ROM-1.33 的 13 个到访解锁特殊飞行地点与独立保存 bit；新增岩山隧道旁 PC 对原岩山隧道 bit5 的登记，森林与百货屋顶允许从内部使用 Fly 飞出；仍保留 Fly 飞入和 `wLastMap` 防鬼打墙规则。特殊地点左右浏览采用用户指定的顺序：华蓝洞窟→海角小屋→岩山隧道→无人发电厂→枯叶市侧地鼠洞→百货屋顶（其余特殊地点原表顺序保持）。
- **城市到特殊的最近候选修复**：只修改 `MoveSpecialFlyCursor` 的 `.fromCityAnchor` 分支，RIGHT 找 `anchor >= cityAnchor` 的最近已解锁项，LEFT 找 `anchor <= cityAnchor` 的最近已解锁项；同锚点优先，没有方向候选才按原规则回绕。特殊地点轴内部仍严格按自定义表顺序前后循环，上下城市轴、START、SELECT、落点、13 个解锁位不变。用户实测确认紫苑镇←发电厂、枯叶市→地鼠洞、玉虹市←发电厂，特殊列表正反顺序、部分解锁跳过及回绕、上下键和快捷键正常；“岩山隧道左到海角小屋／右到发电厂”是光标已处特殊轴时的正确相邻行为，不将其误判为 PC 同锚点失败。PC 同锚点城市轴测试未单独验证。
- **正式收口的 TODO**：仅登记“START 主菜单与 START→Pokémon Party 的上下长按自动连续移动改回只响应新的单按，长按不重复触发”，不改输入代码或其它菜单；Fly 顶部白色区域和 Seafoam Continue 后入口方向回退另案。常青森林/屋顶出入、最终资源视觉、红蓝和 DMG/CGB 的完整矩阵仍需维护者补测。
- **现有静态审计实际执行**：运行 `scripts/verify_*.py` 共 14 项，2 项 PASS（`verify_hp_damage_speed_static.py`、`verify_qol115e_static.py`），12 项 FAIL；抽查失败栈确认多项由早期版本号白名单/源码形态旧断言引起，但不逐项冒充均仅版本守卫失败。当前没有更新检查器或其版本守卫，不能称全量审计通过。
- **技术与交付边界**：正式清理不更改已测游戏执行路径，仅修正游戏版本注释与 TODO/维护/验收文档；无工具/审计脚本改动，采用**模式 B 单笔 `feat(map)`**。交付一个 ZIP、内含“最新已验收 ROM-1.34 开发候选→清理最终状态”的增量、“`e4b6ee0c...` HEAD→ROM-1.34 最终状态”的累计全量、中文 Conventional Commit 日志。两份补丁互斥。只做可逆应用、文件 SHA、数据结构和源码静态核对；不自行 RGBDS 编译/链接，不生成或伪造最终 ROM/MAP/SHA，不执行 Git Commit/Push。

## ROM-1.33 特殊 Fly 正式清理与维护说明（2026-11-04；待维护者提交）

- **正式基线**：第 1 个项目 ZIP 的 RPP 导出声明 `CHS_Mod` HEAD `887f43ef2f1957ce69b0f1fc67fc36bffef46fd1`（ROM-1.31，导出时干净）。ROM-1.32 及其后的 ROM-1.33 是同一轮未提交的开发/修复候选，正式目标显示 `ROM-1.33`，没有更改游戏内测试功能版本。
- **核心功能**：Fly 城市轴上下、特殊点轴左右，新增 13 个 CHS 实际存在的、必须重新到访才解锁的特殊目的地。保持原有 START/SELECT/A/B、Route 4/10 最近恢复点 START-only；双子岛两入口各有到访位，保存状态复用现有预留 padding。
- **关键修复**：不再让列表前哨兵覆盖 `wTownMapCoords` 共用的 `wBuffer[0]`；Fly 到常青森林后把 `wLastMap` 设为 Route 2，飞到玉虹百货屋顶后设为玉虹市，防止 LAST_MAP 出口鬼打墙；显示清除区和箭头范围适配长名称，屋顶地名由 `M.ROOF` 改为「百货屋顶」。同 anchor 城市可直接选择华蓝洞窟/百货屋顶，双子岛西端使用 `$FD` 虚拟选择器。
- **明确暂缓**：不自动追溯旧进度；不调整百货屋顶与玉虹市的重合地图点位；不存在的月见山广场不移植；不在收口阶段变更任何已验收飞行落点或游戏执行逻辑。
- **用户验收与限制**：用户报告七项重点测试（循环、森林/屋顶出口、同 anchor、双子岛、按键/保存、DMG/CGB 显示）及屋顶中文补测通过。缺少完整 13 点逐点录像、蓝版 MAP、最终正式 ROM/MAP/SHA；AI 遵守项目禁止自行 RGBDS 编译/链接的要求；14 个原有 `verify_*.py` 实际 2 PASS、12 FAIL（多数旧版本守卫失败），本轮定向 Fly 静态断言 PASS，不假称总审计 PASS。
- **正式交付**：本轮无工具审计脚本修改，模式 B 单笔 `feat(map)` 提交。只交付“已验收 ROM-1.33 中文候选→最终清理”增量、“ROM-1.31 正式 HEAD→ROM-1.33 最终状态”全量和中文 Commit 日志。两份补丁二选一，不叠加；Git Commit/Push 由维护者执行。

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
