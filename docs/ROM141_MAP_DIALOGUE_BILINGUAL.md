# ROM-1.41 地图脚本对白批量双语接入审计

状态：正式源码清理候选；生成器与静态回归通过。热修后红／蓝构建 MAP 与完整实机回归仍由维护者完成。

## 覆盖结果

- `_G1RB.json` 原始翻译记录：**2447**；唯一翻译标签：**2445**。
- 同代英文源码标签数：**2446**；翻译标签中可直接匹配：**2444**；缺少同代英文原文：**1**。
- 手工英文补充：**8** 条，其中 CHS 新增且不在翻译索引中的文本 **7** 条。
- `src/scripts/` 中 `text_far` 引用：**1944** 条；批量接入：**1942** 条、**1941** 个唯一文本标签。
- 两条既有 ROM-1.41A/B English pilot wrapper 引用保留原样：**2** 条；未分类引用：**0** 条；应接入但未路由：**0** 条。
- 双指针命令相对原 `text_far` 每条增加 3 bytes；本轮总增量：**5,826 bytes**。
- 英文文本数据估算：约 **164,395 bytes**，拆为 **14 个 ROMX 段**，固定放在 **$62-$6F**。估算只用于分段，不是最终 MAP 占用。
- 未被地图脚本 `text_far` 调用的翻译标签：**511**；本轮不把它们误报为已完成。

## 运行时处理与特殊文字

- 新增 `TX_BILINGUAL`（`$18`），载荷包含 CHS 与 English 两个三字节 far pointer；运行时按 `wOptions` bit 5 选择指针，再复用原 `TextCommand_FAR` 读取流程。
- ROM0 新增双语命令分派与双指针选择代码；早期 18-byte 估算属于 HF1 之前的候选，不作为正式版实际占用。随包 `MAP_20261107_080844.zip` 是 HF1 之前的 ROM-1.41C MAP，不能用于本正式源码的 ROM0 余量结论。
- 不增加 WRAM、SRAM 或存档字段。生成器将英文数据固定分配到 ROMX `$62-$6F` 共 **14** 个 section；Bank 余量必须以 HF1 与正式版号调整后的红／蓝新 MAP 为准。
- 已确认的 `#` 特殊字典扩展只在英文字符串字面量中改为普通 `POKé` 字符；本轮共处理 **579** 处。该修正依据 ROM-1.41B 用户录像确认的 `PlacePOKe` 行为。
- `<PLAYER>`、`<RIVAL>` 等动态占位符以及 `text_ram`、`text_decimal`、`text_bcd` 命令原样保留。玩家／劲敌命名界面限制为 7 字符，静态行宽检查按该上限计算；运行时变量指向的名称表／内容不因此自动变成英文。
- 为满足标准对话框 18 列宽度，生成器检查 **6,818** 行可见文本；展开后的最大行宽为 **18/18**。另对 **3** 条原版英文对白仅调整换行、不改词句：`_LavenderHouse1Text_1d8d1`, `_Route12GateUpstairsText_495c4`, `_TM39ExplanationText`。超宽未处理时拒绝生成。
- `<COLON>` 是 charmap 中定义的小型冒号字形，按普通字符保留。未知特殊 token（如 `<PC>`、`<ROCKET>`、`<TM>`、`<TRAINER>`、`<PKMN>`）不会猜测替换；含未知 token、`text_asm` 或嵌套 `text_far` 的文本会被 fail-closed 留待人工复核。
- 当前全量翻译索引中仍有 1 个 `<PKMN>` 特殊字典 token，但它不属于本轮 `src/scripts/` 地图脚本调用范围；本轮地图范围内被阻止自动接入的未知 token 文本数：**0**。
- 本轮地图脚本对白包含脚本直接调用的 NPC、地图提示、道具／教学及训练家对战前后对白；这不等于已接入战斗引擎、菜单、图鉴、名称表或全部 UI 的独立文本入口。

## 人工补充与未覆盖项

- 翻译索引中有、但同代英文源码缺少的地图脚本标签：`_OaksLabHomePCUpdatedText`。该项由 `manual_dialogue_overrides.json` 补充，不标为原版英文原文。
- 另外 7 条 CHS 分支新增硬编码文本：`FishingGuruGoodRodRepeatText`, `FishingGuruOldGoodRodRepeatTextNoBike`, `FishingGuruOldRodRepeatText`, `FishingGuruSuperRodRepeatText`, `FishingGuruSuperRodRepeatTextNoBike`, `FlyHouseExplanationWithSpecialFlyTips`, `SurfFishingRepeatText`。它们的英文稿是项目人工补充，不是上游原文，需维护者／用户检查措辞与行宽。
- `text_ram` 等动态变量指向的物品、技能、宝可梦名称仍取决于现有名称系统；本轮不改名称表语言兼容逻辑。
- 其余 511 个未被地图脚本 `text_far` 调用的翻译标签，以及战斗引擎、菜单、图鉴、名称和其他 UI 的独立入口，留给后续阶段。

## 构建与验证边界

- `scripts/prepare_build.py` 在 XLSX 导入后生成 `buildRB/data/english_text/generated_dialogue.asm`，并在 `buildRB/scripts/` 中重写可路由的 `text_far`。`src/scripts/` 和 XLSX 不被生成器改写。
- 单元测试、静态源检查与构建前置生成检查不等于 RGBDS 编译／链接或手机实机验收。
- 本轮未运行 RGBDS／`rgblink`，未生成正式 ROM、HF1 后 MAP 或 ROM SHA-256；未执行 Git Commit／Push。用户已提供 HF1 后的 NPC 实测视频，但没有提供 HF1 后红／蓝 MAP 与 ROM SHA。最终 Bank 余量及完整红蓝构建仍待维护者确认。
