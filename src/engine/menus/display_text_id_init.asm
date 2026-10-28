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
	; QOL-1.15D: begin recording a distinct second START edge while
	; fixed/dynamic fonts and the menu window are transferred.
	ld a, 1
	ld [wStartMenuInputCapture], a
	xor a
	ld [wStartMenuClosePending], a
	ld a, $90
	ldh [hWY], a
	xor a
	ldh [hAutoBGTransferEnabled], a
	; QOL-1.15A: CHS DFS recreates glyph slots $80-$EB on demand.
	; Upload only the 20 fixed $EC-$FF tiles on a safe START open,
	; including DMG and CGB 1x. Preserve the DFS cache reset.
	; Special redraw/auto-text/LCD-off states still load all 128.
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
	; DFS dynamically fills $80-$EB (54 entries x 2 tiles) while
	; drawing the completed menu; the fixed tail alone needs preload.
	; Keep cache invalidation: omitting it caused earlier garbled text.
	ASSERT (FontGraphicsEnd - FontGraphics) == $80 * $8
	ASSERT $80 + $36 * 2 == $EC
	callfar dfsClearCache
	ld de, FontGraphics + $6c * $8
	ld hl, vFont + $6c * $10
	lb bc, BANK(FontGraphics), $14
	; Keep the proven 20-tile batch for native CGB running at 2x.
	; At 1x (DMG or CGB), use the previously tested 12-tile limit:
	; 20 tiles now take two VBlanks instead of 128 taking 17.
	ldh a, [hCGB]
	and a
	jr z, .oneSpeedStartFont
	ldh a, [rKEY1]
	bit 7, a
	jr z, .oneSpeedStartFont
	call CopyVideoDataDoubleStartMenu
	ret
.oneSpeedStartFont
	call CopyVideoDataDoubleStartMenu1x
	ret
.normalStartFont
	call LoadFontTilePatterns
	ret
