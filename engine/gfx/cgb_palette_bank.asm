; CGB-1.13: Color initialization and remap live in ROMX.
; Called from the fixed-bank entry points, not directly from ROMX.

InitCGBDefaultPalette::
	; CGB-1.12: Game Boy Color boot palettes (not SGB town palettes).
	; Keep OBJ0 at BG6 and BG/OBJ1 at BG7 for DMG shade remapping.
	ldh a, [hCGB]
	and a
	ret z
	ld a, $b0 ; BG palette 6, followed by palette 7; auto-increment.
	ldh [rBGPI], a
	ld hl, .colors
	ld b, 16
.loop
	ld a, [hli]
	ldh [rBGPD], a
	dec b
	jr nz, .loop
	ret
.colors
IF DEF(_RED)
	; Pokemon Red: green sprites over red background.
	RGB 31,31,31, 15,31,06, 00,16,00, 00,00,00 ; OBJ0
	RGB 31,31,31, 31,16,16, 18,07,07, 00,00,00 ; BG/OBJ1
ELSE
	; Pokemon Blue: red sprites over blue background.
	RGB 31,31,31, 31,16,16, 18,07,07, 00,00,00 ; OBJ0
	RGB 31,31,31, 12,20,31, 00,00,31, 00,00,00 ; BG/OBJ1
ENDC

UpdateCGBDmgPalettesBanked::
	; CGB-1.12: BG6/7 hold the original Game Boy Color boot colors.
	; Apply BGP/OBP0/OBP1 shade indices to native palette 0/0/1.
	ldh a, [hCGB]
	and a
	ret z
	ldh a, [rBGP]
	ld b, a
	ldh a, [hCGBBGP]
	cp b
	jr z, .obj0
	ld a, b
	ldh [hCGBBGP], a
	ld c, LOW(rBGPI)
	ld e, 0
	ld h, $38 ; BG7: version-specific background.
	call .writePalette
.obj0
	ldh a, [rOBP0]
	ld b, a
	ldh a, [hCGBOBP0]
	cp b
	jr z, .obj1
	ld a, b
	ldh [hCGBOBP0], a
	ld c, LOW(rOBPI)
	ld e, 0
	ld h, $30 ; BG6: version-specific OBJ0.
	call .writePalette
.obj1
	ldh a, [rOBP1]
	ld b, a
	ldh a, [hCGBOBP1]
	cp b
	ret z
	ld a, b
	ldh [hCGBOBP1], a
	ld c, LOW(rOBPI)
	ld e, 8
	ld h, $38 ; BG7: version-specific OBJ1.
	; fallthrough

.writePalette:
	ld d, 4
.colorLoop
	; Read an RGB555 color from BG6 or BG7 without altering its source.
	ld a, b
	and %11
	add a
	add h
	ldh [rBGPI], a
	ldh a, [rBGPD]
	ld l, a
	ld a, b
	and %11
	add a
	add h
	inc a
	ldh [rBGPI], a
	ldh a, [rBGPD]
	; Write the selected color to the current native BG/OBJ slot.
	push af
	ld a, e
	or $80
	ldh [c], a
	inc c
	ld a, l
	ldh [c], a
	pop af
	ldh [c], a
	dec c
	inc e
	inc e
	ld a, b
	rrca
	rrca
	ld b, a
	dec d
	jr nz, .colorLoop
	ret

; Prime display palettes to black while LCD is disabled.
; Unlike Red++, BG6/BG7 are the immutable Red/Blue RGB555 shade sources here,
; so clear BG0-BG5 and all OBJ slots, but preserve BG6/BG7.
; Keep the software cache synchronized with the current DMG registers: forcing
; a VBlank remap here can immediately repaint the just-cleared palette with the
; old white shade before the silhouette palette is installed.
CGBBlackBattlePalettesLCDOff::
	ldh a, [hCGB]
	and a
	ret z
	ld a, $80
	ldh [rBGPI], a
	xor a
	ld b, 48 ; BG0-BG5; BG6/BG7 contain the Red/Blue source colors.
.bgLoop
	ldh [rBGPD], a
	dec b
	jr nz, .bgLoop
	ld a, $80
	ldh [rOBPI], a
	xor a
	ld b, 64 ; all eight OBJ palettes, matching the reference initialization.
.objLoop
	ldh [rOBPD], a
	dec b
	jr nz, .objLoop
	ldh a, [rBGP]
	ldh [hCGBBGP], a
	ldh a, [rOBP0]
	ldh [hCGBOBP0], a
	ldh a, [rOBP1]
	ldh [hCGBOBP1], a
	ret
