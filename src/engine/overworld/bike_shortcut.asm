; MOV-1.8: SELECT toggles the bicycle using existing sprite and music routines.
; Keep forced biking, scripted movement, surf, and restricted maps unchanged.
SelectBicycleShortcut::
	ld a, [wIsInBattle]
	and a
	ret nz
	ld a, [wd730]
	bit 2, a ; interaction is currently blocked
	ret nz
	call IsPlayerCharacterBeingControlledByGame
	ret nz
	ld a, [wd736]
	bit 6, a ; ledge jump or fishing
	ret nz
	ld a, [wd732]
	bit 5, a ; forced Cycling Road riding
	ret nz
	; RPP #383: allow Surf SELECT to try the remembered Bag rod;
	; land still requires facing fishable water. Forced bike restrictions
	; and all existing gameplay/script guards above are unchanged.
	; The helper preserves carry when it handles the shoreline action.
	farcall TrySelectShoreFishing
	ret c
	ld b, BICYCLE
	call IsItemInBag
	ret z ; no bicycle
	ld a, [wWalkBikeSurfState]
	ld [wWalkBikeSurfStateCopy], a
	cp 1
	jr z, .dismount
	and a
	ret nz
	call IsBikeRidingAllowed
	ret nc
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
