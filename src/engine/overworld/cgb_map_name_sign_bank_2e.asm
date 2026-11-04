; CGB map-name-sign 1bpp assets and blitter in bank $2E.
; Called by Bankswitch from bank $3D; DE is selected VRAM bank-1 target.
; No IRQ/unmasked bank-changing work is introduced here.
MapNameSignCopyExtendedBank2E::
	ld a, [wMapNameSignEffectiveMap]
	sub MAP_NAME_SIGN_SILPH_CO_1F
	ld hl, MapNameSignDataBank2E
	ld bc, 18 * 2 * 8
	and a
	jr z, .copy
.seek
	add hl, bc
	dec a
	jr nz, .seek
.copy
	ld bc, 18 * 2 * 8
.copyByte
	ld a, $ff
	call .waitVRAM
	ld [de], a
	inc de
	ld a, [hli]
	call .waitVRAM
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyByte
	ret
.waitVRAM
	push af
.wait
	ldh a, [rSTAT]
	and %10
	jr nz, .wait
	pop af
	ret

MapNameSignDataBank2E:
	INCBIN "gfx/map_name_sign/labels_ext_a.1bpp"
MapNameSignDataBank2EEnd:
	ASSERT MapNameSignDataBank2EEnd - MapNameSignDataBank2E == MAP_NAME_SIGN_EXT_A_LABELS * 18 * 2 * 8
