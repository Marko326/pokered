; this function is used to display sign messages, sprite dialog, etc.
; INPUT: [hSpriteIndex] = sprite ID or [hTextID] = text ID
DisplayTextID::
	ASSERT hSpriteIndex == hTextID ; these are at the same memory location
	ldh a, [hLoadedROMBank]
	push af
	farcall DisplayTextIDInit ; initialization
	ld hl, wTextPredefFlag
	bit BIT_TEXT_PREDEF, [hl]
	res BIT_TEXT_PREDEF, [hl]
	jr nz, .skipSwitchToMapBank
	ld a, [wCurMap]
	call SwitchToMapRomBank
.skipSwitchToMapBank
	ld a, 30 ; half a second
	ldh [hFrameCounter], a ; used as joypad poll timer
	ld hl, wCurMapTextPtr
	ld a, [hli]
	ld h, [hl]
	ld l, a ; hl = map text pointer
	ld d, $00
	ldh a, [hTextID]
	ld [wSpriteIndex], a

	dict TEXT_START_MENU,       DisplayStartMenu
	dict TEXT_SAFARI_GAME_OVER, DisplaySafariGameOverText
	dict TEXT_MON_FAINTED,      DisplayPokemonFaintedText
	dict TEXT_BLACKED_OUT,      DisplayPlayerBlackedOutText
	dict TEXT_REPEL_WORE_OFF,   DisplayRepelWoreOffText

	ld a, [wNumSprites]
	ld e, a
	ldh a, [hSpriteIndex] ; sprite ID
	cp e
	jr z, .spriteHandling
	jr nc, .skipSpriteHandling
.spriteHandling
; get the text ID of the sprite
	push hl
	push de
	push bc
	farcall UpdateSpriteFacingOffsetAndDelayMovement ; update the graphics of the sprite the player is talking to (to face the right direction)
	pop bc
	pop de
	ld hl, wMapSpriteData ; NPC text entries
	ldh a, [hSpriteIndex]
	dec a
	add a
	add l
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	inc hl
	ld a, [hl] ; a = text ID of the sprite
	pop hl
.skipSpriteHandling
; look up the address of the text in the map's text entries
	dec a
	ld e, a
	sla e
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a ; hl = address of the text
	ld a, [hl] ; a = first byte of text

; check first byte of text for special cases

MACRO dict2
	cp \1
	jr nz, .not\@
	\2
	jr AfterDisplayingTextID
.not\@
ENDM

	dict  TX_SCRIPT_MART,                    DisplayPokemartDialogue
	dict  TX_SCRIPT_POKECENTER_NURSE,        DisplayPokemonCenterDialogue
	dict  TX_SCRIPT_PLAYERS_PC,              TextScript_ItemStoragePC
	dict  TX_SCRIPT_BILLS_PC,                TextScript_BillsPC
	dict  TX_SCRIPT_POKECENTER_PC,           TextScript_PokemonCenterPC
	dict2 TX_SCRIPT_VENDING_MACHINE,         farcall VendingMachineMenu
	dict  TX_SCRIPT_PRIZE_VENDOR,            TextScript_GameCornerPrizeMenu
	dict2 TX_SCRIPT_CABLE_CLUB_RECEPTIONIST, callfar CableClubNPC

	call PrintText_NoCreatingTextBox
	ld a, [wDoNotWaitForButtonPressAfterDisplayingText]
	and a
	jr nz, HoldTextDisplayOpen

AfterDisplayingTextID::
	ld a, [wEnteringCableClub]
	and a
	jr nz, HoldTextDisplayOpen
	call WaitForTextScrollButtonPress

; loop to hold the dialogue box open as long as the player keeps holding down the A button
HoldTextDisplayOpen::
	call Joypad
	ldh a, [hJoyHeld]
	bit B_PAD_A, a
	jr nz, HoldTextDisplayOpen

CloseTextDisplay::
	ld a, [wCurMap]
	call SwitchToMapRomBank
	ld a, $90
	ldh [hWY], a ; move the window off the screen
	call DelayFrame
	call LoadGBPal
	xor a
	ldh [hAutoBGTransferEnabled], a ; disable continuous WRAM to VRAM transfer each V-blank
; loop to make sprites face the directions they originally faced before the dialogue
	ld hl, wSprite01StateData2OrigFacingDirection
	ld c, NUM_SPRITESTATEDATA_STRUCTS - 1
	ld de, SPRITESTATEDATA1_LENGTH
.restoreSpriteFacingDirectionLoop
	ld a, [hl] ; x#SPRITESTATEDATA2_ORIGFACINGDIRECTION
	dec h
	ld [hl], a ; [x#SPRITESTATEDATA1_FACINGDIRECTION]
	inc h
	add hl, de
	dec c
	jr nz, .restoreSpriteFacingDirectionLoop
	ld a, BANK(InitMapSprites)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call InitMapSprites ; reload sprite tile pattern data (since it was partially overwritten by text tile patterns)
	ld hl, wFontLoaded
	res BIT_FONT_LOADED, [hl]
	ld a, [wStatusFlags6]
	bit BIT_FLY_WARP, a
	call z, LoadPlayerSpriteGraphics
	call LoadCurrentMapView
	pop af
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	jp UpdateSprites

; MEN-1.10: direct START close. Window only touched BG1, so BG0 needs
; no map redraw; the font did replace upper NPC sprite patterns (GB VRAM).
; Caller restored wTileMap from wTileMapBackup2. Stack matches CloseTextDisplay.
CloseTextDisplayFastStart::
	ld a, [wCurMap]
	call SwitchToMapRomBank
	ld a, $90
	ldh [hWY], a
	call DelayFrame
	call LoadGBPal
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wSprite01StateData2OrigFacingDirection
	ld c, NUM_SPRITESTATEDATA_STRUCTS - 1
	ld de, SPRITESTATEDATA1_LENGTH
.restoreSpriteFacingDirectionLoop
	ld a, [hl]
	dec h
	ld [hl], a
	inc h
	add hl, de
	dec c
	jr nz, .restoreSpriteFacingDirectionLoop
	ld a, BANK(InitMapSprites)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call InitMapSprites
	xor a
	ld [wStartMenuPartialSpriteRestore], a ; MEN-1.10: prevent state leakage
	ld hl, wFontLoaded
	res BIT_FONT_LOADED, [hl]
	; MEN-1.10: InitMapSprites restores NPC tiles, not the player.
	; START overwrites Bank-0 vNPCSprites2, including the player's
	; walking tiles at $8800-$88bf. Restore them before resuming play.
	ld a, [wStatusFlags6]
	bit BIT_FLY_WARP, a
	jr nz, .playerReady
	ld a, [wWalkBikeSurfState]
	and a
	jr nz, .reloadPlayer
	; Walking: only the second 12-tile half was overwritten by font.
	; Keep the unchanged standing sprites; restore the walking half.
	ld de, RedSprite + $c0
	ld hl, vNPCSprites2
	lb bc, BANK(RedSprite), 12
	call CopyVideoData
	jr .playerReady
.reloadPlayer
	; Bike and surf have different graphics and state checks.
	call LoadPlayerSpriteGraphics
.playerReady
	pop af
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	jp UpdateSprites

DisplayPokemartDialogue::
	push hl
	ld hl, PokemartGreetingText
	call PrintText
	pop hl
	inc hl
	call LoadItemList
	ld a, PRICEDITEMLISTMENU
	ld [wListMenuID], a
	homecall DisplayPokemartDialogue_
	jp AfterDisplayingTextID

PokemartGreetingText::
	text_far _PokemartGreetingText
	text_end

LoadItemList::
	ld a, 1
	ld [wUpdateSpritesEnabled], a
	ld a, h
	ld [wItemListPointer], a
	ld a, l
	ld [wItemListPointer + 1], a
	ld de, wItemList
.loop
	ld a, [hli]
	ld [de], a
	inc de
	cp $ff
	jr nz, .loop
	ret

DisplayPokemonCenterDialogue::
; zeroing these doesn't appear to serve any purpose
	xor a
	ldh [hItemPrice], a
	ldh [hItemPrice + 1], a
	ldh [hItemPrice + 2], a

	inc hl
	homecall DisplayPokemonCenterDialogue_
	jp AfterDisplayingTextID

DisplaySafariGameOverText::
	callfar PrintSafariGameOverText
	jp AfterDisplayingTextID

DisplayPokemonFaintedText::
	ld hl, PokemonFaintedText
	call PrintText
	jp AfterDisplayingTextID

PokemonFaintedText::
	text_far _PokemonFaintedText
	text_end

DisplayPlayerBlackedOutText::
	ld hl, PlayerBlackedOutText
	call PrintText
	ld a, [wStatusFlags6]
	res BIT_ALWAYS_ON_BIKE, a
	ld [wStatusFlags6], a
	jp HoldTextDisplayOpen

PlayerBlackedOutText::
	text_far _PlayerBlackedOutText
	text_end

DisplayRepelWoreOffText::
	ld hl, RepelWoreOffText
	call PrintText
	jp AfterDisplayingTextID

RepelWoreOffText::
	text_far _RepelWoreOffText
	text_end
