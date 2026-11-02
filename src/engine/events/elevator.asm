DisplayElevatorFloorMenu:
	ld hl, WhichFloorText
	call PrintText
	ld hl, wItemList
	ld a, l
	ld [wListPointer], a
	ld a, h
	ld [wListPointer + 1], a
	ld a, [wListScrollOffset]
	push af
	xor a
	ld [wCurrentMenuItem], a
	ld [wListScrollOffset], a
	; Highlight the elevator's current exit floor on each new open.
	call RestoreElevatorFloorMenuPosition
	xor a
	ld [wPrintItemPrices], a
	ld a, SPECIALLISTMENU
	ld [wListMenuID], a
	call DisplayListMenuID
	pop bc
	ld a, b
	ld [wListScrollOffset], a
	ret c
	ld hl, wCurrentMapScriptFlags
	set 7, [hl]
	ld hl, wElevatorWarpMaps
	ld a, [wWhichPokemon]
	add a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld c, a
	ld hl, wWarpEntries
	call .UpdateWarp

.UpdateWarp
	inc hl
	inc hl
	ld a, b
	ld [hli], a ; destination warp ID
	ld a, c
	ld [hli], a ; destination map ID
	ret

WhichFloorText:
	text_far _WhichFloorText
	text_end

; Match the map ID of the elevator's current door against the destination
; table copied by the current elevator script.  Each entry is warp ID/map ID.
; DisplayListMenuID has three visible selection rows; put later floors on row 2
; and keep early floors at their natural row.  A missing match leaves row 0.
RestoreElevatorFloorMenuPosition:
	ld a, [wWarpEntries + 3] ; first door's destination map: current floor
	ld c, a
	ld a, [wItemList] ; actual floor count (does not include Cancel)
	ld b, a
	ld hl, wElevatorWarpMaps + 1 ; first destination map byte
	ld d, 0 ; zero-based floor index
.scan
	ld a, b
	and a
	ret z ; unknown map: preserve the default top position
	ld a, [hl]
	cp c
	jr z, .found
	inc hl
	inc hl ; skip warp ID of the next destination
	inc d
	dec b
	jr .scan
.found
	ld a, d
	cp 3
	jr c, .storeRow
	sub 2
	ld [wListScrollOffset], a
	ld a, 2
.storeRow
	ld [wCurrentMenuItem], a
	ret
