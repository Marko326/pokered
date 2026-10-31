GetMonName::
	push hl
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(MonsterNames)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ld a, [wd11e]
	dec a
	push af
	ld a,[wENGNameMark]
	cp 1
	ld hl, MonsterNames
	jr nz, .CHS
	ld hl, MonsterNames2
.CHS
	pop af
	ld c, 10
	ld b, 0
	call AddNTimes
	ld de, wcd6d
	push de
	ld bc, 10
	call CopyData
	ld hl, wcd6d + 10
	ld [hl], CHARVAL("@")
	pop de
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	pop hl
	ret

GetItemName::
; given an item ID at [wd11e], store the name of the item into a string
;     starting at wcd6d
	push hl
	push bc
	ld a, [wd11e]
	cp HM01 ; is this a TM/HM?
	jr nc, .Machine

	ld [wd0b5], a
	ld a, ITEM_NAME
	ld [wNameListType], a
	ld a, BANK(ItemNames)
	ld [wPredefBank], a
	call GetName
	jr .Finish

.Machine
	call GetMachineName
.Finish
	ld de, wcd6d ; pointer to where item name is stored in RAM
	pop bc
	pop hl
	ret

GetMachineName::
; ROM-1.20C: TM/HM name composition and its two private prefixes.
; Original routine takes no arguments in A; HL/BC/DE are passed through
; untouched, and ALL result registers/flags are restored after bank switch.
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(GetMachineName_Banked)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call GetMachineName_Banked
	push af
	push bc
	push de
	push hl
	ld hl, sp + 9 ; saved caller bank (A in saved AF)
	ld a, [hl]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	pop hl
	pop de
	pop bc
	pop af
	inc sp ; discard saved caller bank AF; does not change flags
	inc sp
	ret

; sets carry if item is HM, clears carry if item is not HM
; Input: a = item ID
IsItemHM::
	cp HM01
	jr c, .notHM
	cp TM01
	ret
.notHM
	and a
	ret

; sets carry if move is an HM, clears carry if move is not an HM
; Input: a = move ID
IsMoveHM::
	ld hl, HMMoves
	ld de, 1
	jp IsInArray

HMMoves::
INCLUDE "data/moves/hm_moves.asm"

GetMoveName::
	push hl
	ld a, MOVE_NAME
	ld [wNameListType], a
	ld a, [wd11e]
	ld [wd0b5], a
	ld a, BANK(MoveNames)
	ld [wPredefBank], a
	call GetName
	ld de, wcd6d ; pointer to where move name is stored in RAM
	pop hl
	ret
