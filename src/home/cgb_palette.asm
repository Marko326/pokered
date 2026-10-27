; CGB-1.5: Native colors on stable DMG 60 FPS.
; Keep CPU at its original speed; no SGB packet-to-attribute conversion.
UpdateCGBDmgPalettes::
	ldh a, [hCGB]
	and a
	ret z
	ldh a, [rBGP]
	ld b, a
	ldh a, [hCGBBGP]
	cp b
	jr nz, .changed
	ldh a, [rOBP0]
	ld b, a
	ldh a, [hCGBOBP0]
	cp b
	jr nz, .changed
	ldh a, [rOBP1]
	ld b, a
	ldh a, [hCGBOBP1]
	cp b
	ret z
.changed
	farcall UpdateCGBDmgPalettesBanked
	ret

CGBFixOAMPalettes::
	; DMG OBJ palette select is bit 4; native CGB uses bit 0.
	ldh a, [hCGB]
	and a
	ret z
	ld hl, wShadowOAM + 3
	ld de, 4
	ld b, 40
.loop
	ld a, [hl]
	and %11110000
	bit OAM_OBP_NUM, a
	jr z, .store
	or %00000001
.store
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret
