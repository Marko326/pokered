ActivatePC::
	call SaveScreenTilesToBuffer2
	ld a, SFX_TURN_ON_PC
	call PlaySound
	ld hl, TurnedOnPC1Text
	call PrintText
	call WaitForSoundToFinish
	ld hl, wFlags_0xcd60
	set 3, [hl]
	call LoadScreenTilesFromBuffer2
	call Delay3
PCMainMenu:
	farcall DisplayPCMainMenu
	ld hl, wFlags_0xcd60
	set 5, [hl]
	call HandleMenuInput
	bit BIT_B_BUTTON, a
	jp nz, LogOff
	ld a, [wMaxMenuItem]
	cp 2
	jr nz, .next ;if not 2 menu items (not counting log off) (2 occurs before you get the pokedex)
	ld a, [wCurrentMenuItem]
	and a
	jp z, BillsPC    ;if current menu item id is 0, it's bills pc
	cp 1
	jr z, .playersPC ;if current menu item id is 1, it's players pc
	jp LogOff        ;otherwise, it's 2, and you're logging off
.next
	cp 3
	jr nz, .next2 ;if not 3 menu items (not counting log off) (3 occurs after you get the pokedex, before you beat the pokemon league)
	ld a, [wCurrentMenuItem]
	and a
	jp z, BillsPC    ;if current menu item id is 0, it's bills pc
	cp 1
	jr z, .playersPC ;if current menu item id is 1, it's players pc
	cp 2
	jp z, OaksPC     ;if current menu item id is 2, it's oaks pc
	jp LogOff        ;otherwise, it's 3, and you're logging off
.next2
	ld a, [wCurrentMenuItem]
	and a
	jp z, BillsPC    ;if current menu item id is 0, it's bills pc
	cp 1
	jr z, .playersPC ;if current menu item id is 1, it's players pc
	cp 2
	jp z, OaksPC     ;if current menu item id is 2, it's oaks pc
	cp 3
	jp z, PKMNLeague ;if current menu item id is 3, it's pkmnleague
	jp LogOff        ;otherwise, it's 4, and you're logging off
.playersPC
	ld hl, wFlags_0xcd60
	res 5, [hl]
	set 3, [hl]
	ld a, SFX_ENTER_PC
	call PlaySound
	call WaitForSoundToFinish
	ld hl, AccessedMyPCText
	call PrintText
	farcall PlayerPC
	jr ReloadMainMenu
OaksPC:
	ld a, SFX_ENTER_PC
	call PlaySound
	call WaitForSoundToFinish
	farcall OpenOaksPC
	jr ReloadMainMenu
PKMNLeague:
	ld a, SFX_ENTER_PC
	call PlaySound
	call WaitForSoundToFinish
	farcall PKMNLeaguePC
	; Hall of Fame front pictures overwrite overworld tileset patterns.
	; Keep the proven graphics reload until the separate HoF return fix.
	call ReloadMapData
	jr ReloadMainMenu
BillsPC:
	ld a, SFX_ENTER_PC
	call PlaySound
	call WaitForSoundToFinish
	CheckEvent EVENT_MET_BILL
	jr nz, .billsPC ;if you've met bill, use that bill's instead of someone's
	ld hl, AccessedSomeonesPCText
	jr .printText
.billsPC
	ld hl, AccessedBillsPCText
.printText
	call PrintText
	farcall BillsPC_
ReloadMainMenu:
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	; RPP #112, CHS adaptation: no LCD-off map reload while PC owns UI.
	; Restore the PC session's saved background in WRAM only; the next
	; DisplayPCMainMenu composes the full menu before BG transfer resumes.
	call LoadScreenTilesFromBuffer2DisableBGTransfer
	; DisplayPCMainMenu updates OAM after the menu border is prepared.
	; Do not expose an intermediate sprite/map combination on DMG.
	jp PCMainMenu
LogOff:
	ld a, SFX_TURN_OFF_PC
	call PlaySound
	call WaitForSoundToFinish
	ld hl, wFlags_0xcd60
	res 3, [hl]
	res 5, [hl]
	; Keep the LCD enabled while restoring the overworld. Pokémon status
	; pages reuse vChars2, which aliases the overworld text-box tile range.
	; Restore those patterns through VBlank before redrawing the map.
	; Hide OAM during the row-by-row BG redraw so DMG cannot show map
	; sprites against a partially restored background.
	ld a, [wUpdateSpritesEnabled]
	push af
	xor a
	ld [wUpdateSpritesEnabled], a
	call HideSprites
	call DelayFrame
	call LoadTextBoxTilePatterns
	farcall RedrawMapView
	pop af
	ld [wUpdateSpritesEnabled], a
	cp 1
	jr nz, .done
	call UpdateSprites
.done
	ret

TurnedOnPC1Text:
	text_far _TurnedOnPC1Text
	text_end

AccessedBillsPCText:
	text_far _AccessedBillsPCText
	text_end

AccessedSomeonesPCText:
	text_far _AccessedSomeonesPCText
	text_end

AccessedMyPCText:
	text_far _AccessedMyPCText
	text_end

; removes one of the specified item ID [hItemToRemoveID] from bag (if existent)
RemoveItemByID::
	ld hl, wBagItems
	ldh a, [hItemToRemoveID]
	ld b, a
	xor a
	ldh [hItemToRemoveIndex], a
.loop
	ld a, [hli]
	cp -1 ; reached terminator?
	ret z
	cp b
	jr z, .foundItem
	inc hl
	ldh a, [hItemToRemoveIndex]
	inc a
	ldh [hItemToRemoveIndex], a
	jr .loop
.foundItem
	ld a, $1
	ld [wItemQuantity], a
	ldh a, [hItemToRemoveIndex]
	ld [wWhichPokemon], a
	ld hl, wNumBagItems
	jp RemoveItemFromInventory
