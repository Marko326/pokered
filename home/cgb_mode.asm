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

; CGB-1.13: Fast VBlank path; avoid ROM bank switching unless a DMG
; shade register changed. The full RGB555 remap runs from ROMX.
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
