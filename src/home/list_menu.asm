; INPUT:
; [wListMenuID] = list menu ID
; [wListPointer] = address of the list (2 bytes)
DisplayListMenuID::
	xor a
	ldh [hAutoBGTransferEnabled], a ; disable auto-transfer
	; Reuse the START Bag description panel for the three Player's PC item
	; lists. The gate validates the PC session and actual inventory pointer.
	farcall TryStartPCItemDescriptions
	ld a, JOY_REPEAT_MODE_LONG_LIST
	ldh [hJoy7], a ; long-list repeat speed from MenuRepeatDelayTable
	ld a, [wBattleType]
	and a ; is it the Old Man battle?
	jr nz, .specialBattleType
	ld a, $01 ; hardcoded bank
	jr .bankswitch
.specialBattleType ; Old Man battle
	ld a, BANK(DisplayBattleMenu)
.bankswitch
	call BankswitchHome
	ld hl, wd730
	set 6, [hl] ; turn off letter printing delay
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	ld [wItemListRedrawDirty], a ; first draw does not invalidate saved START glyphs
	ld [wListCount], a
	ld a, [wListPointer]
	ld l, a
	ld a, [wListPointer + 1]
	ld h, a ; hl = address of the list
	ld a, [hl] ; the first byte is the number of entries in the list
	ld [wListCount], a
	ld a, LIST_MENU_BOX
	ld [wTextBoxID], a
	; Mart keeps the original LIST_MENU_BOX frame (y=2..12) below MONEY.
	; Disable the START/PC raised-frame adjustment for this initial draw.
	ld a, [wPCItemDescriptionSessionActive]
	cp 2 ; live Mart item-list description
	jr nz, .drawListBoxNormally
	xor a
	ld [wStartBagDescriptionActive], a
	call DisplayTextBoxID
	ld a, 1
	ld [wStartBagDescriptionActive], a
	jr .listBoxDrawn
.drawListBoxNormally
	call DisplayTextBoxID
.listBoxDrawn
	call UpdateSprites ; disable sprites behind the text box
; the code up to .skipMovingSprites appears to be useless
	hlcoord 5, 2 ;hlcoord 4, 2 ; coordinates of upper left corner of menu text box
	lb de, 9, 14 ; height and width of menu text box
	ld a, [wListMenuID]
	and a ; PCPOKEMONLISTMENU?
	jr nz, .skipMovingSprites
	call UpdateSprites
.skipMovingSprites
	ld a, 1 ; max menu item ID is 1 if the list has less than 2 entries
	ld [wMenuWatchMovingOutOfBounds], a
	ld a, [wListCount]
	cp 2 ; does the list have less than 2 entries?
	jr c, .setMenuVariables
	ld a, 2 ; max menu item ID is 2 if the list has at least 2 entries
.setMenuVariables
	ld [wMaxMenuItem], a
	; START Bag/Player PC use y=3; Mart retains its original y=4 cursor row.
	ld a, [wStartBagDescriptionActive]
	and a
	ld a, 4
	jr z, .setTopMenuY
	ld a, [wPCItemDescriptionSessionActive]
	cp 2
	ld a, 4
	jr z, .setTopMenuY
	dec a
.setTopMenuY
	ld [wTopMenuItemY], a
	ld a, 5
	ld [wTopMenuItemX], a
	ld a, A_BUTTON | B_BUTTON | SELECT
	ld [wMenuWatchedKeys], a
	ld c, 10
	call DelayFrames
	; The initial list draw keeps the original START Bag fast-return path.
	xor a
	jr DisplayListMenuIDLoop.paint

DisplayListMenuIDLoop::
	xor a ; regular redraw: no edge-wrap wait
	jr .redraw
.wrapAndWait
	ld a, 1 ; single edge jump: wait for direction release after redraw
.redraw
	; After the initial draw, any list repaint may replace CHS DFS glyphs
	; referenced by START's saved tilemap. Do not use that tilemap alone on exit.
	push af
	ld a, 1
	ld [wItemListRedrawDirty], a
	pop af
.paint
	push af
	xor a
	ldh [hAutoBGTransferEnabled], a ; disable transfer
	call PrintListMenuEntries
	; List repaint can recycle DFS font tiles even if the selected item ID
	; has not changed. Repaint its description too, never show stale glyphs.
	ld a, $fe
	ld [wStartBagDescriptionLastID], a
	call UpdateStartBagDescriptionIfActive
	call PlaceMenuCursor ; list and cursor enter the normal BG transfer together
	ld a, 1
	ldh [hAutoBGTransferEnabled], a ; enable transfer
	call Delay3
	pop af
	and a
	call nz, .waitForDirectionRelease
	ld a, [wBattleType]
	and a ; is it the Old Man battle?
	jr z, .notOldManBattle
.oldManBattle
	ld a, CHARVAL("▶")
	ldcoord_a 5, 4 ; place menu cursor in front of first menu entry
	ld c, 80
	call DelayFrames
	xor a
	ld [wCurrentMenuItem], a
	hlcoord 5, 4
	ld a, l
	ld [wMenuCursorLocation], a
	ld a, h
	ld [wMenuCursorLocation + 1], a
	jr .buttonAPressed
.notOldManBattle
	call LoadGBPal
.input
	call HandleMenuInput
	push af
	call UpdateStartBagDescriptionIfActive
	call PlaceMenuCursor
	pop af
	bit BIT_A_BUTTON, a
	jp z, .checkOtherKeys
.buttonAPressed
	ld a, [wCurrentMenuItem]
	call PlaceUnfilledArrowMenuCursor

; pointless because both values are overwritten before they are read
	ld a, $01
	ld [wMenuExitMethod], a
	ld [wChosenMenuItem], a

	xor a
	ld [wMenuWatchMovingOutOfBounds], a
	ld a, [wCurrentMenuItem]
	ld c, a
	ld a, [wListScrollOffset]
	add c
	ld c, a
	ld a, [wListCount]
	and a ; is the list empty?
	jp z, ExitListMenu ; if so, exit the menu
	dec a
	cp c ; did the player select Cancel?
	jp c, ExitListMenu ; if so, exit the menu
	ld a, c
	ld [wWhichPokemon], a
	ld a, [wListMenuID]
	cp ITEMLISTMENU
	jr nz, .skipMultiplying
; if it's an item menu
	sla c ; item entries are 2 bytes long, so multiply by 2
.skipMultiplying
	ld a, [wListPointer]
	ld l, a
	ld a, [wListPointer + 1]
	ld h, a
	inc hl ; hl = beginning of list entries
	ld b, 0
	add hl, bc
	ld a, [hl]
	ld [wcf91], a
	ld a, [wListMenuID]
	and a ; PCPOKEMONLISTMENU?
	jr z, .pokemonList
	push hl
	call GetItemPrice
	pop hl
	ld a, [wListMenuID]
	cp ITEMLISTMENU
	jr nz, .skipGettingQuantity
; if it's an item menu
	inc hl
	ld a, [hl] ; a = item quantity
	ld [wMaxItemQuantity], a
.skipGettingQuantity
	ld a, [wcf91]
	ld [wd0b5], a
	ld a, BANK(ItemNames)
	ld [wPredefBank], a
	call GetName
	jr .storeChosenEntry
.pokemonList
	ld hl, wPartyCount
	ld a, [wListPointer]
	cp l ; is it a list of party pokemon or box pokemon?
	ld hl, wPartyMonNicks
	jr z, .getPokemonName
	ld hl, wBoxMonNicks ; box pokemon names
.getPokemonName
	ld a, [wWhichPokemon]
	call GetPartyMonName
.storeChosenEntry ; store the menu entry that the player chose and return
	ld de, wcd6d
	call CopyToStringBuffer
	ld a, CHOSE_MENU_ITEM
	ld [wMenuExitMethod], a
	ld a, [wCurrentMenuItem]
	ld [wChosenMenuItem], a
	xor a
	ldh [hJoy7], a ; joypad state update flag
	ld hl, wd730
	res 6, [hl] ; turn on letter printing delay
	farcall FinishPCItemDescriptions
	xor a ; chosen item: carry must remain clear after the farcall
	jp BankswitchBack
.checkOtherKeys ; check B, SELECT, Up, and Down keys
	bit BIT_B_BUTTON, a
	jp nz, ExitListMenu ; if so, exit the menu
	bit BIT_SELECT, a
	jp nz, HandleItemListSwapping ; if so, allow the player to swap menu entries
	ld b, a
	bit BIT_D_DOWN, b
	jr z, .upPressed
.downPressed
	; Include priced shop-buy and special elevator/badge lists.
	; Moves list is deliberately excluded; held Down never wraps.
	ld a, [wListMenuID]
	cp MOVESLISTMENU
	jr z, .regularDown
	cp SPECIALLISTMENU + 1
	jr nc, .regularDown
.eligibleDown
	ld a, [wListCount]
	and a
	jr z, .regularDown
	ld c, a
	ld a, [wListScrollOffset]
	ld b, a
	ld a, [wCurrentMenuItem]
	add b
	cp c
	jr nz, .regularDown
	ldh a, [hJoyPressed]
	bit BIT_D_DOWN, a
	jr z, .noMovementDown
	xor a
	ld [wListScrollOffset], a
	ld [wCurrentMenuItem], a
	jp DisplayListMenuIDLoop.wrapAndWait
.noMovementDown
	call DisplayListMenuIDLoop.waitForDirectionRelease
	jp DisplayListMenuIDLoop.input
.regularDown
	ld hl, wListScrollOffset
	ld a, [hl]
	add 3
	ld b, a
	ld a, [wListCount]
	cp b ; will going down scroll past the Cancel button?
	jp c, DisplayListMenuIDLoop.input ; no unnecessary redraw at boundary
	inc [hl] ; if not, go down
	jp DisplayListMenuIDLoop
.upPressed
	; Same eligibility on fresh Up; never repeat-wrap.
	ld a, [wListMenuID]
	cp MOVESLISTMENU
	jr z, .regularUp
	cp SPECIALLISTMENU + 1
	jr nc, .regularUp
.eligibleUp
	ld a, [wListCount]
	and a
	jr z, .regularUp
	ld a, [wListScrollOffset]
	and a
	jr nz, .regularUp
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .regularUp
	ldh a, [hJoyPressed]
	bit BIT_D_UP, a
	jr z, .noMovementUp
	ld a, [wListCount]
	cp 2
	jr c, .shortList
	sub 2 ; last visible row points to CANCEL
	ld [wListScrollOffset], a
	ld a, 2
	ld [wCurrentMenuItem], a
	jp DisplayListMenuIDLoop.wrapAndWait
.shortList
	xor a
	ld [wListScrollOffset], a
	ld a, [wListCount] ; CANCEL follows the only item
	ld [wCurrentMenuItem], a
	jp DisplayListMenuIDLoop.wrapAndWait
.noMovementUp
	call DisplayListMenuIDLoop.waitForDirectionRelease
	jp DisplayListMenuIDLoop.input
.regularUp
	ld hl, wListScrollOffset
	ld a, [hl]
	and a
	jp z, DisplayListMenuIDLoop.input ; no redraw at first entry
	dec [hl]
	jp DisplayListMenuIDLoop
.waitForDirectionRelease
	call DelayFrame
	call Joypad
	ldh a, [hJoyHeld]
	and D_UP | D_DOWN
	jr nz, .waitForDirectionRelease
	ret

; ROM-1.3: Preserve the original HOME interface and A return value.
DisplayChooseQuantityMenu::
	farcall DisplayChooseQuantityMenu_
	ld a, e
	ret

; PC and Mart description lists leave OAM suspended after ExitListMenu.
; State 3/$82 means the list is gone but its parent UI has not yet been revealed.
RestoreItemListSpritesAndUpdate::
	ld a, [wPCItemDescriptionSessionActive]
	cp 3
	jr z, .restoreSavedState
	cp $82
	jr z, .restoreSavedState
	call UpdateSprites ; no pending description list (e.g. first PC parent menu)
	ret
.restoreSavedState
	xor a
	ld [wPCItemDescriptionSessionActive], a
	ld a, [wPCItemDescriptionSavedSpritesEnabled]
	ld [wUpdateSpritesEnabled], a
	call UpdateSprites
	ret

ExitListMenu::
	ld a, [wCurrentMenuItem]
	ld [wChosenMenuItem], a
	ld a, CANCELLED_MENU
	ld [wMenuExitMethod], a
	ld [wMenuWatchMovingOutOfBounds], a
	xor a
	ldh [hJoy7], a
	ld hl, wd730
	res 6, [hl]
	farcall FinishPCItemDescriptions
	call BankswitchBack
	xor a
	ld [wMenuItemToSwap], a ; 0 means no item is currently being swapped
	scf
	ret

; ROM-1.3: Keep OldManItemList accessible in its original bank $0F.
PrintListMenuEntries::
	farjp PrintListMenuEntries_

ListMenuCancelText::
	db "CANCEL@"

; START Bag, Player PC and Mart item lists reuse one description flag.
UpdateStartBagDescriptionIfActive::
    ld a, [wStartBagDescriptionActive]
    and a
    ret z
    push bc
    push de
    push hl
    farcall UpdateSingleBagDescription
    pop hl
    pop de
    pop bc
    ret
