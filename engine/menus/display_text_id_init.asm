; function that performs initialization for DisplayTextID
DisplayTextIDInit::
	xor a
	ld [wListMenuID], a
	; MEN-1.10: only a normal START session can use the quick-close path.
	ldh a, [hTextID]
	and a
	jr nz, .checkTextBox
	ld a, $91
	ldh [hWY], a ; keep START Window offscreen while loading the font
	xor a
	ld [wStartMenuFullRestoreFlag], a
	ld [wStartMenuPartialSpriteRestore], a
	ld a, [wAutoTextBoxDrawingControl]
	bit BIT_NO_AUTO_TEXT_BOX, a
	jr z, .checkPendingRedraw
	jr .needsFullRestore
.checkPendingRedraw
	ldh a, [hRedrawRowOrColumnMode]
	and a
	jr nz, .needsFullRestore
	ldh a, [hVBlankCopyBGSource]
	and a
	jr z, .checkTextBox
.needsFullRestore
	ld a, 1
	ld [wStartMenuFullRestoreFlag], a
.checkTextBox
	ld a, [wAutoTextBoxDrawingControl]
	bit BIT_NO_AUTO_TEXT_BOX, a
	jr nz, .skipDrawingTextBoxBorder
	ldh a, [hTextID]
	and a
	jr z, .skipDrawingTextBoxBorder ; MEN-1.10: START border is drawn once.
; if text ID is not 0, draw the standard dialogue box
.notStartMenu
	hlcoord 0, 12
	ld b, $04
	ld c, $12
	call TextBoxBorder
.skipDrawingTextBoxBorder
	ld hl, wFontLoaded
	set BIT_FONT_LOADED, [hl]
	ld hl, wMiscFlags
	bit BIT_NO_SPRITE_UPDATES, [hl]
	res BIT_NO_SPRITE_UPDATES, [hl]
	jr nz, .skipMovingSprites
	call UpdateSprites
.skipMovingSprites
; loop to copy [x#SPRITESTATEDATA1_FACINGDIRECTION] to
; [x#SPRITESTATEDATA2_ORIGFACINGDIRECTION] for each non-player sprite
; this is done because when you talk to an NPC, they turn to look your way
; the original direction they were facing must be restored after the dialogue is over
	ld hl, wSprite01StateData1FacingDirection
	ld c, NUM_SPRITESTATEDATA_STRUCTS - 1
	ld de, SPRITESTATEDATA1_LENGTH
.spriteFacingDirectionCopyLoop
	ld a, [hl] ; x#SPRITESTATEDATA1_FACINGDIRECTION
	inc h
	ld [hl], a ; [x#SPRITESTATEDATA2_ORIGFACINGDIRECTION]
	dec h
	add hl, de
	dec c
	jr nz, .spriteFacingDirectionCopyLoop
; loop to force all the sprites in the middle of animation to stand still
; (so that they don't like they're frozen mid-step during the dialogue)
	ld hl, wSpritePlayerStateData1ImageIndex
	ld de, SPRITESTATEDATA1_LENGTH
	ASSERT NUM_SPRITESTATEDATA_STRUCTS == SPRITESTATEDATA1_LENGTH
	ld c, e
.spriteStandStillLoop
	ld a, [hl]
	cp $ff ; is the sprite visible?
	jr z, .nextSprite
; if it is visible
	and $fc
	ld [hl], a
.nextSprite
	add hl, de
	dec c
	jr nz, .spriteStandStillLoop
	; MEN-1.10: load only the glyphs needed for START, with a
	; full-font fallback for special names and pending graphics redraws.
	ldh a, [hTextID]
	and a
	jr nz, .regularText
	ld a, [wAutoTextBoxDrawingControl]
	bit BIT_NO_AUTO_TEXT_BOX, a
	jr nz, .regularText
	ld a, [wStartMenuFullRestoreFlag]
	and a
	jr nz, .regularStartFont
	call LoadStartMenuFontFast
	jr .startFontReady
.regularStartFont
	xor a
	ld [wStartMenuPartialSpriteRestore], a
	call LoadFontTilePatterns
.startFontReady
	; MEN-1.10: normal START needs only the existing three-frame
	; menu refresh in HandleMenuInput; skip the earlier bare-map copy.
	; Special/pending-map-redraw START sessions retain the safe legacy copy.
	ld a, [wStartMenuFullRestoreFlag]
	and a
	jr z, .firstWindowCopyDone
	ld b, HIGH(vBGMap1)
	call CopyScreenTileBufferToVRAM
.firstWindowCopyDone
	ld a, $91
	ldh [hWY], a
	jr .startTransfer
.regularText
	; QOL-1.18A: load the font before exposing the normal dialogue window.
	call LoadFontTilePatterns
	ld b, HIGH(vBGMap1)
	call CopyScreenTileBufferToVRAM
	xor a
	ldh [hWY], a
.startTransfer
	ld a, $01
	ldh [hAutoBGTransferEnabled], a ; enable continuous WRAM to VRAM transfer each V-blank
	ret

; MEN-1.10: GB START font subset. No CGB VRAM Bank 1 dependency.
; A-Z, e-acute and cursor are always used. Load lowercase/numerics only
; if the player name or Safari overlay needs them. Exotic names use full font.
LoadStartMenuFontFast::
	ld hl, wPlayerName
	ld d, 0 ; bit 0: lowercase; bit 1: numeric/Safari glyphs
	ld c, NAME_LENGTH + 1 ; malformed/unterminated names fall back safely
.scanName
	dec c
	jp z, .fullFont
	ld a, [hli]
	cp '@'
	jr z, .nameDone
	cp ' '
	jr z, .scanName
	cp 'A'
	jp c, .fullFont
	cp 'Z' + 1
	jr c, .scanName
	cp 'a'
	jp c, .fullFont
	cp 'z' + 1
	jr nc, .checkSpecial
	set 0, d
	jr .scanName
.checkSpecial
	cp 'é'
	jr z, .scanName
	cp '▷'
	jr z, .scanName
	cp '▶'
	jr z, .scanName
	cp '×'
	jp c, .fullFont
	; $f1-$ff includes Safari indicators and digits.
	set 1, d
	jr .scanName
.nameDone
	ld a, [wCurMap]
	cp SAFARI_ZONE_EAST
	jr c, .loadFast
	cp CERULEAN_CAVE_2F
	jr nc, .loadFast
	set 1, d
.loadFast
	; Bit 0: subset; bit 1: lowercase; bit 2: digits/Safari.
	ld a, d
	add a
	inc a
	ld [wStartMenuPartialSpriteRestore], a
	push de
	ld de, FontGraphics
	ld hl, vFont
	lb bc, BANK(FontGraphics), 26 ; A-Z
	call CopyVideoDataDouble
	ld de, FontGraphics + ('é' - 'A') * TILE_1BPP_SIZE
	ld hl, vFont tile ('é' - 'A')
	lb bc, BANK(FontGraphics), 1
	call CopyVideoDataDouble
	ld de, FontGraphics + ('▷' - 'A') * TILE_1BPP_SIZE
	ld hl, vFont tile ('▷' - 'A')
	lb bc, BANK(FontGraphics), 2 ; hollow and filled cursors
	call CopyVideoDataDouble
	pop de
	bit 0, d
	jr z, .checkDigits
	push de
	ld de, FontGraphics + ('a' - 'A') * TILE_1BPP_SIZE
	ld hl, vFont tile ('a' - 'A')
	lb bc, BANK(FontGraphics), 26
	call CopyVideoDataDouble
	pop de
.checkDigits
	bit 1, d
	ret z
	ld de, FontGraphics + ('×' - 'A') * TILE_1BPP_SIZE
	ld hl, vFont tile ('×' - 'A')
	lb bc, BANK(FontGraphics), 15 ; ×, /, and 0-9 (Safari/name)
	jp CopyVideoDataDouble
.fullFont
	xor a
	ld [wStartMenuPartialSpriteRestore], a
	jp LoadFontTilePatterns
