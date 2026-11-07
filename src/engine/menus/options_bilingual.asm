; ROM-1.39 bilingual LANGUAGE phase 1 (English content is still a pilot).
; Bank $45: the old Options routines used to live in nearly-full Bank $01.
; Page 1: Text Speed / Battle Animation / Battle Style / PAGE.
; Page 2: Pokemon species name language / global LANGUAGE / PAGE.
; wOptions bit 5 is persisted in existing wMainData; 0=Chinese, 1=English.
; Pokemon species names are controlled solely by wENGNameMark; the global
; LANGUAGE option never changes that separate name-language preference.
; Only Options and the Route 1 test NPC are bilingual in this phase.
; wOptionsMenuPage aliases an unused Options cursor byte (not new WRAM).

DisplayOptionMenuStartExpanded::
    ld a, 1
    jr DisplayOptionMenuExpanded.entry

DisplayOptionMenuExpanded::
    xor a
.entry
    push af ; nonzero if invoked by START, used for the palette reveal
    xor a
    ld [wOptionsMenuPage], a
    call .drawPage1
    xor a
    ld [wCurrentMenuItem], a
    ld [wLastMenuItem], a
    inc a
    ld [wLetterPrintingDelayFlags], a
    call SetCursorPositionsFromOptions
    ; Open Options with the cursor on PAGE 1/2, ready to flip pages.
    ld a, 16
    ld [wTopMenuItemY], a
    ld a, 1
    ld [wTopMenuItemX], a
    ld a, 1
    ldh [hAutoBGTransferEnabled], a
    call Delay3
    pop af
    and a
    jr z, .loop
    farcall RevealFullScreenLoadGBPal
.loop
    call PlaceMenuCursor
    call SetOptionsFromCursorPositions
.waitForInput
    call JoypadLowSensitivity
    ldh a, [hJoy5]
    ld b, a
    and A_BUTTON | B_BUTTON | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
    jr z, .waitForInput
    bit BIT_B_BUTTON, b
    jr nz, .exitMenu
    bit BIT_START, b
    jr nz, .exitMenu
    bit BIT_A_BUTTON, b
    jr z, .checkDirections
    ld a, [wTopMenuItemY]
    cp 16
    jp z, .switchPage
    jp .loop ; A on a setting row does not change it
.exitMenu
    ld a, SFX_PRESS_AB
    call PlaySound
    ret

.checkDirections
    ld a, [wOptionsMenuPage]
    and a
    jp nz, .page2Directions
    ld a, [wTopMenuItemY]
    bit BIT_D_DOWN, b
    jp nz, .page1Down
    bit BIT_D_UP, b
    jp nz, .page1Up
    cp 16
    jp z, .onPageSelector
    cp 8
    jr z, .battleAnimation
    cp 13
    jr z, .battleStyle
    bit BIT_D_LEFT, b
    jp nz, .textSpeedLeft
    jp .textSpeedRight

.page1Down
    cp 3
    jr z, .toBattleAnimation
    cp 8
    jr z, .toBattleStyle
    cp 13
    jr z, .toPage1Footer
    jr .toTextSpeed
.page1Up
    cp 3
    jr z, .toPage1Footer
    cp 8
    jr z, .toTextSpeed
    cp 13
    jr z, .toBattleAnimation
    jr .toBattleStyle
.toTextSpeed
    ld a, 3
    ld [wTopMenuItemY], a
    ld a, [wOptionsTextSpeedCursorX]
    jp .moveOptionCursor
.toBattleAnimation
    ld a, 8
    ld [wTopMenuItemY], a
    ld a, [wOptionsBattleAnimCursorX]
    jr .moveOptionCursor
.toBattleStyle
    ld a, 13
    ld [wTopMenuItemY], a
    ld a, [wOptionsBattleStyleCursorX]
    jr .moveOptionCursor
.toPage1Footer
    ld a, 16
    ld [wTopMenuItemY], a
    ld a, 1
.moveOptionCursor
    ld [wTopMenuItemX], a
    call PlaceUnfilledArrowMenuCursor
    jp .loop

.battleAnimation
    ld a, [wOptionsBattleAnimCursorX]
    xor $0b ; original Options: toggle x=1 <-> x=10
    ld [wOptionsBattleAnimCursorX], a
    jp .eraseAndMoveCursor
.battleStyle
    ld a, [wOptionsBattleStyleCursorX]
    xor $0b ; original Options: toggle x=1 <-> x=10
    ld [wOptionsBattleStyleCursorX], a
    jp .eraseAndMoveCursor
.textSpeedLeft
    ld a, [wOptionsTextSpeedCursorX]
    cp 1
    jr z, .storeTextSpeedX
    cp 7
    jr nz, .slowToMedium
    sub 6
    jr .storeTextSpeedX
.slowToMedium
    sub 7
    jr .storeTextSpeedX
.textSpeedRight
    ld a, [wOptionsTextSpeedCursorX]
    cp 14
    jr z, .storeTextSpeedX
    cp 7
    jr nz, .fastToMedium
    add 7
    jr .storeTextSpeedX
.fastToMedium
    add 6
.storeTextSpeedX
    ld [wOptionsTextSpeedCursorX], a
.eraseAndMoveCursor
    ld [wTopMenuItemX], a
    call EraseMenuCursor
    jp .loop

.page2Directions
    ld a, [wTopMenuItemY]
    bit BIT_D_DOWN, b
    jr nz, .page2Down
    bit BIT_D_UP, b
    jr nz, .page2Up
    cp 16
    jp z, .onPageSelector
    ld a, b
    and D_LEFT | D_RIGHT
    jp z, .loop
    ld a, [wTopMenuItemY]
    cp 3
    jr z, .toggleNames
.toggleLanguage
    call EraseMenuCursor
    ld a, [wOptions]
    xor %00100000 ; globally selected language, future text banks use this bit
    ld [wOptions], a
    ; Do not touch wENGNameMark: Pokemon names are an independent option.
    ; Rebuild page 2 immediately in the selected language. Recompute the
    ; page-1 cursor positions off-screen before the next options save pass.
    call .redrawLanguagePage2
    jp .loop
.toggleNames
    call EraseMenuCursor
    ld a, [wENGNameMark]
    xor 1
    ld [wENGNameMark], a
    call .getNameCursorX
    ld [wTopMenuItemX], a
    jp .loop
.page2Down
    cp 3
    jr z, .toLanguage
    cp 8
    jr z, .toPage2Footer
    jr .toNames
.page2Up
    cp 3
    jr z, .toPage2Footer
    cp 8
    jr z, .toNames
    jr .toLanguage
.toNames
    ld a, 3
    ld [wTopMenuItemY], a
    call .getNameCursorX
    jp .moveOptionCursor
.toLanguage
    ld a, 8
    ld [wTopMenuItemY], a
    call .getLanguageCursorX
    jp .moveOptionCursor
.toPage2Footer
    ld a, 16
    ld [wTopMenuItemY], a
    ld a, 1
    jp .moveOptionCursor

.redrawLanguagePage2
    xor a
    ldh [hAutoBGTransferEnabled], a
    ; SetCursorPositionsFromOptions writes page-1 arrows; they are erased
    ; before any BG transfer, but the new x coordinates are retained.
    call SetCursorPositionsFromOptions
    call ClearScreen
    call .drawPage2
    call .placePage2Arrows
    ld a, 8 ; stay on LANGUAGE after switching it
    ld [wTopMenuItemY], a
    call .getLanguageCursorX
    ld [wTopMenuItemX], a
    ld a, 1
    ldh [hAutoBGTransferEnabled], a
    call Delay3
    ret

.onPageSelector
    ld a, b
    and D_LEFT | D_RIGHT
    jp z, .loop
.switchPage
    ; Construct the next tilemap fully off-screen (RPP Options page pattern).
    xor a
    ldh [hAutoBGTransferEnabled], a
    call ClearScreen
    ld a, [wOptionsMenuPage]
    xor 1
    ld [wOptionsMenuPage], a
    and a
    jr z, .showPage1
    call .drawPage2
    call .placePage2Arrows
    jr .finishPageSwitch
.showPage1
    call .drawPage1
    call SetCursorPositionsFromOptions
.finishPageSwitch
    xor a
    ld [wCurrentMenuItem], a
    ld [wLastMenuItem], a
    ld a, 16
    ld [wTopMenuItemY], a
    ld a, 1
    ld [wTopMenuItemX], a
    ldh [hAutoBGTransferEnabled], a
    call Delay3
    jp .loop

.drawPageFrame
    hlcoord 0, 0
    ld b, 3
    ld c, 18
    call TextBoxBorder
    hlcoord 0, 5
    ld b, 3
    ld c, 18
    call TextBoxBorder
    hlcoord 0, 10
    ld b, 3
    ld c, 18
    jp TextBoxBorder
.drawVersion
    hlcoord 11, 0 ; ROM-1.41 is 8 characters; keep the right edge at x=18.
    ld de, GameVersionText
    jp PlaceString
.drawPage1
    call .drawPageFrame
    call .drawVersion
    ld a, [wOptions]
    bit 5, a
    jr nz, .drawPage1English
    ; Use the original CHS main_menu.asm layout and source strings.
    ; The existing data.xlsx importer supplies the Chinese text while keeping
    ; the original anchors, next-line spacing and cursor positions intact.
    hlcoord 1, 1
    ld de, TextSpeedOptionTextCHS
    call PlaceString
    hlcoord 1, 6
    ld de, BattleAnimationOptionTextCHS
    call PlaceString
    hlcoord 1, 11
    ld de, BattleStyleOptionTextCHS
    call PlaceString
    hlcoord 2, 16
    ld de, OptionMenuPage1TextCHS
    call PlaceString
    jp .clearFooterBackHint
.drawPage1English
    ; Match the original English pokered main_menu.asm layout.
    hlcoord 1, 1
    ld de, TextSpeedOptionTextEN
    call PlaceString
    hlcoord 1, 6
    ld de, BattleAnimationOptionTextEN
    call PlaceString
    hlcoord 1, 11
    ld de, BattleStyleOptionTextEN
    call PlaceString
    hlcoord 2, 16
    ld de, OptionMenuPage1TextEN
    call PlaceString
    jp .clearFooterBackHint
.drawPage2
    call .drawPageFrame
    call .drawVersion
    ld a, [wOptions]
    bit 5, a
    jr nz, .drawPage2English
    hlcoord 1, 1
    ld de, NameLanguageOptionTextCHS
    call PlaceString
    hlcoord 1, 6
    ld de, LanguageOptionTextCHS
    call PlaceString
    hlcoord 1, 11
    ld de, PilotScopeOptionTextCHS
    call PlaceString
    hlcoord 2, 16
    ld de, OptionMenuPage2TextCHS
    call PlaceString
    jp .clearFooterBackHint
.drawPage2English
    hlcoord 1, 1
    ld de, NameLanguageOptionTextEN
    call PlaceString
    hlcoord 1, 6
    ld de, LanguageOptionTextEN
    call PlaceString
    hlcoord 1, 11
    ld de, PilotScopeOptionTextEN
    call PlaceString
    hlcoord 2, 16
    ld de, OptionMenuPage2TextEN
    call PlaceString
    jp .clearFooterBackHint
.clearFooterBackHint
    ; CHS page strings retain the old translation lookup key, but the
    ; The CHS DFS suffix is double-height and draws its upper pixels on
    ; y=15 (one row ABOVE the y=16 PlaceString anchor). ROM-1.39C only
    ; cleared y=16..17 and left the upper half of 返回 visible at y=15.
    ; Clear all three right-side rows, while preserving PAGE at x<11.
    hlcoord 11, 15
    call .clearFooterSuffixRow
    hlcoord 11, 16
    call .clearFooterSuffixRow
    hlcoord 11, 17
.clearFooterSuffixRow
    ld b, 8 ; x=11..18; preserve right-hand border at x=19
    ld a, CHARVAL(" ")
.clearFooterSuffixTile
    ld [hli], a
    dec b
    jr nz, .clearFooterSuffixTile
    ret
.placePage2Arrows
    hlcoord 0, 3
    call .getNameCursorX
    call .placeUnfilledArrow
    hlcoord 0, 8
    call .getLanguageCursorX
    call .placeUnfilledArrow
    hlcoord 1, 16
    ld [hl], CHARVAL("▷")
    ret
.placeUnfilledArrow
    ld e, a
    ld d, 0
    add hl, de
    ld [hl], CHARVAL("▷")
    ret
.getNameCursorX
    ld a, [wENGNameMark]
    and 1
    jr nz, .secondChoiceX
    ld a, 1
    ret
.getLanguageCursorX
    ld a, [wOptions]
    bit 5, a
    jr nz, .secondChoiceX
    ld a, 1
    ret
.secondChoiceX
    ld a, 11 ; ENGLISH begins at x=12, so the cursor belongs at x=11
    ret

; The CHS strings intentionally start from the English source phrases.
; The project data.xlsx importer translates only the CHS copies in buildRB.
; English copies split string literals so the importer leaves them untouched.
; Page 1 retains the original main_menu.asm line breaks and cursor positions.
TextSpeedOptionTextCHS:
    db "TEXT SPEED"
    next " FAST  MEDIUM SLOW@"
TextSpeedOptionTextEN:
    db "TEXT", " SPEED"
    next " FAST", "  MEDIUM SLOW@"
BattleAnimationOptionTextCHS:
    db "BATTLE ANIMATION"
    next " ON       OFF@"
BattleAnimationOptionTextEN:
    db "BATTLE", " ANIMATION"
    next " ON", "       OFF@"
BattleStyleOptionTextCHS:
    db "BATTLE STYLE"
    next " SHIFT    SET@"
BattleStyleOptionTextEN:
    db "BATTLE", " STYLE"
    next " SHIFT", "    SET@"
NameLanguageOptionTextCHS:
    db "POKEMON NAMES"
    next " CHINESE       ENGLISH@"
NameLanguageOptionTextEN:
    db "POKEMON", " NAMES"
    ; Preserve the original Chinese choice label even in English UI mode.
    ; $18,$C6 = 中; $11,$70 = 文 (DFS); ENGLISH starts at x=12.
    next " ",$18,$C6,$11,$70,"       ENGLISH@"
LanguageOptionTextCHS:
    db "LANGUAGE"
    next " CHINESE       ENGLISH@"
LanguageOptionTextEN:
    db "LANG", "UAGE"
    ; Keep the user's intentional 中文 / ENGLISH choice labels unchanged.
    next " ",$18,$C6,$11,$70,"       ENGLISH@"
PilotScopeOptionTextCHS:
    db "ROUTE 1 NPC ONLY"
    next "OTHER TEXT: CHS@"
PilotScopeOptionTextEN:
    db "ROUTE 1", " NPC ONLY"
    next "OTHER TEXT:", " CHS@"
; Do not change the CHS lookup strings here: the existing data.xlsx
; import recognizes the original text and supplies the Chinese page labels.
; .clearFooterBackHint erases only the unused right-hand suffix after drawing.
OptionMenuPage1TextCHS:
    db "PAGE 1/2   B:BACK@"
OptionMenuPage1TextEN:
    db "PAGE", " 1/2@"
OptionMenuPage2TextCHS:
    db "PAGE 2/2   B:BACK@"
OptionMenuPage2TextEN:
    db "PAGE", " 2/2@"

; Original Options coordinates are shared by the upstream English layout and
; the CHS layout. The workbook's Chinese strings retain the original spacing.
SetOptionsFromCursorPositions:
    ld hl, TextSpeedOptionData
    ld a, [wOptionsTextSpeedCursorX]
    ld c, a
.loop
    ld a, [hli]
    cp c
    jr z, .textSpeedMatchFound
    inc hl
    jr .loop
.textSpeedMatchFound
    ld a, [hl]
    ld d, a
    ld a, [wOptionsBattleAnimCursorX]
    dec a
    jr z, .battleAnimationOn
    set 7, d
    jr .checkBattleStyle
.battleAnimationOn
    res 7, d
.checkBattleStyle
    ld a, [wOptionsBattleStyleCursorX]
    dec a
    jr z, .battleStyleShift
    set 6, d
    jr .storeOptions
.battleStyleShift
    res 6, d
.storeOptions
    ld a, [wOptions]
    and %00110000 ; preserve LANGUAGE bit 5 and reserved bit 4
    or d
    ld [wOptions], a
    ret

SetCursorPositionsFromOptions:
    ld hl, TextSpeedOptionData + 1
    ld a, [wOptions]
    ld c, a
    and $0f ; LANGUAGE bit 5 is not part of the text-speed value
    push bc
    ld de, 2
    call IsInArray
    pop bc
    dec hl
    ld a, [hl]
    ld [wOptionsTextSpeedCursorX], a
    hlcoord 0, 3
    call .placeUnfilledRightArrow
    sla c
    ld a, 1 ; On
    jr nc, .storeBattleAnimationCursorX
    ld a, 10 ; Off
.storeBattleAnimationCursorX
    ld [wOptionsBattleAnimCursorX], a
    hlcoord 0, 8
    call .placeUnfilledRightArrow
    sla c
    ld a, 1 ; Shift
    jr nc, .storeBattleStyleCursorX
    ld a, 10 ; Set
.storeBattleStyleCursorX
    ld [wOptionsBattleStyleCursorX], a
    hlcoord 0, 13
    call .placeUnfilledRightArrow
    hlcoord 1, 16
    ld [hl], CHARVAL("▷")
    ret
.placeUnfilledRightArrow
    ld e, a
    ld d, 0
    add hl, de
    ld [hl], CHARVAL("▷")
    ret

TextSpeedOptionData:
    db 14, TEXT_DELAY_SLOW
    db  7, TEXT_DELAY_MEDIUM
    db  1, TEXT_DELAY_FAST
    db  7, -1
