_Start::
	cp BOOTUP_A_CGB
	jr z, .cgb
	xor a
	jr .ok
.cgb
	ld a, TRUE ; CGB-1.12: Enable native CGB hardware identification.
.ok
	ldh [hCGB], a ; CGB-1.12: Retain the boot flag across WRAM initialization.
	jp Init
