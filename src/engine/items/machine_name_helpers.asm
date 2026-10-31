; ROM-1.20C: TM/HM text composition and prefix strings, same bank.
GetMachineName_Banked::
; copies the name of the TM/HM in [wd11e] to wcd6d
	push hl
	push de
	push bc
	ld a, [wd11e]
	push af
	cp TM01 ; is this a TM? [not HM]
	jr nc, .WriteTM
; if HM, then write "HM" and add NUM_HMS to the item ID, so we can reuse the
; TM printing code
	add NUM_HMS
	ld [wd11e], a
	ld hl, HiddenPrefix ; points to "HM"
	ld bc, 2 ; TM Length
	jr .WriteMachinePrefix
.WriteTM
	ld hl, TechnicalPrefix ; points to "TM"
	ld bc, 2 ; TM Length
.WriteMachinePrefix
	ld de, wcd6d
	call CopyData

; now get the machine number and convert it to text
	ld a, [wd11e]
	sub TM01 - 1
	ld b, CHARVAL("0")
.FirstDigit
	sub 10
	jr c, .SecondDigit
	inc b
	jr .FirstDigit
.SecondDigit
	add 10
	push af
	ld a, b
	ld [de], a
	inc de
	pop af
	ld b, CHARVAL("0")
	add b
	ld [de], a
	inc de
	ld a, CHARVAL("@")
	ld [de], a
	pop af
	ld [wd11e], a
	pop bc
	pop de
	pop hl
	ret

TechnicalPrefix::
	db "TM"
HiddenPrefix::
	db "HM"

; End of relocated TM/HM helper.
