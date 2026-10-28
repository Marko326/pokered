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
