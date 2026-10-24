; BIKE-1.13A: SELECT bicycle shortcut without an extra mount/dismount SFX.
; Keep the project's automatic 4-pixel bicycle step and existing bag-use flow.
SelectBicycleShortcut::
	ld a, [wIsInBattle]
	and a
	ret nz
	ld a, [wStatusFlags5]
	bit BIT_UNKNOWN_5_2, a
	ret nz
	call IsPlayerCharacterBeingControlledByGame
	ret nz
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	ret nz
	ld a, [wStatusFlags6]
	bit BIT_ALWAYS_ON_BIKE, a
	ret nz ; forced Cycling Road riding cannot be toggled
	ld a, [wWalkBikeSurfState]
	cp 2
	ret z ; never switch from Surf
	ld b, BICYCLE
	call IsItemInBag
	ret z ; no bicycle in the bag
	ld a, [wWalkBikeSurfState]
	ld [wWalkBikeSurfStateCopy], a
	cp 1
	jr z, .dismount
	and a
	ret nz
	call IsBikeRidingAllowed
	ret nc ; do not bypass indoor/restricted-map rules
	ld a, 1
	ld [wWalkBikeSurfState], a
	xor a
	ldh [hJoyHeld], a
	call LoadPlayerSpriteGraphics
	call UpdateSprites
	call PlayDefaultMusic
	ret
.dismount
	xor a
	ld [wWalkBikeSurfState], a
	call LoadPlayerSpriteGraphics
	call UpdateSprites
	call PlayDefaultMusic
	ret
