# ROM-1.41C 地图对白 Bank 空间静态投影

状态：历史静态投影。仅基于随包 ROM-1.41B `buildRB/pokered.map`；早于 ROM-1.41C-HF1 和正式 ROM-1.41 清理。不得用于 HF1／ROM-1.41 的最终 Bank 余量结论。

## 地图脚本 Bank 增量

`text_far` 原命令为 1 byte opcode + 3 byte far pointer；`text_bilingual` 为 1 byte opcode + 两个 3 byte far pointer，因此每条引用精确增加 3 bytes。本轮 1,942 条引用共增加 5,826 bytes。按 `src/maps.asm` 将脚本文件归入 Maps section，再按 ROM-1.41B MAP 聚合到实际 ROMX Bank：

| ROMX Bank | Maps sections | 引用数 | ROM-1.41B 原余量 | 本轮增加 | 静态投影余量 |
|---:|---|---:|---:|---:|---:|
| `$06` | Maps 2 | 184 | 5,563 | 552 | 5,011 |
| `$07` | Maps 4 | 150 | 2,973 | 450 | 2,523 |
| `$11` | Maps 5, Maps 6 | 138 | 3,811 | 414 | 3,397 |
| `$12` | Maps 8 | 223 | 7,292 | 669 | 6,623 |
| `$13` | Maps 9 | 2 | 92 | 6 | **86** |
| `$14` | Maps 10 | 186 | 5,604 | 558 | 5,046 |
| `$15` | Maps 12 | 270 | 5,493 | 810 | 4,683 |
| `$16` | Maps 14 | 240 | 6,735 | 720 | 6,015 |
| `$17` | Maps 16 | 181 | 8,444 | 543 | 7,901 |
| `$18` | Maps 17, Maps 18 | 189 | 6,876 | 567 | 6,309 |
| `$1D` | Maps 20, Maps 21 | 179 | 5,979 | 537 | 5,442 |
| **合计** | **11 个原地图 Bank** | **1,942** | — | **5,826** | — |

最紧张的是 ROMX Bank `$13`：旧 MAP 余量 92 bytes，本轮 2 条引用增加 6 bytes，静态投影仍余 86 bytes。所有受影响地图 Bank 的投影均为正数。

## 英文数据 Bank 规划

- ROM-1.41B MAP 显示 ROMX `$62-$7F` 共 30 个未使用物理 Bank。
- 生成器按每段估算不超过 `$3000` bytes，将英文数据拆成 14 个固定 ROMX section，放在 `$62-$6F`；每段至少保留约 4 KiB 的预算余量。
- 生成器统计英文数据估算约 164,395 bytes。该数值用于分段，不是 RGBDS 实际链接尺寸。
- 规划后仍有 `$70-$7F` 共 16 个空 Bank。最终分配、section 实际大小和 Bank 余量必须以维护者在 HF1＋正式 ROM-1.41 源码上新生成的红／蓝 MAP 为准。

## ROM0 与 WRAM 边界

- 新命令在 ROM0 增加分派及选择代码，按 Game Boy 指令编码静态计算为 18 bytes。
- ROM-1.41B MAP 的 ROM0 原余量为 463 bytes；简单扣除 18 bytes 后的 445 bytes 仅为 HF1 前的旧候选预算参考。HF1 增加了指针消费逻辑，且正式版号从 9 字符变为 8 字符，不能把 445 bytes 当作最终余量。
- 不新增 WRAM、SRAM、存档字段或名称缓存；WRAM0 旧 MAP 的 191 bytes 余量不因本轮代码改变。

## 重要限制

此表只估算脚本命令从 4 bytes 增至 7 bytes 的确定差值，并将新英文数据放入旧 MAP 中未使用的高位 ROMX Bank。它没有执行 RGBDS 编译／链接，不能发现实际宏展开尺寸、section 放置冲突或最终 ROM header／Bank 限制，也不能代替 HF1／正式 ROM-1.41 新 MAP。维护者必须用正式红／蓝构建重新检查 ROM0、所有 Maps Bank、`$62-$6F` 英文数据段和 ROM 总容量。
