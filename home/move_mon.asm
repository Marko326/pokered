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

; ROM-1.0.5: Run the stat calculations in ROMX while preserving the
; caller-visible A, flags, BC, DE and HL after restoring the caller bank.
; These routines receive WRAM pointers (not banked ROM data pointers).
CalcStats::
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(_CalcStats)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call _CalcStats
	jp RestoreCalcStatsBank

CalcStat::
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(_CalcStat)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call _CalcStat
	; fall through

RestoreCalcStatsBank:
	push af
	push bc
	push de
	push hl
	ld hl, sp + 9 ; saved bank byte above the pushed AF/BC/DE/HL
	ld a, [hl]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop hl
	pop de
	pop bc
	pop af
	inc sp ; discard saved caller bank and its flags
	inc sp
	ret

AddEnemyMonToPlayerParty::
	homecall_sf _AddEnemyMonToPlayerParty
	ret

MoveMon::
	homecall_sf _MoveMon
	ret
