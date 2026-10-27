; MOV-1.7: keep the 60 FPS overworld loop and accelerate only player steps.
; Walking: 16 frames/tile; hold B: 8 frames/tile; bicycle: 4 frames/tile.
; The last pixel always uses the normal advancement path so the counter
; cannot underflow when B is released or the cycling-road direction changes.
AdvancePlayerAtSpeed::
	ld a, [wWalkBikeSurfState]
	cp $02 ; surfing is always normal speed
	jr z, .normal
	call IsPlayerCharacterBeingControlledByGame
	jr nz, .normal ; scripted movement, doors and simulated joypad
	ld a, [wd736]
	bit 6, a ; ledge jump
	jr nz, .normal
	ld a, [wWalkBikeSurfState]
	cp $01 ; bicycle
	jr z, .bicycle
	and a ; $00 = walking
	jr nz, .normal
	ldh a, [hJoyHeld]
	and B_BUTTON
	jr z, .normal
	ld c, 1 ; one additional pixel while holding B
	jr .extraSteps
.bicycle
	ld a, [wCurMap]
	cp ROUTE_17 ; preserve Cycling Road uphill/sideways restriction
	jr nz, .fastBike
	ldh a, [hJoyHeld]
	and D_UP | D_LEFT | D_RIGHT
	jr nz, .normal
.fastBike
	ld c, 3 ; three additional pixels on the bicycle
.extraSteps
	ld a, [wWalkCounter]
	cp 2
	jr c, .normal ; leave the last pixel to the normal call
	push bc
	call AdvancePlayerSprite ; precisely one pixel per extra call
	pop bc
	dec c
	jr nz, .extraSteps
.normal
	jp AdvancePlayerSprite
