SoftReset::
	call GBCSetCPU1xSpeed ; CGB-1.12: Keep reset audio and fades at normal speed.
	call StopAllSounds
	call GBPalWhiteOut
	ld c, 32
	call DelayFrames
	; fallthrough

Init::
;  Program init.
	call GBCSetCPU1xSpeed ; CGB-1.12: Also normalize direct jumps to Init.
	di

	xor a
	ldh [rIF], a
	ldh [rIE], a
	ldh [rSCX], a
	ldh [rSCY], a
	ldh [rSB], a
	ldh [rSC], a
	ldh [rWX], a
	ldh [rWY], a
	ldh [rTMA], a
	ldh [rTAC], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a

	ld a, LCDC_ON
	ldh [rLCDC], a
	call DisableLCD

	ld sp, wStack

	ld hl, STARTOF(WRAM0)
	ld bc, SIZEOF(WRAM0)
.loop
	ld [hl], 0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop

	; CGB-1.12: Restore the hardware flag after clearing WRAM.
	ldh a, [hCGB]
	ld [wOnCGB], a
	and a
	jr z, .vramReady
	; Clear CGB attribute bank, then return to the DMG-compatible tile bank.
	ld a, 1
	ldh [rVBK], a
	call ClearVram
	xor a
	ldh [rVBK], a
.vramReady
	call ClearVram

	ld hl, STARTOF(HRAM)
	ld bc, SIZEOF(HRAM) - 1 ; CGB-1.12: Preserve hCGB at the end.
	call FillMemory
	; CGB-1.12: Cache invalidation, including the all-black palette case.
	ldh a, [rBGP]
	cpl
	ldh [hCGBBGP], a
	ldh a, [rOBP0]
	cpl
	ldh [hCGBOBP0], a
	ldh a, [rOBP1]
	cpl
	ldh [hCGBOBP1], a
	call InitCGBDefaultPalette

	call ClearSprites

	ld a, BANK(WriteDMACodeToHRAM)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call WriteDMACodeToHRAM

	xor a
	ldh [hTileAnimations], a
	ldh [rSTAT], a
	ldh [hSCX], a
	ldh [hSCY], a
	ldh [rIF], a
	ld a, IE_VBLANK | IE_TIMER | IE_SERIAL
	ldh [rIE], a

	ld a, 144 ; move the window off-screen
	ldh [hWY], a
	ldh [rWY], a
	ld a, 7
	ldh [rWX], a

	ld a, CONNECTION_NOT_ESTABLISHED
	ldh [hSerialConnectionStatus], a

	ld h, HIGH(vBGMap0)
	call ClearBgMap
	ld h, HIGH(vBGMap1)
	call ClearBgMap

	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld a, 16
	ldh [hSoftReset], a
	call StopAllSounds

	ei

	predef LoadSGB

	ld a, BANK(SFX_Shooting_Star)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	ld a, HIGH(vBGMap1)
	ldh [hAutoBGTransferDest + 1], a
	xor a
	ldh [hAutoBGTransferDest], a
	dec a
	ld [wUpdateSpritesEnabled], a

	predef PlayIntro

	call DisableLCD
	call ClearVram
	call GBPalNormal
	call ClearSprites
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a

	jp PrepareTitleScreen

ClearVram::
	ld hl, STARTOF(VRAM)
	ld bc, SIZEOF(VRAM)
	xor a
	jp FillMemory


StopAllSounds::
	ld a, BANK("Audio Engine 1")
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a
	xor a
	ld [wAudioFadeOutControl], a
	ld [wNewSoundID], a
	ld [wLastMusicSoundID], a
	dec a
	jp PlaySound
