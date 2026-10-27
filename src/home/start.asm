_Start::
	cp GBC
	jr z, .gbc
	xor a
	jr .ok
.gbc
	ld a, TRUE ; CGB-1.5A: hardware flag from boot ROM.
.ok
	ldh [hCGB], a ; home2 clears WRAM; preserve the flag in HRAM.
	jp Init
