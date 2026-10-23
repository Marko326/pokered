; MOV-1.11: ROMX implementation of MEN-1.10 direct START close.
; Keep VRAM restoration and all special movement-state checks unchanged.
; ROM0 wrapper handles the original saved bank and UpdateSprites tail.
CloseTextDisplayFastStartBanked::
	ld a, $90
	ldh [hWY], a
	call DelayFrame
	call LoadGBPal
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wSprite01StateData2OrigFacingDirection
	ld c, NUM_SPRITESTATEDATA_STRUCTS - 1
	ld de, SPRITESTATEDATA1_LENGTH
.restoreSpriteFacingDirectionLoop
	ld a, [hl]
	dec h
	ld [hl], a
	inc h
	add hl, de
	dec c
	jr nz, .restoreSpriteFacingDirectionLoop
	farcall InitMapSprites
	xor a
	ld [wStartMenuPartialSpriteRestore], a ; MEN-1.10: prevent state leakage
	ld hl, wFontLoaded
	res BIT_FONT_LOADED, [hl]
	; MEN-1.10: InitMapSprites restores NPC tiles, not the player.
	; START overwrites Bank-0 vNPCSprites2, including the player's
	; walking tiles at $8800-$88bf. Restore them before resuming play.
	ld a, [wStatusFlags6]
	bit BIT_FLY_WARP, a
	jr nz, .playerReady
	ld a, [wWalkBikeSurfState]
	and a
	jr nz, .reloadPlayer
	; Walking: only the second 12-tile half was overwritten by font.
	; Keep the unchanged standing sprites; restore the walking half.
	ld de, RedSprite + $c0
	ld hl, vNPCSprites2
	lb bc, BANK(RedSprite), 12
	call CopyVideoData
	jr .playerReady
.reloadPlayer
	; Bike and surf have different graphics and state checks.
	call LoadPlayerSpriteGraphics
.playerReady
	ret
