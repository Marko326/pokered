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

	ld b, $9c
	ld c, 9
	ld hl, $900 * 1 ; coordinates for row 9
	decoord 0, 9
	call .setup
	jp DelayFrame
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
