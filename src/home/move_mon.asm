; Copies [hl, bc) to [de, de + bc - hl).
; In other words, the source data is from hl up to but not including bc,
; and the destination is de.
CopyDataUntil::
	ld a, [hli]
	ld [de], a
	inc de
	ld a, h
	cp b
	jr nz, CopyDataUntil
	ld a, l
	cp c
	jr nz, CopyDataUntil
	ret

; Function to remove a pokemon from the party or the current box.
; wWhichPokemon determines the pokemon.
; [wRemoveMonFromBox] == 0 specifies the party.
; [wRemoveMonFromBox] != 0 specifies the current box.
RemovePokemon::
	jpfar _RemovePokemon

AddPartyMon::
	push hl
	push de
	push bc
	farcall _AddPartyMon
	pop bc
	pop de
	pop hl
	ret

; ROM-1.20B: register-safe ROM0 entry points for stat calculation.
; Original stat routines use B/C/HL as inputs, so a plain farjp is unsafe.
; Stack after banking call and PUSH AF (offset from SP):
;   +0..1 = callee's AF, +2..3 = saved caller bank AF,
;   +4..5 = original BC, +6..7 = original HL, +8.. = caller return.
; Save DE by NOT touching it, preserve exact computed AF using POP AF.
; Bank restore modifies only A/HL and flags temporarily; POP restores AF.
; CalcStats originally returns C = NUM_STATS; CalcStat preserves C.
CalcStats::
	push hl
	push bc
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(CalcStats_Banked)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call CalcStats_Banked
	push af
	ld hl, sp + 3
	ld a, [hl] ; saved caller ROM bank (upper byte of old AF)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	pop af
	pop bc ; discard saved caller-bank AF
	pop bc ; restore original BC
	pop hl ; restore original HL
	ld c, NUM_STATS ; original CalcStats advances C from 0 to NUM_STATS
	ret

CalcStat::
	push hl
	push bc
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(CalcStat_Banked)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call CalcStat_Banked
	push af
	ld hl, sp + 3
	ld a, [hl]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	pop af
	pop bc ; discard saved caller-bank AF
	pop bc ; restore original BC
	pop hl ; restore original HL
	ret

AddEnemyMonToPlayerParty::
	homecall_sf _AddEnemyMonToPlayerParty
	ret

MoveMon::
	homecall_sf _MoveMon
	ret
