LoadSpinnerArrowTiles::
	; RPP #221 / Yellow Legacy: movement is 16 one-pixel steps at 60 FPS.
	; Refresh facing and spinner graphics only every other step so each tile keeps
	; eight visual rotations instead of spinning twice as fast.
	ld a, [wWalkCounter]
	bit 0, a
	ret nz

	ld a, [wSpritePlayerStateData1ImageIndex]
	srl a
	srl a
	ld hl, SpinnerPlayerFacingDirections
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [hl]
	ld [wSpritePlayerStateData1ImageIndex], a
	ld a, [wCurMapTileset]
	cp FACILITY
	ld hl, FacilitySpinnerArrows
	jr z, .gotSpinnerArrows
	ld hl, GymSpinnerArrows
.gotSpinnerArrows
	ld a, [wSimulatedJoypadStatesIndex]
	bit 0, a
	jr nz, .alternateGraphics
	ld de, 6 * 4
	add hl, de
.alternateGraphics
	ld a, $4
	ld bc, $0
.loop
	push af
	push hl
	push bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CopySpinnerTile
	pop bc
	ld a, $6
	add c
	ld c, a
	pop hl
	pop af
	dec a
	jr nz, .loop
	; The Overworld loop already waits once for every one-pixel step.
	; Do not add eight more frame waits during the eight arrow refreshes.
	ret

CopySpinnerTile:
	; All #221 spinner frames come from SpinnerArrowAnimTiles in this same ROM
	; bank. Copy one 2bpp tile directly during safe LCD modes. Mainline-only:
	; IME must be enabled on entry, since this routine restores it with ei.
	; The Overworld loop owns frame pacing. Preserve the CGB VRAM bank.
	di
	ldh a, [rVBK]
	push af
	xor a
	ldh [rVBK], a

	; Save the VRAM destination and real stack pointer. hSPTemp is the engine's
	; existing VBlank scratch pair; interrupts remain disabled while it is used.
	ld b, h
	ld c, l
	ld hl, sp + 0
	ld a, h
	ldh [hSPTemp], a
	ld a, l
	ldh [hSPTemp + 1], a

	; Use the stack as the fast 16-byte ROM source, matching RPP #221.
	ld h, d
	ld l, e
	ld sp, hl
	ld h, b
	ld l, c
	ld c, 8
.loop
	pop de
.waitVRAM
	ldh a, [rSTAT]
	and %10
	jr nz, .waitVRAM
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	dec c
	jr nz, .loop

	ldh a, [hSPTemp]
	ld h, a
	ldh a, [hSPTemp + 1]
	ld l, a
	ld sp, hl
	pop af
	ldh [rVBK], a
	ei
	ret

INCLUDE "data/tilesets/spinner_tiles.asm"

SpinnerPlayerFacingDirections:
; This isn't the order of the facing directions.  Rather, it's a list of
; the facing directions that come next. For example, when the player is
; facing down (00), the next facing direction is left (08).
	db $08 ; down -> left
	db $0C ; up -> right
	db $04 ; left -> up
	db $00 ; right -> down

; these tiles are the animation for the tiles that push the player in dungeons like Rocket HQ
SpinnerArrowAnimTiles:
	INCBIN "gfx/overworld/spinners.2bpp"
