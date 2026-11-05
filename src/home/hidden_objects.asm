UpdateCinnabarGymGateTileBlocks::
	farjp UpdateCinnabarGymGateTileBlocks_

CheckForHiddenObjectOrBookshelfOrCardKeyDoor::
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hJoyHeld]
	bit BIT_A_BUTTON, a
	jr z, .nothingFound
; A button is pressed
	ld a, BANK(CheckForHiddenObject)
	ld [MBC1RomBank], a
	ldh [hLoadedROMBank], a
	call CheckForHiddenObject
	ldh a, [hDidntFindAnyHiddenObject]
	and a
	jr nz, .hiddenObjectNotFound
	ld a, [wHiddenObjectFunctionRomBank]
	ld [MBC1RomBank], a
	ldh [hLoadedROMBank], a
	ld de, .returnAddress
	push de
	jp hl
.returnAddress
	; A previously claimed hidden item must not block an NPC, sign or
	; field move at the same coordinate.  Unclaimed items still win.
	ldh a, [hDidntFindAnyHiddenObject]
	and a
	jr nz, .hiddenObjectNotFound
	xor a
	jr .done
.hiddenObjectNotFound
	farcall PrintBookshelfText
	ldh a, [hFFDB]
	and a
	jr z, .done
.nothingFound
	ld a, $ff
.done
	ldh [hItemAlreadyFound], a
	pop af
	ld [MBC1RomBank], a
	ldh [hLoadedROMBank], a
	ret
