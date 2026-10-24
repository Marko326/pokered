; CGB-1.12: Native CGB speed and DMG palette compatibility.
; Keep the existing 60 FPS overworld and its movement timing unchanged.

GBCSetCPU1xSpeed::
	push af
	ldh a, [hCGB]
	and a
	jr z, .done
	ldh a, [rKEY1]
	bit 7, a
	call nz, CGBSwitchCPUSpeed
.done
	pop af
	ret

GBCSetCPU2xSpeed::
	push af
	ldh a, [hCGB]
	and a
	jr z, .done
	ldh a, [rKEY1]
	bit 7, a
	call z, CGBSwitchCPUSpeed
.done
	pop af
	ret

CGBSwitchCPUSpeed:
	; CGB-1.12: STOP toggles speed; keep pending IRQ flags intact.
	di
	ldh a, [rIE]
	push af
	xor a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	ld a, 1
	ldh [rKEY1], a
	stop
	pop af
	ldh [rIE], a
	ei
	ret

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

UpdateCGBDmgPalettes::
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

CGBFixOAMPalettes::
	; CGB-1.12: DMG's bits 0-2 are internal sprite flags, NOT palettes.
	; Retain flips/priority and translate only DMG OBJ1 bit 4 to CGB bit 0.
	ldh a, [hCGB]
	and a
	ret z
	ld hl, wShadowOAM + 3
	ld de, OBJ_SIZE
	ld b, 40
.loop
	ld a, [hl]
	and %11110000
	bit B_OAM_PAL1, a
	jr z, .store
	or %00000001
.store
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret
