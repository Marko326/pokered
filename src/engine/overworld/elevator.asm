ShakeElevator::
	ld b, 100 ; legacy duration for existing non-building callers
	jr ShakeElevatorWithLoopCount

ShakeBuildingElevator::
	ld b, 40 ; shorter animation for the three building elevators

ShakeElevatorWithLoopCount:
	push bc ; preserve the loop count across redraw and sound helpers
	ld de, -$20
	call ShakeElevatorRedrawRow
	ld de, SCREEN_HEIGHT * $20
	call ShakeElevatorRedrawRow
	call Delay3
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound
	ldh a, [hSCY]
	ld d, a
	ld e, $1
	pop bc ; restore the chosen 100/40 count
.shakeLoop ; scroll the BG up and down and play a sound effect
	ld a, e
	xor $fe
	ld e, a
	add d
	ldh [hSCY], a
	push bc
	ld c, BANK(SFX_Collision_1)
	ld a, SFX_COLLISION
	call PlayMusic
	pop bc
	ld c, 2
	call DelayFrames
	dec b
	jr nz, .shakeLoop
	ld a, d
	ldh [hSCY], a
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound
	ld c, BANK(SFX_Safari_Zone_PA)
	ld a, SFX_SAFARI_ZONE_PA
	call PlayMusic
.musicLoop
	ld a, [wChannelSoundIDs + CHAN5]
	cp SFX_SAFARI_ZONE_PA
	jr z, .musicLoop
	call UpdateSprites
	jp PlayDefaultMusic

ShakeElevatorRedrawRow:
; This function is used to redraw certain portions of the screen, but it does
; not appear to ever result in any visible effect, so this function seems to
; be pointless.
	ld hl, wMapViewVRAMPointer + 1
	ld a, [hld]
	push af
	ld a, [hl]
	push af
	push hl
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, h
	and $3
	or HIGH(vBGMap0)
	ld d, a
	ld a, l
	pop hl
	ld [hli], a
	ld [hl], d
	call ScheduleNorthRowRedraw
	pop hl
	pop af
	ld [hli], a
	pop af
	ld [hl], a
	jp Delay3
