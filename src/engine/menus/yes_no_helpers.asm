; ROM-1.20A: Yes/No modal implementation relocated from ROM0.
; Called through the ROM0 entry points in home/yes_no.asm.
; No direct ROMX callers: the ROM0 stubs ensure the current bank is restored.

; displays yes/no choice
; yes -> set carry
YesNoChoice_::
	call SaveScreenTilesToBuffer1
	call InitYesNoTextBoxParameters
	jr DisplayYesNoChoice

TwoOptionMenu:: ; unreferenced
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call InitYesNoTextBoxParameters
	jp DisplayTextBoxID

InitYesNoTextBoxParameters::
	xor a ; YES_NO_MENU
	ld [wTwoOptionMenuID], a
	hlcoord 14, 7
	lb bc, 8, 15
	ret

YesNoChoicePokeCenter_::
	call SaveScreenTilesToBuffer1
	ld a, HEAL_CANCEL_MENU
	ld [wTwoOptionMenuID], a
	hlcoord 11, 7 ;hlcoord 11, 6
	lb bc, 8, 12
	jr DisplayYesNoChoice

; WideYesNoChoice:: ; unused
	; call SaveScreenTilesToBuffer1
	; ld a, WIDE_YES_NO_MENU
	; ld [wTwoOptionMenuID], a
	; hlcoord 12, 7
	; lb bc, 8, 13

DisplayYesNoChoice::
	ld a, TWO_OPTION_MENU
	ld [wTextBoxID], a
	call DisplayTextBoxID
	jp LoadScreenTilesFromBuffer1
