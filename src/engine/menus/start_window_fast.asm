; QOL-1.14: copy only the completed START window, never a dialogue window.
; On an actual 2x CGB, two transfers of nine rows each are used.
; This does not skip loading any font tiles or touch the Chinese DFS cache.
CopyStartMenuWindowFast::
	ldh a, [hCGB]
	and a
	jr z, .normal
	ldh a, [rKEY1]
	bit 7, a
	jr z, .normal
	ld a, [wAutoTextBoxDrawingControl]
	bit 0, a
	jr nz, .normal
	ldh a, [hRedrawRowOrColumnMode]
	and a
	jr nz, .normal
	ldh a, [hVBlankCopyBGSource]
	and a
	jr nz, .normal
	ldh a, [rLCDC]
	bit 7, a
	jr z, .normal

	ld b, $9c ; START window uses BG map 1.
	ld c, 9
	ld hl, $900 * 0 ; coordinates for row 0
	decoord 0, 0
	call .setup
	call DelayFrame
	call CaptureStartMenuInputIfEnabled

	ld b, $9c
	ld c, 9
	ld hl, $900 * 1 ; coordinates for row 9
	decoord 0, 9
	call .setup
	call DelayFrame
	call CaptureStartMenuInputIfEnabled
	ret
.normal
	ld b, $9c
	jp CopyScreenTileBufferToVRAM
.setup
	ld a, d
	ldh [hVBlankCopyBGSource + 1], a
	call GetRowColAddressBgMap
	ld a, l
	ldh [hVBlankCopyBGDest], a
	ld a, h
	ldh [hVBlankCopyBGDest + 1], a
	ld a, c
	ldh [hVBlankCopyBGNumRows], a
	ld a, e
	ldh [hVBlankCopyBGSource], a
	ret

; QOL-1.16A: Pokédex return helper. QOL-1.16B also reuses the final reveal stage
; after its own Party-specific restoration wrapper has disabled AutoBG transfer.
; The caller must restore the saved START tilemap/DFS glyphs and any overwritten
; overworld graphics under the white palette before entering this helper.
RestoreStartMenuFromPokedexWhite::
RestoreStartMenuFromWhite::
	ld a, 1
	ld [wStartMenuInputCapture], a
	farcall DrawStartMenu
	farcall PrintSafariZoneSteps
	call UpdateSprites
	; Put the intended Window position in hWY before the transfer waits. Both
	; CopyStartMenuWindowFast paths execute VBlank waits, so rWY is guaranteed
	; to be 0 before DMG's immediate palette reveal below.
	xor a
	ldh [hWY], a
	call CopyStartMenuWindowFast
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	; CGB consumes the mapped palette on VBlank. A one-frame DMG scanline split
	; was visible in direct frame capture but not in GBP/MyOldBoy normal playback;
	; this is accepted for now. Do not add a global palette wait for that artifact.
	jp LoadGBPal

; QOL-1.16B: Party's existing RestoreScreenTilesAndReloadTilePatterns helper
; finishes with AutoBG transfer enabled. Disable it before the shared START draw;
; leave the Pokédex caller and its already-disabled transfer state untouched.
RestoreStartMenuFromPartyWhite::
RestoreStartMenuFromTrainerWhite::
RestoreStartMenuFromOptionsWhite::
	xor a
	ldh [hAutoBGTransferEnabled], a
	jp RestoreStartMenuFromWhite


; QOL-1.16F: Bag is an overlay on top of the parent START/map view.  When item
; result text has dirtied CHS DFS slots, rebuild the parent while AutoBG transfer
; is disabled but keep the current Bag frame visible.  Only after the START text,
; cursor state and DFS glyphs are complete do we upload the repaired window.
; Unlike the full-screen submenu helpers above, this path never changes palette.
RestoreStartMenuFromItemNoWhite::
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld a, 1
	ld [wStartMenuInputCapture], a
	farcall DrawStartMenu
	farcall PrintSafariZoneSteps
	call UpdateSprites
	xor a
	ldh [hWY], a
	call CopyStartMenuWindowFast
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

; QOL-1.16C: Bag returns already have the exact START tilemap saved in Buffer2.
; Do not redraw text (which would churn DFS tiles while the Bag is still visible);
; rebuild only HandleMenuInput's state and cursor bookkeeping, then let the normal
; restored tilemap become the parent menu.
RestoreStartMenuInputStateFromSaved::
	ld a, 1
	ld [wStartMenuInputCapture], a
	ld a, D_DOWN | D_UP | START | B_BUTTON | A_BUTTON
	ld [wMenuWatchedKeys], a
	ld a, $02
	ld [wTopMenuItemY], a
	ld a, $0b
	ld [wTopMenuItemX], a
	ld a, [wBattleAndStartSavedMenuItem]
	ld [wCurrentMenuItem], a
	ld [wLastMenuItem], a
	xor a
	ld [wMenuWatchMovingOutOfBounds], a
	CheckEvent EVENT_GOT_POKEDEX
	ld a, $06
	jr z, .storeMenuItemCount
	inc a
.storeMenuItemCount
	ld [wMaxMenuItem], a

	; The submenu snapshot contains the parent's hollow cursor. Convert that cell
	; back to the active START cursor and restore the cursor address/under-tile state
	; without repainting the menu text.
	hlcoord 11, 2
	ld a, [wBattleAndStartSavedMenuItem]
	and a
	jr z, .cursorReady
	ld de, SCREEN_WIDTH * 2
.cursorRowLoop
	add hl, de
	dec a
	jr nz, .cursorRowLoop
.cursorReady
	ld a, l
	ld [wMenuCursorLocation], a
	ld a, h
	ld [wMenuCursorLocation + 1], a
	ld a, CHARVAL(" ")
	ld [wTileBehindCursor], a
	ld [hl], CHARVAL("▶")
	ret

; QOL-1.15C: the ordinary START border, labels and cursor live wholly in
; columns 10..19 of wTileMap. Use the existing wTileMapBackup2 for 18x10
; contiguous tile IDs. The Safari left-side counter takes the full-map path.
; These functions are only called from the initial safe START fast-close path.
SaveStartMenuRightHalf::
	hlcoord 10, 0
	ld de, wTileMapBackup2
	ld b, SCREEN_HEIGHT
.row
	ld c, 10
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy
	; Move from the just-copied column 20 to column 10 next row.
	ld a, l
	add 10
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	dec b
	jr nz, .row
	ret

RestoreStartMenuRightHalf::
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wTileMapBackup2
	decoord 10, 0
	ld b, SCREEN_HEIGHT
.row
	ld c, 10
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy
	; Skip the untouched left ten columns of the next wTileMap row.
	ld a, e
	add 10
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	dec b
	jr nz, .row
	ret
