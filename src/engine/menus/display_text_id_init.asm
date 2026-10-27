; function that performs initialization for DisplayTextID
DisplayTextIDInit::
	xor a
	ld [wListMenuID], a
	ld a, [wAutoTextBoxDrawingControl]
	bit 0, a
	jr nz, .skipDrawingTextBoxBorder
	ldh a, [hSpriteIndexOrTextID] ; text ID (or sprite ID)
	and a
	jr nz, .notStartMenu
; QOL-1.11: START border is drawn by DrawStartMenu.
; Keep the CHS debug hook, but skip the redundant early border.
IF DEF(_DEBUG)
	push af
	call DebugPressedOrHeldB
	jr z, .bIsNotPressed
	ld a,[wSimulatedJoypadStatesIndex]
	xor a,$FF
	ld [wSimulatedJoypadStatesIndex],a
.bIsNotPressed
	pop af
ENDC
	jr .skipDrawingTextBoxBorder
.notStartMenu
	hlcoord 0, 12
	ld b, $04
	ld c, $12
.drawTextBoxBorder
	call TextBoxBorder
.skipDrawingTextBoxBorder
	ld hl, wFontLoaded
	set 0, [hl]
	ld hl, wFlags_0xcd60
	bit 4, [hl]
	res 4, [hl]
	jr nz, .skipMovingSprites
	call UpdateSprites
.skipMovingSprites
; loop to copy [x#SPRITESTATEDATA1_FACINGDIRECTION] to
; [x#SPRITESTATEDATA2_ORIGFACINGDIRECTION] for each non-player sprite
; this is done because when you talk to an NPC, they turn to look your way
; the original direction they were facing must be restored after the dialogue is over
	ld hl, wSprite01StateData1FacingDirection
	ld c, $0f
	ld de, $10
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
	ld de, $10
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
	; QOL-1.11: keep START offscreen while CHS text is prepared.
	; The completed START window is copied once by RedisplayStartMenu.
	ldh a, [hSpriteIndexOrTextID]
	and a
	jr z, .startMenu
	; QOL-1.10 regular dialogue: unchanged font preloading and transfer.
	call LoadFontTilePatterns
	ld b, $9c
	call CopyScreenTileBufferToVRAM
	xor a
	ldh [hWY], a
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret
.startMenu
	ld a, $90
	ldh [hWY], a
	xor a
	ldh [hAutoBGTransferEnabled], a
	; Keep CHS glyph-cache invalidation, and upload the SAME 128 base
	; glyphs with RPP's 12-tiles/VBlank START-only transfer when safe.
	; Auto-text maps, ongoing BG redraws, and LCD-off paths stay on
	; the original 8-tiles/VBlank/font initialization path.
	ld a, [wAutoTextBoxDrawingControl]
	bit 0, a
	jr nz, .normalStartFont
	ldh a, [hRedrawRowOrColumnMode]
	and a
	jr nz, .normalStartFont
	ldh a, [hVBlankCopyBGSource]
	and a
	jr nz, .normalStartFont
	ldh a, [rLCDC]
	bit 7, a
	jr z, .normalStartFont
	callfar dfsClearCache
	ld de, FontGraphics
	ld hl, vFont
	lb bc, BANK(FontGraphics), (FontGraphicsEnd - FontGraphics) / $8
	call CopyVideoDataDoubleStartMenu
	ret
.normalStartFont
	call LoadFontTilePatterns
	ret
