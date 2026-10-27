DisplayStartMenu::
	ld a, BANK(StartMenu_Pokedex)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ld a, [wWalkBikeSurfState] ; walking/biking/surfing
	ld [wWalkBikeSurfStateCopy], a
	; QOL-1.13A: preserve the overworld for a direct B/START/EXIT close.
	; Any pending redraw/special text state uses the original full close.
	ld a, 1
	ld [wStartMenuCloseMode], a
	ld a, [wAutoTextBoxDrawingControl]
	bit 0, a
	jr nz, .startSound
	ldh a, [hRedrawRowOrColumnMode]
	and a
	jr nz, .startSound
	ldh a, [hVBlankCopyBGSource]
	and a
	jr nz, .startSound
	xor a
	ld [wStartMenuCloseMode], a
	call SaveScreenTilesToBuffer2
.startSound
	ld a, SFX_START_MENU
	call PlaySound

RedisplayStartMenu::
	; QOL-1.11: prevent progressive CHS menu drawing from reaching the LCD.
	ld a, $90
	ldh [hWY], a
	xor a
	ldh [hAutoBGTransferEnabled], a
	call DelayFrame ; finish hiding before touching the menu's glyph tiles
	farcall DrawStartMenu
	farcall PrintSafariZoneSteps ; print Safari Zone info, if in Safari Zone
	; QOL-1.11: mark NPC sprites behind the finished menu as hidden
	; before the three VBlanks used to transfer the window tilemap.
	; OAM will be refreshed before the window is revealed.
	call UpdateSprites
	; Copy the finished window once, then reveal it. This replaces the
	; redundant 3-frame empty-window copy on initial START opening.
	ld b, $9c
	call CopyScreenTileBufferToVRAM
	xor a
	ldh [hWY], a
	inc a
	ldh [hAutoBGTransferEnabled], a
.loop
	call HandleMenuInput
	ld b, a
.checkIfUpPressed
	bit BIT_D_UP, a
	jr z, .checkIfDownPressed
	ld a, [wCurrentMenuItem] ; menu selection
	and a
	jr nz, .loop
	ld a, [wLastMenuItem]
	and a
	jr nz, .loop
; if the player pressed tried to go past the top item, wrap around to the bottom
	CheckEvent EVENT_GOT_POKEDEX
	ld a, 6 ; there are 7 menu items with the pokedex, so the max index is 6
	jr nz, .wrapMenuItemId
	dec a ; there are only 6 menu items without the pokedex
.wrapMenuItemId
	ld [wCurrentMenuItem], a
	call EraseMenuCursor
	jr .loop
.checkIfDownPressed
	bit BIT_D_DOWN, a
	jr z, .buttonPressed
; if the player pressed tried to go past the bottom item, wrap around to the top
	CheckEvent EVENT_GOT_POKEDEX
	ld a, [wCurrentMenuItem]
	ld c, 7 ; there are 7 menu items with the pokedex
	jr nz, .checkIfPastBottom
	dec c ; there are only 6 menu items without the pokedex
.checkIfPastBottom
	cp c
	jr nz, .loop
; the player went past the bottom, so wrap to the top
	xor a
	ld [wCurrentMenuItem], a
	call EraseMenuCursor
	jr .loop
.buttonPressed ; A, B, or Start button pressed
	call PlaceUnfilledArrowMenuCursor
	ld a, [wCurrentMenuItem]
	ld [wBattleAndStartSavedMenuItem], a ; save current menu selection
	ld a, b
	and B_BUTTON | START ; was the Start button or B button pressed?
	jp nz, CloseStartMenu
	CheckEvent EVENT_GOT_POKEDEX
	ld a, [wCurrentMenuItem]
	jr nz, .displayMenuItem
	inc a ; adjust position to account for missing pokedex menu item
.displayMenuItem
	cp 6 ; EXIT: do not overwrite the preserved overworld snapshot
	jp z, CloseStartMenu
	; Entering a submenu invalidates the direct-close shortcut.
	push af
	ld a, 1
	ld [wStartMenuCloseMode], a
	call SaveScreenTilesToBuffer2 ; preserve START for submenu return
	pop af
	cp 0
	jp z, StartMenu_Pokedex
	cp 1
	jp z, StartMenu_Pokemon
	cp 2
	jp z, StartMenu_Item
	cp 3
	jp z, StartMenu_TrainerInfo
	cp 4
	jp z, StartMenu_SaveReset
	cp 5
	jp z, StartMenu_Option

; EXIT falls through to here
CloseStartMenu::
	call Joypad
	ldh a, [hJoyPressed]
	bit BIT_A_BUTTON, a
	jr nz, CloseStartMenu
	ld a, [wStartMenuCloseMode]
	and a
	jr nz, .fullClose
	; BG map is untouched by the START window. Restore its WRAM tilemap
	; instead of rebuilding the map from block graphics on direct close.
	call LoadScreenTilesFromBuffer2DisableBGTransfer
	ld a, 2
	ld [wStartMenuCloseMode], a
	; QOL-1.13E: direct close already restored the map tilemap.
	; Skip LoadCurrentMapView; submenu/special close keeps full restore.
	jp CloseTextDisplayFastStart
.fullClose
	call LoadTextBoxTilePatterns
	jp CloseTextDisplay
