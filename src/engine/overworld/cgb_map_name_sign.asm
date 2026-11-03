; ROM-1.30 CGB-only location sign (native CHS font, map-entry-only trigger).
; The DMG frame loop never calls this module. The CGB Window uses its own
; tile data in VRAM bank 1, instead of CHS DFS / NPC sprite tiles in bank 0.
; No new saved variables, no edits to the existing Town Map/Fly names.
; Formal ROM-1.30 second stage: 11 cities + Routes 1-25 plus five basic
; physical landmarks from RPP #214; floor-specific identities remain later work.

DEF MAP_NAME_SIGN_SPECIAL_BASE EQU $80
DEF MAP_NAME_SIGN_VIRIDIAN_FOREST EQU MAP_NAME_SIGN_SPECIAL_BASE + 0
DEF MAP_NAME_SIGN_MT_MOON         EQU MAP_NAME_SIGN_SPECIAL_BASE + 1
DEF MAP_NAME_SIGN_ROCK_TUNNEL     EQU MAP_NAME_SIGN_SPECIAL_BASE + 2
DEF MAP_NAME_SIGN_DIGLETTS_CAVE   EQU MAP_NAME_SIGN_SPECIAL_BASE + 3
DEF MAP_NAME_SIGN_POWER_PLANT     EQU MAP_NAME_SIGN_SPECIAL_BASE + 4
DEF MAP_NAME_SIGN_BASE_LABELS     EQU 36
DEF MAP_NAME_SIGN_SPECIAL_LABELS  EQU 5

UpdateCGBMapNameSign::
	ld a, [wMapNameSignInitialized]
	and a
	jr nz, .initialized
	inc a
	ld [wMapNameSignInitialized], a
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	ld a, $ff
	ld [wMapNameSignEffectiveMap], a
	; New Game / Continue should identify the current supported place once,
	; using the same short post-entry delay as Fly. Indoor maps are resolved
	; through the Town Map name table only when that name already has one of
	; this first-stage sign's 36 city/route labels.
	call MapNameSignResolveInitialMap
	jr nc, .initialNoPopup
	inc a ; store map id + 1 so PALLET_TOWN ($00) is representable
	ld [wMapNameSignInitialMap], a
	ld a, MAP_NAME_SIGN_FLY_DELAY + 1
	ld [wMapNameSignPending], a
	ret
.initialNoPopup
	xor a
	ld [wMapNameSignInitialMap], a
	ld [wMapNameSignPending], a
	ret

.initialized
	; A frame/step is not a map transition. Only the map loader arms it.
	ld a, [wMapNameSignPending]
	and a
	jr nz, .mapChanged

	ld a, [wMapNameSignTimer]
	and a
	ret z
	; Other code may already have reclaimed the Window.
	ldh a, [hWY]
	cp MAP_NAME_SIGN_Y
	jp nz, HideCGBMapNameSign
	ldh a, [rWY]
	cp MAP_NAME_SIGN_Y
	jp nz, HideCGBMapNameSign
	ldh a, [hAutoBGTransferEnabled]
	and a
	jp nz, HideCGBMapNameSign
	ld hl, wMapNameSignTimer
	dec [hl]
	ret nz
	jp HideCGBMapNameSign

.mapChanged
	; Fly and the first New Game / Continue popup share the same short delay.
	; Display time remains a full 120 frames once the sign is visible.
	cp 1
	jr z, .readyToDraw
	dec a
	ld [wMapNameSignPending], a
	ret
.readyToDraw
	; Startup may resolve a city/route or one of the five stage-2 physical
	; landmarks. Normal transitions use the same physical resolver, while all
	; other indoor maps remain neutral and preserve the previous landmark.
	ld a, [wMapNameSignInitialMap]
	and a
	jr z, .resolveCurrentMap
	dec a
	ld b, a
	xor a
	ld [wMapNameSignInitialMap], a
	jr .show

.resolveCurrentMap
	call MapNameSignResolveRuntimeMap
	jr nc, .notOutdoor
	ld a, [wMapNameSignEffectiveMap]
	cp b
	jr nz, .show
	; Same effective landmark cancels any old popup instead of re-showing it.
	ld a, b
	ld [wMapNameSignLastRawMap], a
	xor a
	ld [wMapNameSignPending], a
	jp HideCGBMapNameSign
.notOutdoor
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	xor a
	ld [wMapNameSignPending], a
	jp HideCGBMapNameSign

.show
	; Shared CGB Window is safe only when no menu/text/VRAM upload owns it.
	ldh a, [hAutoBGTransferEnabled]
	and a
	ret nz
	ldh a, [hRedrawRowOrColumnMode]
	and a
	ret nz
	ldh a, [hVBlankCopyBGSource]
	and a
	ret nz
	ldh a, [rLCDC]
	bit 7, a
	ret z
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	ld a, b
	ld [wMapNameSignEffectiveMap], a
	xor a
	ld [wMapNameSignPending], a

	; #215-style continuous refresh: if the previous sign is still visible,
	; keep its frame on screen while the new 36 glyph tiles are rendered into
	; the inactive bank-1 buffer. Switch only the 36 Window tile IDs in one
	; fresh VBlank, so the frame never disappears and partial glyph uploads are
	; never visible.
	ld a, [wMapNameSignAttrsActive]
	and a
	jr z, .showFresh
	ldh a, [hWY]
	cp MAP_NAME_SIGN_Y
	jr nz, .showFreshAfterReclaim
	ldh a, [rWY]
	cp MAP_NAME_SIGN_Y
	jr nz, .showFreshAfterReclaim
	call MapNameSignRefreshVisible
	ld a, MAP_NAME_SIGN_FRAMES
	ld [wMapNameSignTimer], a
	ret

.showFreshAfterReclaim
	call HideCGBMapNameSign
.showFresh
	; Fresh popup uses the original buffer and writes the complete frame/map.
	xor a
	ld [wMapNameSignLabelBuffer], a

	; Short direct VRAM writes are synchronized by STAT mode checks.
	; The normal interrupt handler assumes VBK 0: mask its interrupt source
	; until VBK is restored, without changing the caller's IME state.
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, 1
	ldh [rVBK], a
	; The CHS CGB palette 0 follows the Red/Blue overworld tint.
	; Unlike RPP, CHS palette 7 also holds a tinted boot palette, not a
	; neutral text palette. Use dedicated BG palette 5 for white/black.
	call MapNameSignSetNeutralPalette

	; Original textbox-border tiles $80-$88 and native DFS glyphs $90-$b3.
	ld hl, MapNameSignFrame1bpp
	ld de, $8800
	ld bc, 9 * 8
	call MapNameSignCopy1bppAsOpaque2bpp
	ld de, $8900
	call MapNameSignCopyCurrentLabelToVRAM

	; Tile IDs go into Window map 1 in bank 0, not the live map BG.
	xor a
	ldh [rVBK], a
	ld hl, MapNameSignWindowTiles
	ld de, $9c00
	ld b, 4
.copyTileRows
	push bc
	ld c, 20
.copyTileColumn
	ld a, [hli]
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .copyTileColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .copyTileRows

	; CGB attribute: neutral palette 5, VRAM bank 1, BG priority. Every pixel
	; of the sign uses color 1 or 3 (never 0), so sprites do not bleed
	; through the Window; no Bank $01 OAM logic needs modification.
	ld a, 1
	ldh [rVBK], a
	ld de, $9c00
	ld b, 4
.copyAttrRows
	push bc
	ld c, 20
.copyAttrColumn
	ld a, %10001101
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .copyAttrColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .copyAttrRows

	xor a
	ldh [rVBK], a
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ld a, 1
	ld [wMapNameSignAttrsActive], a
	ld a, MAP_NAME_SIGN_FRAMES
	ld [wMapNameSignTimer], a
	ld a, 7
	ldh [rWX], a
	ld a, MAP_NAME_SIGN_Y
	ldh [hWY], a
	ldh [rWY], a
	ret

; Resolve the currently loaded physical map to an effective sign identity.
; Carry set: B = supported identity. Carry clear: neutral/unsupported indoor map.
; Ordinary interiors and gates deliberately remain neutral, preserving the previous
; effective city/route/landmark until the player reaches another supported map.
MapNameSignResolveRuntimeMap:
	ld a, [wCurMap]
	cp FIRST_INDOOR_MAP
	jr nc, .special
	cp NUM_CITY_MAPS
	jr c, .external
	cp FIRST_ROUTE_MAP
	jr c, .unsupported ; unused raw map $0b
.external
	ld b, a
	scf
	ret

.special
	ld c, a
	ld hl, MapNameSignSpecialMapTable
.loop
	ld a, [hli]
	cp $ff
	jr z, .unsupported
	cp c
	jr z, .found
	inc hl
	jr .loop
.found
	ld b, [hl]
	scf
	ret
.unsupported
	and a ; clear carry
	ret

MapNameSignSpecialMapTable:
	; Stage 2 intentionally stops at five basic landmarks. Gate/entrance maps are
	; omitted so they inherit the previous landmark just like RPP #214 transit maps.
	db VIRIDIAN_FOREST, MAP_NAME_SIGN_VIRIDIAN_FOREST
	db MT_MOON_1F,      MAP_NAME_SIGN_MT_MOON
	db MT_MOON_B1F,     MAP_NAME_SIGN_MT_MOON
	db MT_MOON_B2F,     MAP_NAME_SIGN_MT_MOON
	db ROCK_TUNNEL_1F,  MAP_NAME_SIGN_ROCK_TUNNEL
	db ROCK_TUNNEL_B1F, MAP_NAME_SIGN_ROCK_TUNNEL
	db DIGLETTS_CAVE,   MAP_NAME_SIGN_DIGLETTS_CAVE
	db POWER_PLANT,     MAP_NAME_SIGN_POWER_PLANT
	db $ff

; Resolve the first map after New Game / Continue to a currently supported label.
; Stage-2 physical landmarks resolve directly; other indoor maps reuse the existing
; Town Map name only when it exactly matches one of the original 36 city/route labels.
; Returns carry set with A = supported effective identity; carry clear otherwise.
MapNameSignResolveInitialMap:
	; Prefer the physical resolver so Continue inside one of the five supported
	; landmarks identifies the landmark itself rather than a Town Map alias.
	call MapNameSignResolveRuntimeMap
	jr nc, .indoor
	ld a, b
	scf
	ret
.indoor
	ld a, [wCurMap]
	cp FIRST_INDOOR_MAP
	jr c, .unsupported
	ld de, wTownMapCoords
	farcall LoadTownMapEntry
	ld d, h
	ld e, l
	ld hl, MapNameSignTownMapNamePointers
	ld c, 0
.compareLoop
	ld a, [hli]
	cp e
	jr nz, .nextPointer
	ld a, [hl]
	cp d
	jr z, .foundPointer
.nextPointer
	inc hl
	inc c
	ld a, c
	cp 36
	jr c, .compareLoop
.unsupported
	and a ; clear carry
	ret
.foundPointer
	ld a, c
	cp NUM_CITY_MAPS
	jr c, .foundMap
	inc a ; skip unused raw map $0b before Route 1
.foundMap
	scf
	ret

; Render the current effective label into DE in VRAM bank 1.
MapNameSignCopyCurrentLabelToVRAM:
	push de
	ld a, [wMapNameSignEffectiveMap]
	cp MAP_NAME_SIGN_SPECIAL_BASE
	jr nc, .specialIndex
	cp FIRST_ROUTE_MAP
	jr c, .labelIndexReady
	dec a ; skip unused map $0b; routes follow the eleven cities
	jr .labelIndexReady
.specialIndex
	sub MAP_NAME_SIGN_SPECIAL_BASE
	add MAP_NAME_SIGN_BASE_LABELS
.labelIndexReady
	ld e, a
	ld d, 0
	ld hl, MapNameSignLabelPointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	ld bc, 18 * 2 * 8
	jp MapNameSignCopy1bppAsOpaque2bpp

; Keep the visible frame while changing landmarks. The inactive label buffer is
; safe to rewrite during visible scanlines; only the 36 tile IDs are swapped in
; one fresh VBlank.
MapNameSignRefreshVisible:
	; Keep interrupt sources masked from the bank-1 glyph upload through the
	; fresh-VBlank tile-ID swap, matching the #215 ownership rule.
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, [wMapNameSignLabelBuffer]
	xor 1
	ld [wMapNameSignLabelBuffer], a
	and a
	jr z, .buffer0
	ld de, $8b40 ; tile $b4, 36 tiles through $d7
	jr .bufferReady
.buffer0
	ld de, $8900 ; tile $90, 36 tiles through $b3
.bufferReady
	ld a, 1
	ldh [rVBK], a
	call MapNameSignCopyCurrentLabelToVRAM
	xor a
	ldh [rVBK], a

	; Match RPP #215's ownership rule: keep interrupt sources masked while
	; waiting for a *fresh* VBlank. If the normal VBlank handler runs first,
	; most of the transfer window is already gone and the two 18-tile rows can
	; be only partially switched, producing mixed top/bottom Chinese glyphs.
	call MapNameSignWaitFreshVBlank
	ld a, [wMapNameSignLabelBuffer]
	and a
	ld a, $90
	jr z, .tileBaseReady
	ld a, $b4
.tileBaseReady
	call MapNameSignWriteVisibleLabelTileIDs
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ret

; A = first tile id for the 36 label tiles. Called at the start of VBlank.
MapNameSignWriteVisibleLabelTileIDs:
	ld c, a
	ld de, $9c00 + BG_MAP_WIDTH + 1
	ld b, 18
.row1
	ld a, c
	ld [de], a
	inc c
	inc de
	dec b
	jr nz, .row1
	ld de, $9c00 + 2 * BG_MAP_WIDTH + 1
	ld b, 18
.row2
	ld a, c
	ld [de], a
	inc c
	inc de
	dec b
	jr nz, .row2
	ret

MapNameSignWaitFreshVBlank:
	; If called during the current VBlank, wait for it to end first so all 36
	; tile-ID writes belong to one new VBlank window.
.waitCurrentVBlankEnd
	ldh a, [rLY]
	cp 144
	jr nc, .waitCurrentVBlankEnd
.waitNextVBlank
	ldh a, [rLY]
	cp 144
	jr c, .waitNextVBlank
	ret

MapNameSignTownMapNamePointers:
	dw PalletTownName
	dw ViridianCityName
	dw PewterCityName
	dw CeruleanCityName
	dw LavenderTownName
	dw VermilionCityName
	dw CeladonCityName
	dw FuchsiaCityName
	dw CinnabarIslandName
	dw IndigoPlateauName
	dw SaffronCityName
	dw Route1Name
	dw Route2Name
	dw Route3Name
	dw Route4Name
	dw Route5Name
	dw Route6Name
	dw Route7Name
	dw Route8Name
	dw Route9Name
	dw Route10Name
	dw Route11Name
	dw Route12Name
	dw Route13Name
	dw Route14Name
	dw Route15Name
	dw Route16Name
	dw Route17Name
	dw Route18Name
	dw Route19Name
	dw Route20Name
	dw Route21Name
	dw Route22Name
	dw Route23Name
	dw Route24Name
	dw Route25Name

HideCGBMapNameSign::
	; Called explicitly before dialogue/START overwrites Window BG $9c00.
	xor a
	ld [wMapNameSignTimer], a
	ld a, [wMapNameSignAttrsActive]
	and a
	ret z
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ldh [rWY], a
	xor a
	ld [wMapNameSignAttrsActive], a
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, 1
	ldh [rVBK], a
	; Restore bank-zero Window ownership for all four modified rows.
	; START and dialogue continue using their existing screen tile writer.
	ld de, $9c00
	ld b, 4
.clearRows
	push bc
	ld c, 20
.clearColumn
	xor a
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .clearColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .clearRows
	xor a
	ldh [rVBK], a
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ret

; Palette 5 is private to this CGB-only Window.  Its color 1 is white
; (the opaque background) and its color 3 is black (the glyph/border ink).
; The 1bpp -> 2bpp blitter below produces only indexes 1 and 3.
MapNameSignSetNeutralPalette:
	ld a, $a8 ; index $28 = BG palette 5, enable auto-increment
	ldh [rBGPI], a
	ld hl, .colors
	ld b, 8
.copy
	ld a, [hli]
	call MapNameSignWaitVRAM
	ldh [rBGPD], a
	dec b
	jr nz, .copy
	ret
.colors
	RGB 31, 31, 31 ; color 0: white (unused)
	RGB 31, 31, 31 ; color 1: opaque white background
	RGB 16, 16, 16 ; color 2: gray (unused)
	RGB  0,  0,  0 ; color 3: black ink

; Wait for VRAM access in visible scanline modes. Preserve the byte in A.
MapNameSignWaitVRAM:
	push af
.wait
	ldh a, [rSTAT]
	and %10
	jr nz, .wait
	pop af
	ret

; 1bpp input rows -> opaque bank-1 2bpp output rows:
; background color 1 and ink color 3, both higher priority than OBJ.
MapNameSignCopy1bppAsOpaque2bpp:
.copyRow
	ld a, $ff
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	ld a, [hli]
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyRow
	ret

MapNameSignSkipMapRowPadding:
	ld a, e
	add 32 - 20
	ld e, a
	ret nc
	inc d
	ret

MapNameSignDropPendingVBlank:
	ld a, [rIF]
	res VBLANK, a
	ld [rIF], a
	ret

MapNameSignWindowTiles:
	db $85
	REPT 18
		db $81
	ENDR
	db $86
	db $83
	FOR i, 18
		db $90 + i
	ENDR
	db $84
	db $83
	FOR i, 18
		db $a2 + i
	ENDR
	db $84
	db $87
	REPT 18
		db $82
	ENDR
	db $88

MapNameSignFrame1bpp:
	INCBIN "gfx/map_name_sign/frame.1bpp"
MapNameSignFrameEnd:
	ASSERT MapNameSignFrameEnd - MapNameSignFrame1bpp == 9 * 8
MapNameSignLabelPointers:
	FOR i, MAP_NAME_SIGN_BASE_LABELS + MAP_NAME_SIGN_SPECIAL_LABELS
		dw MapNameSignLabelData + i * (18 * 2 * 8)
	ENDR
MapNameSignLabelData:
	; Index 0..10: towns; 11..35: Routes 1..25.
	; Index 36..40: 常青森林, 月见山, 岩山隧道, 地鼠洞穴, 无人发电厂.
	INCBIN "gfx/map_name_sign/labels.1bpp"
MapNameSignLabelDataEnd:
	ASSERT MapNameSignLabelDataEnd - MapNameSignLabelData == (MAP_NAME_SIGN_BASE_LABELS + MAP_NAME_SIGN_SPECIAL_LABELS) * 18 * 2 * 8
