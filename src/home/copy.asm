FarCopyData::
; Copy bc bytes from a:hl to de.
	ld [wBuffer], a
	ldh a, [hLoadedROMBank]
	push af
	ld a, [wBuffer]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call CopyData
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ret

CopyData::
; DOR-1.17B (adapted from Shin Pokemon Red): during map loading,
; writes to VRAM wait for an accessible LCD period. All other copies
; retain the original fast path. Only the dest $8000-$9fff is gated.
	ldh a, [hMapLoadVRAMSafeFlag]
	and a
	jr z, .fast
	ld a, d
	cp $80
	jr c, .fast
	cp $a0
	jr nc, .fast
.safe
	di
.waitVRAM
	ldh a, [rSTAT]
	and %10 ; modes 0 and 1 permit VRAM writes
	jr nz, .waitVRAM
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ei
	ld a, c
	or b
	jr nz, .safe
	ret
.fast
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .fast
	ret
