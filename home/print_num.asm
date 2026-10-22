PrintNumber::
; Print the c-digit, b-byte value at de.
; Allows 2 to 7 digits. For 1-digit numbers, add
; the value to char "0" instead of calling PrintNumber.
; Flags LEADING_ZEROES and LEFT_ALIGN can be given
; in bits 7 and 6 of b respectively.
	xor a
	ldh [hPastLeadingZeros], a
	ldh [hNumToPrint], a
	ldh [hNumToPrint + 1], a
	ld a, b
	and $f
	cp 1
	jr z, .byte
	cp 2
	jr z, .word
.long
	ld a, [de]
	ldh [hNumToPrint], a
	inc de
	ld a, [de]
	ldh [hNumToPrint + 1], a
	inc de
	ld a, [de]
	ldh [hNumToPrint + 2], a
	jr .runFormatter

.word
	ld a, [de]
	ldh [hNumToPrint + 1], a
	inc de
	ld a, [de]
	ldh [hNumToPrint + 2], a
	jr .runFormatter

.byte
	ld a, [de]
	ldh [hNumToPrint + 2], a

.runFormatter
; ROM-1.0.4: Save the caller bank on the stack; this wrapper may be nested.
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(PrintNumber_)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call PrintNumber_
	push af
	push bc
	push de
	push hl
	ld hl, sp + 9 ; saved caller ROM bank, above the formatter return values
	ld a, [hl]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop hl
	pop de
	pop bc
	pop af
	inc sp
	inc sp
	ret
