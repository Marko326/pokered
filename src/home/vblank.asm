VBlank::

	push af
	push bc
	push de
	push hl

	ldh a, [hLoadedROMBank]
	ld [wVBlankSavedROMBank], a
	; DOR-1.17D: DMG doorway palette commit during VBlank.
	; No pending writes on CGB; its normal fade path is unchanged.
	ld a, [wDoorFadePending]
	and a
	jr z, .noDoorPalette
	xor a
	ld [wDoorFadePending], a
	ld a, [wDoorFadeBGP]
	ldh [rBGP], a
	ld a, [wDoorFadeOBP0]
	ldh [rOBP0], a
	ld a, [wDoorFadeOBP1]
	ldh [rOBP1], a
.noDoorPalette
	; Map DMG shade registers to the CGB native palettes.
	call UpdateCGBDmgPalettes

	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a

	ld a, [wDisableVBlankWYUpdate]
	and a
	jr nz, .ok
	ldh a, [hWY]
	ldh [rWY], a
.ok

	; DOR-1.17B: do not let old-map auto BG/scroll writes race with
	; manual map VRAM uploads. Still service font/sprite VBlank queues.
	ldh a, [hMapLoadVRAMSafeFlag]
	and a
	jr nz, .skipMapBgUpdates
	call AutoBgMapTransfer
	call VBlankCopyBgMap
	call RedrawRowOrColumn
.skipMapBgUpdates
	call VBlankCopy
	call VBlankCopyDouble
	ldh a, [hMapLoadVRAMSafeFlag]
	and a
	call z, UpdateMovingBgTiles
	call CGBFixOAMPalettes
	; Defer OAM DMA and sprite construction until the new map is ready.
	ldh a, [hMapLoadVRAMSafeFlag]
	and a
	jr nz, .skipOAM
	call hDMARoutine
	ld a, BANK(PrepareOAMData)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call PrepareOAMData
.skipOAM
	; VBlank-sensitive operations end.

	call Random

	ldh a, [hVBlankOccurred]
	and a
	jr z, .skipZeroing
	xor a
	ldh [hVBlankOccurred], a

.skipZeroing
	ldh a, [hFrameCounter]
	and a
	jr z, .skipDec
	dec a
	ldh [hFrameCounter], a

.skipDec
	call FadeOutAudio

	ld a, [wAudioROMBank] ; music ROM bank
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

	cp BANK(Audio1_UpdateMusic)
	jr nz, .checkForAudio2
.audio1
	call Audio1_UpdateMusic
	jr .afterMusic
.checkForAudio2
	cp BANK(Audio2_UpdateMusic)
	jr nz, .audio3
.audio2
	call Music_DoLowHealthAlarm
	call Audio2_UpdateMusic
	jr .afterMusic
.audio3
	call Audio3_UpdateMusic
.afterMusic

	farcall TrackPlayTime ; keep track of time played

	ldh a, [hDisableJoypadPolling]
	and a
	call z, ReadJoypad

	ld a, [wVBlankSavedROMBank]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

	pop hl
	pop de
	pop bc
	pop af
	reti


DelayFrame::
; Wait for the next vblank interrupt.
; As a bonus, this saves battery.

DEF NOT_VBLANKED EQU 1

	ld a, NOT_VBLANKED
	ldh [hVBlankOccurred], a
.halt
	halt
	ldh a, [hVBlankOccurred]
	and a
	jr nz, .halt
	ret
