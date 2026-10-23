; MOV-1.11: use extra one-pixel movement updates to keep the 60FPS
; overworld cadence. A normal 16-pixel tile is 16 frames on foot,
; 8 frames while holding B, or 4 frames on a bicycle.
; Keep one final update for AdvancePlayerSprite so wWalkCounter never wraps
; if B is released or the cycling-road direction changes mid-tile.
AdvancePlayerAtSpeed::
	ld a, [wWalkBikeSurfState]
	cp $01 ; bicycle
	jr z, .bicycle
	and a ; $00 = walking, $02 = surfing
	jr nz, .normal
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_MOVEMENT_STATE, a
	jr nz, .normal ; do not accelerate scripted walking
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	jr nz, .normal ; preserve the ledge/fishing cadence
	ldh a, [hJoyHeld]
	and PAD_B
	jr z, .normal
	ld c, 1 ; running: one extra pixel per rendered frame
	jr .extraSteps
.bicycle
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	jr nz, .normal
	ld c, 3 ; bicycle: three extra pixels per rendered frame
.extraSteps
	ld a, [wWalkCounter]
	cp 2
	jr c, .normal ; reserve the final pixel for the normal call
	push bc
	call DoBikeSpeedup ; retains Cycling Road / scripted-move guards
	pop bc
	dec c
	jr nz, .extraSteps
.normal
	jp AdvancePlayerSprite
