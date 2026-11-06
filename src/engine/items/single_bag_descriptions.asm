; START Bag single-list short descriptions (CHS adaptation of RPP #085).
; Bank $30. Uses the existing wBagItems list; no Pocket/SlotMap or save change.
; Called from HOME only when wStartBagDescriptionActive != 0.
UpdateSingleBagDescription::
    ld a, [wCurrentMenuItem]
    ld b, a
    ld a, [wListScrollOffset]
    add b
    ld b, a
    ld a, [wNumBagItems]
    cp b
    jr z, .cancel
    jr c, .cancel
    ld a, b
    add a
    ld e, a
    ld d, 0
    ld hl, wBagItems
    add hl, de
    ld a, [hl]
    jr .selected
.cancel
    ld a, $ff
.selected
    ld b, a
    ld a, [wStartBagDescriptionLastID]
    cp b
    ret z
    ld a, b
    ld [wStartBagDescriptionLastID], a
    ; New DFS glyphs can overwrite saved START text; choose safe no-white rebuild.
    ld a, 1
    ld [wItemListRedrawDirty], a
    ; Protect the tilemap while text and glyph graphics are updated.
    ldh a, [hAutoBGTransferEnabled]
    push af
    xor a
    ldh [hAutoBGTransferEnabled], a
    ld a, [wStartBagDescriptionBoxDrawn]
    and a
    jr nz, .boxDrawn
    ld a, MESSAGE_BOX
    ld [wTextBoxID], a
    call DisplayTextBoxID
    ld a, 1
    ld [wStartBagDescriptionBoxDrawn], a
.boxDrawn
    ; DFS Chinese double-height glyphs extend one tile ABOVE their anchor.
    ; The box interior is rows 13..16: draw anchors at 14/16, not 13/15.
    ; Clear both upper/lower rows on every selection, including CANCEL.
    hlcoord 1, 13
    lb bc, 4, 18
    call ClearScreenArea
    ld a, [wStartBagDescriptionLastID]
    cp $ff
    jr z, .finish
    cp HM01
    jr nc, .maybeMachine
    cp NUM_ITEMS + 1
    jr nc, .finish ; never index past the descriptions for 01..53
    jr .ordinary
.maybeMachine
    cp TM01 + NUM_TMS
    jr nc, .finish
    call .machine
    jr .finish
.ordinary
    dec a
    add a
    ld e, a
    ld d, 0
    ld hl, SingleBagItemDescriptionPointers
    add hl, de
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld d, h
    ld e, l
    hlcoord 1, 14
    call PlaceString
.finish
    pop af
    ldh [hAutoBGTransferEnabled], a
    ret
.machine
    ; TM/HM machine descriptions use current TMToMove/MoveNames data.
    ; The two baselines 14/16 keep the two double-height text rows inside the box.
    push af
    ld de, SingleBagMachineDescription
    hlcoord 1, 14
    call PlaceString
    pop af
    cp TM01
    jr nc, .tm
    sub HM01
    add NUM_TMS + 1
    jr .number
.tm
    sub TM01 - 1
.number
    ld [wd11e], a
    predef TMToMove
    call GetMoveName
    hlcoord 1, 16
    call PlaceString
    ret

SingleBagItemDescriptionPointers:
    dw SingleBagItemDescription01
    dw SingleBagItemDescription02
    dw SingleBagItemDescription03
    dw SingleBagItemDescription04
    dw SingleBagItemDescription05
    dw SingleBagItemDescription06
    dw SingleBagItemDescription07
    dw SingleBagItemDescription08
    dw SingleBagItemDescription09
    dw SingleBagItemDescription10
    dw SingleBagItemDescription11
    dw SingleBagItemDescription12
    dw SingleBagItemDescription13
    dw SingleBagItemDescription14
    dw SingleBagItemDescription15
    dw SingleBagItemDescription16
    dw SingleBagItemDescription17
    dw SingleBagItemDescription18
    dw SingleBagItemDescription19
    dw SingleBagItemDescription20
    dw SingleBagItemDescription21
    dw SingleBagItemDescription22
    dw SingleBagItemDescription23
    dw SingleBagItemDescription24
    dw SingleBagItemDescription25
    dw SingleBagItemDescription26
    dw SingleBagItemDescription27
    dw SingleBagItemDescription28
    dw SingleBagItemDescription29
    dw SingleBagItemDescription30
    dw SingleBagItemDescription31
    dw SingleBagItemDescription32
    dw SingleBagItemDescription33
    dw SingleBagItemDescription34
    dw SingleBagItemDescription35
    dw SingleBagItemDescription36
    dw SingleBagItemDescription37
    dw SingleBagItemDescription38
    dw SingleBagItemDescription39
    dw SingleBagItemDescription40
    dw SingleBagItemDescription41
    dw SingleBagItemDescription42
    dw SingleBagItemDescription43
    dw SingleBagItemDescription44
    dw SingleBagItemDescription45
    dw SingleBagItemDescription46
    dw SingleBagItemDescription47
    dw SingleBagItemDescription48
    dw SingleBagItemDescription49
    dw SingleBagItemDescription50
    dw SingleBagItemDescription51
    dw SingleBagItemDescription52
    dw SingleBagItemDescription53
    dw SingleBagItemDescription54
    dw SingleBagItemDescription55
    dw SingleBagItemDescription56
    dw SingleBagItemDescription57
    dw SingleBagItemDescription58
    dw SingleBagItemDescription59
    dw SingleBagItemDescription60
    dw SingleBagItemDescription61
    dw SingleBagItemDescription62
    dw SingleBagItemDescription63
    dw SingleBagItemDescription64
    dw SingleBagItemDescription65
    dw SingleBagItemDescription66
    dw SingleBagItemDescription67
    dw SingleBagItemDescription68
    dw SingleBagItemDescription69
    dw SingleBagItemDescription70
    dw SingleBagItemDescription71
    dw SingleBagItemDescription72
    dw SingleBagItemDescription73
    dw SingleBagItemDescription74
    dw SingleBagItemDescription75
    dw SingleBagItemDescription76
    dw SingleBagItemDescription77
    dw SingleBagItemDescription78
    dw SingleBagItemDescription79
    dw SingleBagItemDescription80
    dw SingleBagItemDescription81
    dw SingleBagItemDescription82
    dw SingleBagItemDescription83

SingleBagMachineDescription:
    db $0b, $29, $06, $81, $0f, $d2, $06, $f8, $18, $68, $0f, $b5 ; 可传授的招式
    db CHARVAL("@")

SingleBagItemDescription01:
    db $05, $76, $07, $43, $05, $b2, $09, $b3 ; 必定捕获
    db CHARVAL("<NEXT>")
    db $0e, $ec, $09, $1b, $05, $2e, $0b, $29, $0c, $da ; 任何宝可梦
    db CHARVAL("@")

SingleBagItemDescription02:
    db $05, $b2, $09, $b3, $0c, $78, $08, $86, $08, $69 ; 捕获率更高
    db CHARVAL("<NEXT>")
    db $06, $f8, $0a, $a5, $0c, $23, $0e, $b2 ; 的精灵球
    db CHARVAL("@")

SingleBagItemDescription03:
    db $08, $86, $13, $20, $05, $b2, $09, $b3 ; 更易捕获
    db CHARVAL("<NEXT>")
    db $12, $f2, $0f, $94, $05, $2e, $0b, $29, $0c, $da ; 野生宝可梦
    db CHARVAL("@")

SingleBagItemDescription04:
    db $13, $81, $13, $98, $05, $b2, $09, $b3 ; 用于捕获
    db CHARVAL("<NEXT>")
    db $12, $f2, $0f, $94, $05, $2e, $0b, $29, $0c, $da ; 野生宝可梦
    db CHARVAL("@")

SingleBagItemDescription05:
    db $05, $e5, $0b, $10, $08, $c0, $07, $6c ; 查看关都
    db CHARVAL("<NEXT>")
    db $07, $10, $0e, $b8, $07, $10, $10, $ec ; 地区地图
    db CHARVAL("@")

SingleBagItemDescription06:
    db $0e, $3b, $06, $13, $06, $6e, $12, $41 ; 骑车出行
    db CHARVAL("<NEXT>")
    db $13, $0c, $07, $4a, $08, $86, $0b, $62 ; 移动更快
    db CHARVAL("@")

SingleBagItemDescription07:
    db $0a, $c3, $05, $0c, $06, $48, $0b, $9f, $05, $0b ; 旧版冲浪板
    db CHARVAL("<NEXT>")
    db $11, $8a, $07, $b6, $0f, $b1, $13, $81 ; 无法使用
    db CHARVAL("@")

SingleBagItemDescription08:
    db $1d, $8d, $0c, $0a, $07, $10, $06, $ce ; 狩猎地带
    db CHARVAL("<NEXT>")
    db $18, $fc, $13, $81, $0a, $a5, $0c, $23, $0e, $b2 ; 专用精灵球
    db CHARVAL("@")

SingleBagItemDescription09:
    db $09, $e7, $0c, $6a, $13, $b4, $0a, $23, $06, $f8 ; 记录遇见的
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $19, $26, $0c, $05 ; 宝可梦资料
    db CHARVAL("@")

SingleBagItemDescription10:
    db $0d, $64, $0f, $b1, $05, $bb, $07, $e4 ; 能使部分
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $0a, $94, $09, $71 ; 宝可梦进化
    db CHARVAL("@")

SingleBagItemDescription11:
    db $0a, $7e, $06, $75, $05, $2e, $0b, $29, $0c, $da ; 解除宝可梦
    db CHARVAL("<NEXT>")
    db $06, $f8, $18, $c6, $07, $6e, $19, $0c, $10, $7e ; 的中毒状态
    db CHARVAL("@")

SingleBagItemDescription12:
    db $0a, $7e, $06, $75, $05, $2e, $0b, $29, $0c, $da ; 解除宝可梦
    db CHARVAL("<NEXT>")
    db $06, $f8, $19, $21, $0f, $65, $19, $0c, $10, $7e ; 的灼伤状态
    db CHARVAL("@")

SingleBagItemDescription13:
    db $0a, $7e, $06, $75, $05, $2e, $0b, $29, $0c, $da ; 解除宝可梦
    db CHARVAL("<NEXT>")
    db $06, $f8, $05, $97, $07, $63, $19, $0c, $10, $7e ; 的冰冻状态
    db CHARVAL("@")

SingleBagItemDescription14:
    db $09, $7f, $12, $42, $06, $23, $10, $09, $06, $f8 ; 唤醒沉睡的
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da ; 宝可梦
    db CHARVAL("@")

SingleBagItemDescription15:
    db $0a, $7e, $06, $75, $05, $2e, $0b, $29, $0c, $da ; 解除宝可梦
    db CHARVAL("<NEXT>")
    db $06, $f8, $0c, $97, $05, $72, $19, $0c, $10, $7e ; 的麻痹状态
    db CHARVAL("@")

SingleBagItemDescription16:
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $10, $b7, $0b, $d8 ; 恢复全部体力
    db CHARVAL("<NEXT>")
    db $05, $9e, $18, $c4, $13, $b8, $13, $36, $06, $01 ; 并治愈异常
    db CHARVAL("@")

SingleBagItemDescription17:
    db $11, $21, $0e, $c9, $09, $98, $08, $28 ; 完全恢复
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $10, $b7, $0b, $d8 ; 宝可梦体力
    db CHARVAL("@")

SingleBagItemDescription18:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $07, $ae, $04, $fb, $07, $1e ; 二百点
    db CHARVAL("@")

SingleBagItemDescription19:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $11, $91, $0f, $a6, $07, $1e ; 五十点
    db CHARVAL("@")

SingleBagItemDescription20:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $07, $ae, $0f, $a6, $07, $1e ; 二十点
    db CHARVAL("@")

SingleBagItemDescription21:
    db $1d, $8d, $0c, $0a, $07, $10, $06, $ce ; 狩猎地带
    db CHARVAL("<NEXT>")
    db $13, $81, $0b, $88, $10, $e6, $07, $d3, $13, $93, $07, $ac ; 用来投放诱饵
    db CHARVAL("@")

SingleBagItemDescription22:
    db $1d, $8d, $0c, $0a, $07, $10, $06, $ce ; 狩猎地带
    db CHARVAL("<NEXT>")
    db $13, $81, $0b, $88, $10, $e6, $18, $b6, $0f, $a7, $10, $e7 ; 用来投掷石头
    db CHARVAL("@")

SingleBagItemDescription23:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription24:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription25:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription26:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription27:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription28:
    db $06, $f4, $08, $c5, $09, $97, $18, $45 ; 道馆徽章
    db CHARVAL("<NEXT>")
    db $05, $b7, $0f, $bf, $0e, $20, $10, $d8, $06, $f4, $0a, $d9 ; 不是普通道具
    db CHARVAL("@")

SingleBagItemDescription29:
    db $06, $a9, $07, $64, $12, $8c, $10, $a5, $06, $6e ; 从洞穴逃出
    db CHARVAL("<NEXT>")
    db $09, $9a, $06, $f1, $0f, $0d, $0b, $3a, $06, $7c ; 回到入口处
    db CHARVAL("@")

SingleBagItemDescription30:
    db $13, $01, $07, $43, $05, $b9, $0f, $f5, $0d, $62 ; 一定步数内
    db CHARVAL("<NEXT>")
    db $0f, $1a, $12, $0d, $05, $2e, $0b, $29, $0c, $da, $05, $b7, $0b, $88 ; 弱小宝可梦不来
    db CHARVAL("@")

SingleBagItemDescription31:
    db $08, $ad, $0b, $a3, $06, $f8, $28, $04, $1f, $f0 ; 古老的琥珀
    db CHARVAL("<NEXT>")
    db $09, $b4, $05, $d4, $13, $8e, $09, $71, $0f, $a7 ; 或藏有化石
    db CHARVAL("@")

SingleBagItemDescription32:
    db $0d, $64, $0f, $b1, $05, $bb, $07, $e4 ; 能使部分
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $0a, $94, $09, $71 ; 宝可梦进化
    db CHARVAL("@")

SingleBagItemDescription33:
    db $0d, $64, $0f, $b1, $05, $bb, $07, $e4 ; 能使部分
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $0a, $94, $09, $71 ; 宝可梦进化
    db CHARVAL("@")

SingleBagItemDescription34:
    db $0d, $64, $0f, $b1, $05, $bb, $07, $e4 ; 能使部分
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $0a, $94, $09, $71 ; 宝可梦进化
    db CHARVAL("@")

SingleBagItemDescription35:
    db $18, $19, $09, $f3, $05, $2e, $0b, $29, $0c, $da ; 增加宝可梦
    db CHARVAL("<NEXT>")
    db $10, $b7, $0b, $d8, $06, $f8, $09, $bb, $06, $77, $18, $ab ; 体力的基础值
    db CHARVAL("@")

SingleBagItemDescription36:
    db $18, $19, $09, $f3, $05, $2e, $0b, $29, $0c, $da ; 增加宝可梦
    db CHARVAL("<NEXT>")
    db $08, $8d, $09, $b9, $06, $f8, $09, $bb, $06, $77, $18, $ab ; 攻击的基础值
    db CHARVAL("@")

SingleBagItemDescription37:
    db $18, $19, $09, $f3, $05, $2e, $0b, $29, $0c, $da ; 增加宝可梦
    db CHARVAL("<NEXT>")
    db $07, $ce, $13, $b7, $06, $f8, $09, $bb, $06, $77, $18, $ab ; 防御的基础值
    db CHARVAL("@")

SingleBagItemDescription38:
    db $18, $19, $09, $f3, $05, $2e, $0b, $29, $0c, $da ; 增加宝可梦
    db CHARVAL("<NEXT>")
    db $10, $37, $07, $78, $06, $f8, $09, $bb, $06, $77, $18, $ab ; 速度的基础值
    db CHARVAL("@")

SingleBagItemDescription39:
    db $18, $19, $09, $f3, $05, $2e, $0b, $29, $0c, $da ; 增加宝可梦
    db CHARVAL("<NEXT>")
    db $10, $aa, $0f, $da, $06, $f8, $09, $bb, $06, $77, $18, $ab ; 特殊的基础值
    db CHARVAL("@")

SingleBagItemDescription40:
    db $0e, $e1, $05, $2e, $0b, $29, $0c, $da ; 让宝可梦
    db CHARVAL("<NEXT>")
    db $06, $fc, $09, $d6, $10, $b3, $08, $69, $13, $01, $09, $d6 ; 等级提高一级
    db CHARVAL("@")

SingleBagItemDescription41:
    db $08, $ad, $06, $d0, $05, $2e, $0b, $29, $0c, $da ; 古代宝可梦
    db CHARVAL("<NEXT>")
    db $0c, $2e, $11, $cc, $06, $f8, $09, $71, $0f, $a7 ; 留下的化石
    db CHARVAL("@")

SingleBagItemDescription42:
    db $08, $ad, $06, $d0, $05, $2e, $0b, $29, $0c, $da ; 古代宝可梦
    db CHARVAL("<NEXT>")
    db $0c, $2e, $11, $cc, $06, $f8, $09, $71, $0f, $a7 ; 留下的化石
    db CHARVAL("@")

SingleBagItemDescription43:
    db $06, $c8, $0b, $06, $10, $aa, $0f, $da, $0c, $d1, $10, $6c ; 打开特殊门锁
    db CHARVAL("<NEXT>")
    db $10, $6d, $12, $6e, $06, $f8, $13, $db, $06, $39 ; 所需的钥匙
    db CHARVAL("@")

SingleBagItemDescription44:
    db $11, $8a, $07, $b6, $0f, $b1, $13, $81, $06, $f8 ; 无法使用的
    db CHARVAL("<NEXT>")
    db $11, $60, $18, $a0, $06, $f4, $0a, $d9 ; 未知道具
    db CHARVAL("@")

SingleBagItemDescription45:
    db $07, $82, $09, $7d, $19, $30, $12, $41, $06, $13 ; 兑换自行车
    db CHARVAL("<NEXT>")
    db $10, $6d, $12, $6e, $06, $f8, $07, $82, $09, $7d, $0e, $cd ; 所需的兑换券
    db CHARVAL("@")

SingleBagItemDescription46:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $0f, $97 ; 战斗时提升
    db CHARVAL("<NEXT>")
    db $18, $68, $0f, $b5, $0d, $0c, $18, $c6, $0c, $78 ; 招式命中率
    db CHARVAL("@")

SingleBagItemDescription47:
    db $0d, $64, $0f, $b1, $05, $bb, $07, $e4 ; 能使部分
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $0a, $94, $09, $71 ; 宝可梦进化
    db CHARVAL("@")

SingleBagItemDescription48:
    db $0b, $06, $0e, $41, $11, $ad, $0c, $61, $08, $04 ; 开启希鲁夫
    db CHARVAL("<NEXT>")
    db $08, $93, $10, $1b, $0c, $d1, $0a, $97 ; 公司门禁
    db CHARVAL("@")

SingleBagItemDescription49:
    db $0b, $29, $13, $1d, $0c, $a2, $06, $f7 ; 可以卖得
    db CHARVAL("<NEXT>")
    db $08, $69, $09, $fb, $06, $f8, $0a, $8c, $18, $df ; 高价的金珠
    db CHARVAL("@")

SingleBagItemDescription50:
    db $10, $b3, $0f, $97, $05, $2e, $0b, $29, $0c, $da ; 提升宝可梦
    db CHARVAL("<NEXT>")
    db $18, $68, $0f, $b5, $19, $60, $06, $c9, $06, $a4, $0f, $f5 ; 招式最大次数
    db CHARVAL("@")

SingleBagItemDescription51:
    db $0e, $e1, $07, $84, $0f, $ce, $0b, $bf, $0b, $06 ; 让对手离开
    db CHARVAL("<NEXT>")
    db $18, $40, $07, $67, $06, $f8, $11, $1d, $0d, $a2 ; 战斗的玩偶
    db CHARVAL("@")

SingleBagItemDescription52:
    db $0a, $7e, $06, $75, $0e, $c9, $05, $bb ; 解除全部
    db CHARVAL("<NEXT>")
    db $13, $36, $06, $01, $19, $0c, $10, $7e ; 异常状态
    db CHARVAL("@")

SingleBagItemDescription53:
    db $0e, $e1, $09, $aa, $19, $9a, $05, $2e, $0b, $29, $0c, $da ; 让昏厥宝可梦
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $05, $bb, $07, $e4, $10, $b7, $0b, $d8 ; 恢复部分体力
    db CHARVAL("@")

SingleBagItemDescription54:
    db $0e, $e1, $09, $aa, $19, $9a, $05, $2e, $0b, $29, $0c, $da ; 让昏厥宝可梦
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $10, $b7, $0b, $d8 ; 恢复全部体力
    db CHARVAL("@")

SingleBagItemDescription55:
    db $18, $40, $07, $67, $18, $c6, $07, $ce, $18, $af ; 战斗中防止
    db CHARVAL("<NEXT>")
    db $0d, $64, $0b, $d8, $05, $44, $0a, $3b, $07, $05 ; 能力被降低
    db CHARVAL("@")

SingleBagItemDescription56:
    db $13, $01, $07, $43, $05, $b9, $0f, $f5, $0d, $62 ; 一定步数内
    db CHARVAL("<NEXT>")
    db $0f, $1a, $12, $0d, $05, $2e, $0b, $29, $0c, $da, $05, $b7, $0b, $88 ; 弱小宝可梦不来
    db CHARVAL("@")

SingleBagItemDescription57:
    db $08, $86, $06, $02, $0f, $a9, $0a, $08, $0d, $62 ; 更长时间内
    db CHARVAL("<NEXT>")
    db $0f, $1a, $12, $0d, $05, $2e, $0b, $29, $0c, $da, $05, $b7, $0b, $88 ; 弱小宝可梦不来
    db CHARVAL("@")

SingleBagItemDescription58:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $08, $69 ; 战斗时提高
    db CHARVAL("<NEXT>")
    db $12, $ec, $08, $ec, $0d, $0c, $18, $c6, $0c, $78 ; 要害命中率
    db CHARVAL("@")

SingleBagItemDescription59:
    db $13, $8c, $11, $c1, $06, $d0, $05, $70 ; 游戏代币
    db CHARVAL("<NEXT>")
    db $13, $81, $13, $98, $13, $8c, $0b, $aa, $05, $fb ; 用于游乐场
    db CHARVAL("@")

SingleBagItemDescription60:
    db $0f, $6e, $11, $38, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 稍微恢复体力
    db CHARVAL("<NEXT>")
    db $0b, $29, $19, $69, $13, $46, $0c, $05 ; 可作饮料
    db CHARVAL("@")

SingleBagItemDescription61:
    db $09, $98, $08, $28, $08, $86, $07, $90, $10, $b7, $0b, $d8 ; 恢复更多体力
    db CHARVAL("<NEXT>")
    db $0b, $29, $19, $69, $13, $46, $0c, $05 ; 可作饮料
    db CHARVAL("@")

SingleBagItemDescription62:
    db $09, $98, $08, $28, $06, $c9, $0b, $f1, $10, $b7, $0b, $d8 ; 恢复大量体力
    db CHARVAL("<NEXT>")
    db $0b, $29, $19, $69, $13, $46, $0c, $05 ; 可作饮料
    db CHARVAL("@")

SingleBagItemDescription63:
    db $0f, $9d, $04, $d4, $0d, $91, $09, $0f ; 圣安奴号
    db CHARVAL("<NEXT>")
    db $06, $fb, $06, $82, $0e, $06, $18, $9a ; 登船凭证
    db CHARVAL("@")

SingleBagItemDescription64:
    db $0a, $42, $09, $7b, $08, $82, $13, $cc, $06, $02 ; 交还给园长
    db CHARVAL("<NEXT>")
    db $06, $f8, $18, $ce, $12, $ec, $11, $9b, $0d, $fb ; 的重要物品
    db CHARVAL("@")

SingleBagItemDescription65:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $08, $69 ; 战斗时提高
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $08, $8d, $09, $b9 ; 宝可梦攻击
    db CHARVAL("@")

SingleBagItemDescription66:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $08, $69 ; 战斗时提高
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $07, $ce, $13, $b7 ; 宝可梦防御
    db CHARVAL("@")

SingleBagItemDescription67:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $08, $69 ; 战斗时提高
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $10, $37, $07, $78 ; 宝可梦速度
    db CHARVAL("@")

SingleBagItemDescription68:
    db $18, $40, $07, $67, $0f, $a9, $10, $b3, $08, $69 ; 战斗时提高
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $10, $aa, $0f, $da ; 宝可梦特殊
    db CHARVAL("@")

SingleBagItemDescription69:
    db $0f, $cd, $09, $cf, $05, $9e, $06, $bc, $07, $d3 ; 收集并存放
    db CHARVAL("<NEXT>")
    db $13, $8c, $11, $c1, $06, $d0, $05, $70 ; 游戏代币
    db CHARVAL("@")

SingleBagItemDescription70:
    db $10, $2b, $11, $31, $06, $c9, $0d, $30, $05, $a5, $0f, $b7 ; 送往大木博士
    db CHARVAL("<NEXT>")
    db $06, $f8, $05, $26, $08, $e4 ; 的包裹
    db CHARVAL("@")

SingleBagItemDescription71:
    db $05, $e5, $18, $6a, $08, $31, $0a, $98, $06, $f8 ; 查找附近的
    db CHARVAL("<NEXT>")
    db $13, $49, $05, $d4, $06, $f4, $0a, $d9 ; 隐藏道具
    db CHARVAL("@")

SingleBagItemDescription72:
    db $0b, $10, $0e, $a5, $13, $82, $0c, $23 ; 看清幽灵
    db CHARVAL("<NEXT>")
    db $18, $7e, $0f, $ad, $0c, $f2, $0c, $be ; 真实面貌
    db CHARVAL("@")

SingleBagItemDescription73:
    db $06, $8b, $11, $f6, $07, $09, $0f, $93 ; 吹响笛声
    db CHARVAL("<NEXT>")
    db $09, $7f, $12, $42, $05, $2e, $0b, $29, $0c, $da ; 唤醒宝可梦
    db CHARVAL("@")

SingleBagItemDescription74:
    db $0b, $38, $18, $bc, $07, $23, $10, $af ; 控制电梯
    db CHARVAL("<NEXT>")
    db $10, $6d, $12, $6e, $06, $f8, $13, $db, $06, $39 ; 所需的钥匙
    db CHARVAL("@")

SingleBagItemDescription75:
    db $0e, $e1, $0e, $c9, $07, $83, $07, $e4, $11, $f7 ; 让全队分享
    db CHARVAL("<NEXT>")
    db $18, $40, $07, $67, $0a, $a7, $12, $cd ; 战斗经验
    db CHARVAL("@")

SingleBagItemDescription76:
    db $19, $60, $09, $bb, $06, $77, $06, $f8 ; 最基础的
    db CHARVAL("<NEXT>")
    db $07, $32, $13, $a1, $13, $81, $07, $32, $08, $42 ; 钓鱼用钓竿
    db CHARVAL("@")

SingleBagItemDescription77:
    db $0b, $29, $07, $32, $06, $f1, $08, $86, $0e, $7f ; 可钓到更强
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $06, $f8, $07, $32, $08, $42 ; 宝可梦的钓竿
    db CHARVAL("@")

SingleBagItemDescription78:
    db $0d, $64, $07, $32, $06, $f1, $11, $ab, $13, $8e ; 能钓到稀有
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da, $06, $f8, $07, $32, $08, $42 ; 宝可梦的钓竿
    db CHARVAL("@")

SingleBagItemDescription79:
    db $10, $b3, $0f, $97, $05, $2e, $0b, $29, $0c, $da ; 提升宝可梦
    db CHARVAL("<NEXT>")
    db $18, $68, $0f, $b5, $19, $60, $06, $c9, $06, $a4, $0f, $f5 ; 招式最大次数
    db CHARVAL("@")

SingleBagItemDescription80:
    db $09, $98, $08, $28, $13, $01, $08, $80, $18, $68, $0f, $b5 ; 恢复一个招式
    db CHARVAL("<NEXT>")
    db $06, $f8, $05, $bb, $07, $e4, $06, $a4, $0f, $f5 ; 的部分次数
    db CHARVAL("@")

SingleBagItemDescription81:
    db $09, $98, $08, $28, $13, $01, $08, $80, $18, $68, $0f, $b5 ; 恢复一个招式
    db CHARVAL("<NEXT>")
    db $06, $f8, $0e, $c9, $05, $bb, $06, $a4, $0f, $f5 ; 的全部次数
    db CHARVAL("@")

SingleBagItemDescription82:
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $18, $68, $0f, $b5 ; 恢复全部招式
    db CHARVAL("<NEXT>")
    db $06, $f8, $05, $bb, $07, $e4, $06, $a4, $0f, $f5 ; 的部分次数
    db CHARVAL("@")

SingleBagItemDescription83:
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $18, $68, $0f, $b5 ; 恢复全部招式
    db CHARVAL("<NEXT>")
    db $06, $f8, $0e, $c9, $05, $bb, $06, $a4, $0f, $f5 ; 的全部次数
    db CHARVAL("@")
