; Shared single-list short descriptions (CHS adaptation of RPP #085).
; START Bag, Player's PC and Mart BUY/SELL reuse the same translated text.
; Only obtainable Bag items were refined: badge/SAFARI_BALL/POKEDEX/COIN and
; unused IDs keep their original placeholders. No new Pocket or save layout.
; The active inventory comes from wListPointer and wListCount.
UpdateSingleBagDescription::
    ld a, [wCurrentMenuItem]
    ld b, a
    ld a, [wListScrollOffset]
    add b
    ld b, a
    ; wListCount and wListPointer belong to the current list: Bag or PC.
    ; Both inventories store count followed by (item ID, quantity) pairs.
    ld a, [wListCount]
    cp b
    jr z, .cancel
    jr c, .cancel
    ; Mart BUY has one item ID byte per entry (wItemList).
    ; Bag, Player PC and Mart SELL use pairs (ID, quantity).
    ld a, [wListMenuID]
    cp PRICEDITEMLISTMENU
    ld a, b
    jr z, .entryOffsetReady
    add a
.entryOffsetReady
    ld e, a
    ld d, 0
    ld a, [wListPointer]
    ld l, a
    ld a, [wListPointer + 1]
    ld h, a
    inc hl
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

; Player PC and Mart lists share the conventional list-menu entry point.
; The Mart uses an explicit parent-session marker in HOME. Bank $01 caller code
; remains size-neutral; the existing PlayerPC sprite update moves after reveal.
; Bill's PC and battle are gated.
TryStartPCItemDescriptions::
    ; START Bag owns its own OAM save on the caller stack.
    ld a, [wStartBagDescriptionActive]
    and a
    ret nz
    ; $80 = fresh Mart parent; $82 = Mart parent after a list returned.
    ; $03 = Player PC after a list returned. Pending states keep the original
    ; saved byte instead of overwriting it with the temporarily disabled value.
    ld a, [wPCItemDescriptionSessionActive]
    cp $80
    jr z, .martParentFresh
    cp $82
    jr z, .martParentPending
    cp 3
    jr z, .pcParentPending
    xor a
    ld [wPCItemDescriptionSessionActive], a ; fresh non-Mart list
    ld b, 0 ; save the current OAM enable byte
    jr .checkPlayerPC
.pcParentPending
    ld b, 1 ; preserve the original OAM enable byte across PC list loops
.checkPlayerPC
    ld a, [wFlags_0xcd60]
    bit 5, a ; PlayerPCMenu has the player-PC parent menu open
    ret z
    ld a, [wListMenuID]
    cp ITEMLISTMENU
    ret nz
    ; Only the real player Bag and storage inventories, never a vendor list.
    ld a, [wListPointer]
    cp LOW(wNumBagItems)
    jr nz, .checkBox
    ld a, [wListPointer + 1]
    cp HIGH(wNumBagItems)
    jr z, .enable
.checkBox
    ld a, [wListPointer]
    cp LOW(wNumBoxItems)
    ret nz
    ld a, [wListPointer + 1]
    cp HIGH(wNumBoxItems)
    ret nz
.enable
    ld a, 1 ; Player PC item-list session
    ld [wPCItemDescriptionSessionActive], a
    jr .enablePanel
.martParentFresh
    ld b, 0 ; save the current OAM enable byte
    jr .martParent
.martParentPending
    ld b, 1 ; preserve the original OAM enable byte across Mart list loops
.martParent
    ; The Mart is the only caller with this explicit parent marker.
    ; BUY: PRICEDITEMLISTMENU + wItemList (single-byte IDs).
    ; SELL: ITEMLISTMENU + wNumBagItems (ID,quantity pairs).
    ld a, [wListMenuID]
    cp PRICEDITEMLISTMENU
    jr z, .martBuy
    cp ITEMLISTMENU
    ret nz
    ld a, [wListPointer]
    cp LOW(wNumBagItems)
    ret nz
    ld a, [wListPointer + 1]
    cp HIGH(wNumBagItems)
    ret nz
    ld a, [wPrintItemPrices]
    and a
    ret nz
    jr .enableMart
.martBuy
    ld a, [wListPointer]
    cp LOW(wItemList)
    ret nz
    ld a, [wListPointer + 1]
    cp HIGH(wItemList)
    ret nz
    ld a, [wPrintItemPrices]
    and a
    ret z
.enableMart
    ld a, 2 ; live Mart BUY/SELL list, distinct from the parent $80/$82
    ld [wPCItemDescriptionSessionActive], a
.enablePanel
    ld a, 1
    ld [wStartBagDescriptionActive], a
    ld a, $fe ; force a fresh description on first draw
    ld [wStartBagDescriptionLastID], a
    xor a
    ld [wStartBagDescriptionBoxDrawn], a
    ; Keep OAM disabled through the caller's prompt/parent-screen rebuild.
    ld a, b
    and a
    jr nz, .keepSavedSprites
    ld a, [wUpdateSpritesEnabled]
    ld [wPCItemDescriptionSavedSpritesEnabled], a
.keepSavedSprites
    xor a
    ld [wUpdateSpritesEnabled], a
    call HideSprites
    call DelayFrame
    ret

FinishPCItemDescriptions::
    ld a, [wPCItemDescriptionSessionActive]
    cp 1
    jr z, .finishList
    cp 2
    ret nz ; START Bag, Mart parent ($80/$82), and other lists are untouched
.finishList
    push af
    xor a
    ld [wStartBagDescriptionActive], a
    ld [wStartBagDescriptionBoxDrawn], a
    pop af
    cp 2
    jr z, .restoreMartParent
    ld a, 3 ; PC parent is pending; restore OAM only after its menu is drawn
    jr .storeMode
.restoreMartParent
    ld a, $82 ; Mart parent is pending; keep OAM hidden across BUY/SELL loops
.storeMode
    ld [wPCItemDescriptionSessionActive], a
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
    dw SingleBagEvolutionStoneDescription
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
    dw SingleBagEvolutionStoneDescription
    dw SingleBagEvolutionStoneDescription
    dw SingleBagEvolutionStoneDescription
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
    dw SingleBagEvolutionStoneDescription
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
    db $05, $b2, $19, $18, $12, $f2, $0f, $94, $05, $2e, $0b, $29, $0c, $da ; 捕捉野生宝可梦
    db CHARVAL("<NEXT>")
    db $05, $76, $07, $43, $06, $2b, $08, $8e ; 必定成功
    db CHARVAL("@")

SingleBagItemDescription02:
    db $05, $b2, $09, $b3, $0d, $64, $0b, $d8, $08, $86, $0e, $7f, $06, $f8 ; 捕获能力更强的
    db CHARVAL("<NEXT>")
    db $08, $69, $09, $d6, $0a, $a5, $0c, $23, $0e, $b2 ; 高级精灵球
    db CHARVAL("@")

SingleBagItemDescription03:
    db $05, $66, $0e, $20, $10, $d8, $0a, $a5, $0c, $23, $0e, $b2 ; 比普通精灵球
    db CHARVAL("<NEXT>")
    db $08, $86, $0e, $fb, $13, $20, $05, $b2, $19, $18 ; 更容易捕捉
    db CHARVAL("@")

SingleBagItemDescription04:
    db $13, $81, $13, $98, $05, $b2, $19, $18 ; 用于捕捉
    db CHARVAL("<NEXT>")
    db $12, $f2, $0f, $94, $05, $2e, $0b, $29, $0c, $da ; 野生宝可梦
    db CHARVAL("@")

SingleBagItemDescription05:
    db $05, $e5, $0b, $10, $08, $c0, $07, $6c, $07, $10, $0e, $b8 ; 查看关都地区
    db CHARVAL("<NEXT>")
    db $07, $10, $10, $ec ; 地图
    db CHARVAL("@")

SingleBagItemDescription06:
    db $0e, $3b, $06, $2d, $19, $30, $12, $41, $06, $13 ; 骑乘自行车
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

SingleBagItemDescription11:
    db $0a, $7e, $06, $75, $18, $c6, $07, $6e, $19, $0c, $10, $7e ; 解除中毒状态
    db CHARVAL("<NEXT>")
    db $05, $b7, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 不恢复体力
    db CHARVAL("@")

SingleBagItemDescription12:
    db $0a, $7e, $06, $75, $19, $21, $0f, $65, $19, $0c, $10, $7e ; 解除灼伤状态
    db CHARVAL("<NEXT>")
    db $05, $b7, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 不恢复体力
    db CHARVAL("@")

SingleBagItemDescription13:
    db $0a, $7e, $06, $75, $05, $97, $07, $63, $19, $0c, $10, $7e ; 解除冰冻状态
    db CHARVAL("<NEXT>")
    db $05, $b7, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 不恢复体力
    db CHARVAL("@")

SingleBagItemDescription14:
    db $09, $7f, $12, $42, $10, $09, $19, $20, $06, $f8 ; 唤醒睡着的
    db CHARVAL("<NEXT>")
    db $05, $2e, $0b, $29, $0c, $da ; 宝可梦
    db CHARVAL("@")

SingleBagItemDescription15:
    db $0a, $7e, $06, $75, $0c, $97, $05, $72, $19, $0c, $10, $7e ; 解除麻痹状态
    db CHARVAL("<NEXT>")
    db $05, $b7, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 不恢复体力
    db CHARVAL("@")

SingleBagItemDescription16:
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $10, $b7, $0b, $d8 ; 恢复全部体力
    db CHARVAL("<NEXT>")
    db $05, $9e, $0a, $7e, $06, $75, $13, $36, $06, $01, $19, $0c, $10, $7e ; 并解除异常状态
    db CHARVAL("@")

SingleBagItemDescription17:
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $10, $b7, $0b, $d8 ; 恢复全部体力
    db CHARVAL("<NEXT>")
    db $06, $df, $05, $b7, $0a, $7e, $06, $75, $13, $36, $06, $01, $19, $0c, $10, $7e ; 但不解除异常状态
    db CHARVAL("@")

SingleBagItemDescription18:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $e8, $01, $e6, $01, $e6, $07, $1e ; 最多２００点
    db CHARVAL("@")

SingleBagItemDescription19:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $eb, $01, $e6, $07, $1e ; 最多５０点
    db CHARVAL("@")

SingleBagItemDescription20:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $e8, $01, $e6, $07, $1e ; 最多２０点
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
    db $06, $a9, $07, $64, $12, $8c, $18, $c6, $10, $a5, $06, $6e ; 从洞穴中逃出
    db CHARVAL("<NEXT>")
    db $09, $9a, $06, $f1, $0f, $0d, $0b, $3a, $08, $31, $0a, $98 ; 回到入口附近
    db CHARVAL("@")

SingleBagItemDescription30:
    db $01, $e7, $01, $e6, $01, $e6, $05, $b9, $0d, $62, $05, $7a, $0b, $06 ; １００步内避开
    db CHARVAL("<NEXT>")
    db $05, $66, $07, $83, $0f, $cf, $06, $fc, $09, $d6, $07, $05, $06, $f8, $05, $2e, $0b, $29, $0c, $da ; 比队首等级低的宝可梦
    db CHARVAL("@")

SingleBagItemDescription31:
    db $08, $ad, $06, $d0, $05, $2e, $0b, $29, $0c, $da, $06, $f8 ; 古代宝可梦的
    db CHARVAL("<NEXT>")
    db $13, $0b, $06, $81, $11, $9b, $18, $c0, $28, $04, $1f, $f0 ; 遗传物质琥珀
    db CHARVAL("@")

SingleBagItemDescription35:
    db $10, $b3, $08, $69, $10, $b7, $0b, $d8, $06, $f8 ; 提高体力的
    db CHARVAL("<NEXT>")
    db $09, $bb, $06, $77, $0d, $64, $0b, $d8, $18, $ab ; 基础能力值
    db CHARVAL("@")

SingleBagItemDescription36:
    db $10, $b3, $08, $69, $08, $8d, $09, $b9, $06, $f8 ; 提高攻击的
    db CHARVAL("<NEXT>")
    db $09, $bb, $06, $77, $0d, $64, $0b, $d8, $18, $ab ; 基础能力值
    db CHARVAL("@")

SingleBagItemDescription37:
    db $10, $b3, $08, $69, $07, $ce, $13, $b7, $06, $f8 ; 提高防御的
    db CHARVAL("<NEXT>")
    db $09, $bb, $06, $77, $0d, $64, $0b, $d8, $18, $ab ; 基础能力值
    db CHARVAL("@")

SingleBagItemDescription38:
    db $10, $b3, $08, $69, $10, $37, $07, $78, $06, $f8 ; 提高速度的
    db CHARVAL("<NEXT>")
    db $09, $bb, $06, $77, $0d, $64, $0b, $d8, $18, $ab ; 基础能力值
    db CHARVAL("@")

SingleBagItemDescription39:
    db $10, $b3, $08, $69, $10, $aa, $0f, $da, $06, $f8 ; 提高特殊的
    db CHARVAL("<NEXT>")
    db $09, $bb, $06, $77, $0d, $64, $0b, $d8, $18, $ab ; 基础能力值
    db CHARVAL("@")

SingleBagItemDescription40:
    db $0e, $e1, $05, $2e, $0b, $29, $0c, $da ; 让宝可梦
    db CHARVAL("<NEXT>")
    db $06, $fc, $09, $d6, $10, $b3, $0f, $97, $13, $01, $09, $d6 ; 等级提升一级
    db CHARVAL("@")

SingleBagItemDescription41:
    db $08, $ad, $06, $d0, $05, $2e, $0b, $29, $0c, $da ; 古代宝可梦
    db CHARVAL("<NEXT>")
    db $0c, $2e, $11, $cc, $06, $f8, $09, $f7, $0b, $27, $09, $71, $0f, $a7 ; 留下的甲壳化石
    db CHARVAL("@")

SingleBagItemDescription42:
    db $08, $ad, $06, $d0, $05, $2e, $0b, $29, $0c, $da ; 古代宝可梦
    db CHARVAL("<NEXT>")
    db $0c, $2e, $11, $cc, $06, $f8, $05, $3c, $0b, $27, $09, $71, $0f, $a7 ; 留下的贝壳化石
    db CHARVAL("@")

SingleBagItemDescription43:
    db $13, $81, $13, $98, $06, $c8, $0b, $06 ; 用于打开
    db CHARVAL("<NEXT>")
    db $10, $aa, $07, $43, $0c, $d1, $10, $6c, $06, $f8, $13, $db, $06, $39 ; 特定门锁的钥匙
    db CHARVAL("@")

SingleBagItemDescription44:
    db $11, $8a, $07, $b6, $0f, $b1, $13, $81, $06, $f8 ; 无法使用的
    db CHARVAL("<NEXT>")
    db $11, $60, $18, $a0, $06, $f4, $0a, $d9 ; 未知道具
    db CHARVAL("@")

SingleBagItemDescription45:
    db $0e, $06, $0e, $cd, $0b, $29, $07, $82, $09, $7d ; 凭券可兑换
    db CHARVAL("<NEXT>")
    db $13, $01, $0b, $f0, $19, $30, $12, $41, $06, $13 ; 一辆自行车
    db CHARVAL("@")

SingleBagItemDescription46:
    db $18, $40, $07, $67, $18, $c6, $13, $f9, $0f, $a9 ; 战斗中暂时
    db CHARVAL("<NEXT>")
    db $10, $b3, $08, $69, $18, $68, $0f, $b5, $0d, $0c, $18, $c6, $0c, $78 ; 提高招式命中率
    db CHARVAL("@")

SingleBagItemDescription48:
    db $0b, $06, $0e, $41, $11, $ad, $0c, $61, $08, $04 ; 开启希鲁夫
    db CHARVAL("<NEXT>")
    db $08, $93, $10, $1b, $06, $f8, $0c, $d1, $0a, $97 ; 公司的门禁
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
    db $13, $f6, $12, $f2, $0f, $94, $18, $40, $07, $67, $18, $c6 ; 在野生战斗中
    db CHARVAL("<NEXT>")
    db $0d, $64, $18, $a7, $0a, $6f, $10, $a5, $0b, $bf ; 能直接逃离
    db CHARVAL("@")

SingleBagItemDescription52:
    db $0a, $7e, $06, $75, $13, $36, $06, $01, $19, $0c, $10, $7e ; 解除异常状态
    db CHARVAL("<NEXT>")
    db $05, $b7, $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 不恢复体力
    db CHARVAL("@")

SingleBagItemDescription53:
    db $0e, $e1, $09, $aa, $19, $9a, $05, $2e, $0b, $29, $0c, $da, $08, $28, $09, $b0 ; 让昏厥宝可梦复活
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $13, $01, $05, $11, $10, $b7, $0b, $d8 ; 恢复一半体力
    db CHARVAL("@")

SingleBagItemDescription54:
    db $0e, $e1, $09, $aa, $19, $9a, $05, $2e, $0b, $29, $0c, $da, $08, $28, $09, $b0 ; 让昏厥宝可梦复活
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $0e, $c9, $05, $bb, $10, $b7, $0b, $d8 ; 恢复全部体力
    db CHARVAL("@")

SingleBagItemDescription55:
    db $18, $40, $07, $67, $18, $c6, $07, $ce, $18, $af ; 战斗中防止
    db CHARVAL("<NEXT>")
    db $0d, $64, $0b, $d8, $05, $44, $0a, $3b, $07, $05 ; 能力被降低
    db CHARVAL("@")

SingleBagItemDescription56:
    db $01, $e8, $01, $e6, $01, $e6, $05, $b9, $0d, $62, $05, $7a, $0b, $06 ; ２００步内避开
    db CHARVAL("<NEXT>")
    db $05, $66, $07, $83, $0f, $cf, $06, $fc, $09, $d6, $07, $05, $06, $f8, $05, $2e, $0b, $29, $0c, $da ; 比队首等级低的宝可梦
    db CHARVAL("@")

SingleBagItemDescription57:
    db $01, $e8, $01, $eb, $01, $e6, $05, $b9, $0d, $62, $05, $7a, $0b, $06 ; ２５０步内避开
    db CHARVAL("<NEXT>")
    db $05, $66, $07, $83, $0f, $cf, $06, $fc, $09, $d6, $07, $05, $06, $f8, $05, $2e, $0b, $29, $0c, $da ; 比队首等级低的宝可梦
    db CHARVAL("@")

SingleBagItemDescription58:
    db $18, $40, $07, $67, $18, $c6, $0f, $b1, $13, $81 ; 战斗中使用
    db CHARVAL("<NEXT>")
    db $0a, $94, $0f, $0d, $0a, $d5, $0e, $45, $19, $0c, $10, $7e ; 进入聚气状态
    db CHARVAL("@")

SingleBagItemDescription59:
    db $13, $8c, $11, $c1, $06, $d0, $05, $70 ; 游戏代币
    db CHARVAL("<NEXT>")
    db $13, $81, $13, $98, $13, $8c, $0b, $aa, $05, $fb ; 用于游乐场
    db CHARVAL("@")

SingleBagItemDescription60:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $eb, $01, $e6, $07, $1e ; 最多５０点
    db CHARVAL("@")

SingleBagItemDescription61:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $ec, $01, $e6, $07, $1e ; 最多６０点
    db CHARVAL("@")

SingleBagItemDescription62:
    db $09, $98, $08, $28, $10, $b7, $0b, $d8 ; 恢复体力
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $01, $ee, $01, $e6, $07, $1e ; 最多８０点
    db CHARVAL("@")

SingleBagItemDescription63:
    db $06, $2d, $19, $6a, $0f, $9d, $04, $d4, $0d, $91, $09, $0f ; 乘坐圣安奴号
    db CHARVAL("<NEXT>")
    db $10, $6d, $12, $6e, $06, $f8, $06, $82, $0d, $f5 ; 所需的船票
    db CHARVAL("@")

SingleBagItemDescription64:
    db $1d, $8d, $0c, $0a, $07, $10, $06, $ce, $13, $cc, $06, $02 ; 狩猎地带园长
    db CHARVAL("<NEXT>")
    db $13, $0b, $0f, $9f, $06, $f8, $0a, $8c, $09, $f9, $12, $a4 ; 遗失的金假牙
    db CHARVAL("@")

SingleBagItemDescription65:
    db $18, $40, $07, $67, $18, $c6, $13, $f9, $0f, $a9 ; 战斗中暂时
    db CHARVAL("<NEXT>")
    db $10, $b3, $08, $69, $08, $8d, $09, $b9, $0d, $64, $0b, $d8 ; 提高攻击能力
    db CHARVAL("@")

SingleBagItemDescription66:
    db $18, $40, $07, $67, $18, $c6, $13, $f9, $0f, $a9 ; 战斗中暂时
    db CHARVAL("<NEXT>")
    db $10, $b3, $08, $69, $07, $ce, $13, $b7, $0d, $64, $0b, $d8 ; 提高防御能力
    db CHARVAL("@")

SingleBagItemDescription67:
    db $18, $40, $07, $67, $18, $c6, $13, $f9, $0f, $a9 ; 战斗中暂时
    db CHARVAL("<NEXT>")
    db $10, $b3, $08, $69, $10, $37, $07, $78, $0d, $64, $0b, $d8 ; 提高速度能力
    db CHARVAL("@")

SingleBagItemDescription68:
    db $18, $40, $07, $67, $18, $c6, $13, $f9, $0f, $a9 ; 战斗中暂时
    db CHARVAL("<NEXT>")
    db $10, $b3, $08, $69, $10, $aa, $0f, $da, $0d, $64, $0b, $d8 ; 提高特殊能力
    db CHARVAL("@")

SingleBagItemDescription69:
    db $13, $81, $0b, $88, $06, $bc, $07, $d3 ; 用来存放
    db CHARVAL("<NEXT>")
    db $13, $8c, $11, $c1, $10, $ce, $06, $d0, $05, $70 ; 游戏厅代币
    db CHARVAL("@")

SingleBagItemDescription70:
    db $0a, $42, $08, $82, $06, $c9, $0d, $30, $05, $a5, $0f, $b7 ; 交给大木博士
    db CHARVAL("<NEXT>")
    db $06, $f8, $05, $26, $08, $e4 ; 的包裹
    db CHARVAL("@")

SingleBagItemDescription71:
    db $0d, $64, $12, $94, $18, $6a, $08, $31, $0a, $98, $06, $f8 ; 能寻找附近的
    db CHARVAL("<NEXT>")
    db $13, $49, $05, $d4, $06, $f4, $0a, $d9 ; 隐藏道具
    db CHARVAL("@")

SingleBagItemDescription72:
    db $0b, $10, $06, $7f, $13, $82, $0c, $23, $06, $f8 ; 看穿幽灵的
    db CHARVAL("<NEXT>")
    db $18, $7e, $0f, $ad, $0c, $f2, $0c, $be ; 真实面貌
    db CHARVAL("@")

SingleBagItemDescription73:
    db $06, $8b, $11, $f6, $0b, $29, $09, $7f, $12, $42 ; 吹响可唤醒
    db CHARVAL("<NEXT>")
    db $06, $23, $10, $09, $06, $f8, $05, $2e, $0b, $29, $0c, $da ; 沉睡的宝可梦
    db CHARVAL("@")

SingleBagItemDescription74:
    db $05, $d5, $0b, $38, $07, $23, $10, $af, $06, $f8 ; 操控电梯的
    db CHARVAL("<NEXT>")
    db $18, $ce, $12, $ec, $13, $db, $06, $39 ; 重要钥匙
    db CHARVAL("@")

SingleBagItemDescription75:
    db $0e, $e1, $0e, $c9, $07, $83, $07, $e4, $11, $f7 ; 让全队分享
    db CHARVAL("<NEXT>")
    db $09, $b3, $06, $f7, $06, $f8, $0a, $a7, $12, $cd ; 获得的经验
    db CHARVAL("@")

SingleBagItemDescription76:
    db $19, $60, $09, $bb, $06, $77, $06, $f8 ; 最基础的
    db CHARVAL("<NEXT>")
    db $07, $32, $13, $a1, $13, $81, $07, $32, $08, $42 ; 钓鱼用钓竿
    db CHARVAL("@")

SingleBagItemDescription77:
    db $13, $f6, $10, $08, $05, $7d, $07, $32, $13, $a1 ; 在水边钓鱼
    db CHARVAL("<NEXT>")
    db $0b, $29, $0d, $64, $07, $32, $06, $f1, $08, $86, $0e, $7f, $06, $f8, $05, $2e, $0b, $29, $0c, $da ; 可能钓到更强的宝可梦
    db CHARVAL("@")

SingleBagItemDescription78:
    db $13, $f6, $10, $08, $05, $7d, $07, $32, $13, $a1 ; 在水边钓鱼
    db CHARVAL("<NEXT>")
    db $0b, $29, $0d, $64, $07, $32, $06, $f1, $11, $ab, $13, $8e, $05, $2e, $0b, $29, $0c, $da ; 可能钓到稀有宝可梦
    db CHARVAL("@")

SingleBagItemDescription79:
    db $10, $b3, $08, $69, $06, $d9, $08, $80, $18, $68, $0f, $b5 ; 提高单个招式
    db CHARVAL("<NEXT>")
    db $06, $f8, $19, $60, $06, $c9, $02, $0a, $02, $0a ; 的最大ＰＰ
    db CHARVAL("@")

SingleBagItemDescription80:
    db $06, $d9, $08, $80, $18, $68, $0f, $b5, $02, $0a, $02, $0a ; 单个招式ＰＰ
    db CHARVAL("<NEXT>")
    db $19, $60, $07, $90, $09, $98, $08, $28, $01, $e7, $01, $e6, $07, $1e ; 最多恢复１０点
    db CHARVAL("@")

SingleBagItemDescription81:
    db $06, $d9, $08, $80, $18, $68, $0f, $b5, $02, $0a, $02, $0a ; 单个招式ＰＰ
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $06, $f1, $19, $60, $06, $c9, $18, $ab ; 恢复到最大值
    db CHARVAL("@")

SingleBagItemDescription82:
    db $0e, $c9, $05, $bb, $18, $68, $0f, $b5, $02, $0a, $02, $0a ; 全部招式ＰＰ
    db CHARVAL("<NEXT>")
    db $08, $81, $09, $98, $08, $28, $01, $e7, $01, $e6, $07, $1e ; 各恢复１０点
    db CHARVAL("@")

SingleBagItemDescription83:
    db $0e, $c9, $05, $bb, $18, $68, $0f, $b5, $02, $0a, $02, $0a ; 全部招式ＰＰ
    db CHARVAL("<NEXT>")
    db $09, $98, $08, $28, $06, $f1, $19, $60, $06, $c9, $18, $ab ; 恢复到最大值
    db CHARVAL("@")

SingleBagEvolutionStoneDescription:
    db $0d, $64, $0e, $e1, $10, $aa, $07, $43, $05, $2e, $0b, $29, $0c, $da ; 能让特定宝可梦
    db CHARVAL("<NEXT>")
    db $0a, $94, $09, $71, $06, $f8, $0f, $8b, $0e, $32, $0f, $a7, $10, $e7 ; 进化的神奇石头
    db CHARVAL("@")
