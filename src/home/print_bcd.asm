; function to print a BCD (Binary-coded decimal) number
; de = address of BCD number
; hl = destination address
; c = flags and length
; bit 7: if set, do not print leading zeroes
;        if unset, print leading zeroes
; bit 6: if set, left-align the string (do not pad empty digits with spaces)
;        if unset, right-align the string
; bit 5: if set, print currency symbol at the beginning of the string
;        if unset, do not print the currency symbol
; bits 0-4: length of BCD number in bytes
; Note that bits 5 and 7 are modified during execution. The above reflects
; their meaning at the beginning of the functions's execution.
PrintBCDNumber::
; ROM-1.20C: BCD numbers are read from RAM; uses PrintLetterDelay in ROM0.
; Original routine takes no arguments in A; HL/BC/DE are passed through
; untouched, and ALL result registers/flags are restored after bank switch.
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(PrintBCDNumber_Banked)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call PrintBCDNumber_Banked
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
