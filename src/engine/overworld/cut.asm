UsedCut:
	xor a
	ld [wActionResultOrTookBattleTurn], a ; initialise to failure value
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	jr z, .overworld
	cp GYM
	jr nz, .nothingToCut
	; Gym cut tree: accept all 4 visual quadrants, not just $50.
	ld a, [wTileInFrontOfPlayer]
	cp $40
	jr z, .canCut
	cp $41
	jr z, .canCut
	cp $50
	jr z, .canCut
	cp $51
	jr z, .canCut
	jr .nothingToCut
.overworld
	ld a, [wTileInFrontOfPlayer]
	; Overworld cut tree: accept all 4 visual quadrants.
	cp $2d
	jr z, .canCut
	cp $2e
	jr z, .canCut
	cp $3d
	jr z, .canCut
	cp $3e
	jr z, .canCut
	cp $52 ; keep the original tall-grass Cut from Party
	jr z, .canCut
.nothingToCut
	ld hl, .NothingToCutText
	jp PrintText

.NothingToCutText
	text_far _NothingToCutText
	text_end

.canCut
	ld [wCutTile], a
	ld a, 1
	ld [wActionResultOrTookBattleTurn], a ; used cut
	ld a, [wWhichPokemon]
	ld hl, wPartyMonNicks
	call GetPartyMonName
	; Keep Options text speed for the Cut success message.
	; Original Red sets wd730 bit 6 here, bypassing PrintLetterDelay.
	ld hl, wd730
	res 6, [hl]
	call GBPalWhiteOutWithDelay3
	call ClearSprites
	call RestoreScreenTilesAndReloadTilePatterns
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	call Delay3
	call ReloadMapData
	call LoadGBPal
	call LoadCurrentMapView
	call SaveScreenTilesToBuffer2
	call Delay3
	xor a
	ldh [hWY], a
Cut2:: ; RPP #031: direct field Cut, no palette whiteout / map reloading
	; Keep the original execution message/animation. RPP #031 only skips
	; the pre-action environment hint when Cut can actually be used.
	ld hl, UsedCutText
	call PrintText
	call LoadScreenTilesFromBuffer2
	ld hl, wd730
	res 6, [hl]
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	call InitCutAnimOAM
	ld de, CutTreeBlockSwaps
	call ReplaceTreeTileBlock
	call RedrawMapView
	farcall AnimCut
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	ld a, SFX_CUT
	call PlaySound
	ld a, $90
	ldh [hWY], a
	call UpdateSprites
	jp RedrawMapView

UsedCutFromFieldA::
	; Front tile is already validated by the A-button field helper.  RPP
	; uses Cut2 here instead of the whiteout-heavy Party UsedCut path.
	ld a, [wTileInFrontOfPlayer]
	ld [wCutTile], a
	ld a, 1
	ld [wActionResultOrTookBattleTurn], a
	; RPP also sets no-text-delay here; CHS honors the user's text-speed option instead.
	ld hl, wd730
	res 6, [hl]
	jp Cut2

UsedCutText:
	text_far _UsedCutText
	text_end

InitCutAnimOAM:
	xor a
	ld [wWhichAnimationOffsets], a
	ld a, %11100100
	ldh [rOBP1], a
	ld a, [wCutTile]
	cp $52
	jr z, .grass
; tree
	ld de, Overworld_GFX tile $2d ; cuttable tree sprite top row
	ld hl, vChars1 tile $7c
	lb bc, BANK(Overworld_GFX), 2
	call CopyVideoData
	ld de, Overworld_GFX tile $3d ; cuttable tree sprite bottom row
	ld hl, vChars1 tile $7e
	lb bc, BANK(Overworld_GFX), 2
	call CopyVideoData
	jr WriteCutOrBoulderDustAnimationOAMBlock
.grass
	ld hl, vChars1 tile $7c
	call LoadCutGrassAnimationTilePattern
	ld hl, vChars1 tile $7d
	call LoadCutGrassAnimationTilePattern
	ld hl, vChars1 tile $7e
	call LoadCutGrassAnimationTilePattern
	ld hl, vChars1 tile $7f
	call LoadCutGrassAnimationTilePattern
	call WriteCutOrBoulderDustAnimationOAMBlock
	ld hl, wShadowOAMSprite36Attributes
	ld de, 4
	ld a, $30
	ld c, e
.loop
	ld [hl], a
	add hl, de
	xor $60
	dec c
	jr nz, .loop
	ret

LoadCutGrassAnimationTilePattern:
	ld de, MoveAnimationTiles1 tile 6 ; tile depicting a leaf
	lb bc, BANK(MoveAnimationTiles1), 1
	jp CopyVideoData

WriteCutOrBoulderDustAnimationOAMBlock:
	call GetCutOrBoulderDustAnimationOffsets
	ld a, $9
	ld de, CutOrBoulderDustAnimationTilesAndAttributes
	jp WriteOAMBlock

CutOrBoulderDustAnimationTilesAndAttributes:
	; WriteOAMBlock reads FOUR (tile ID, attribute) pairs, not OAM
	; sprite position records.  Using dbsprite here inadvertently mixed
	; native CGB OBJ0/OBJ1 across the 2x2 tree animation.
	; Use the original Red four-tile layout and DMG/CGB OBJ1 on all four.
	; Palette 1 stays tied to rOBP1 for the original flashing animation.
	db $fc, OAM_OBP1
	db $fd, OAM_OBP1
	db $fe, OAM_OBP1
	db $ff, OAM_OBP1

GetCutOrBoulderDustAnimationOffsets:
	ld hl, wSpritePlayerStateData1YPixels
	ld a, [hli] ; player's sprite screen Y position
	ld b, a
	inc hl
	ld a, [hli] ; player's sprite screen X position
	ld c, a ; bc holds ypos/xpos of player's sprite
	inc hl
	inc hl
	ld a, [hl] ; a holds direction of player (00: down, 04: up, 08: left, 0C: right)
	srl a
	ld e, a
	ld d, $0 ; de holds direction (00: down, 02: up, 04: left, 06: right)
	ld a, [wWhichAnimationOffsets]
	and a
	ld hl, CutAnimationOffsets
	jr z, .next
	ld hl, BoulderDustAnimationOffsets
.next
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, b
	add d
	ld b, a
	ld a, c
	add e
	ld c, a
	ret

CutAnimationOffsets:
; Each pair represents the x and y pixels offsets from the player of where the cut tree animation should be drawn
	db  8, 36 ; player is facing down
	db  8,  4 ; player is facing up
	db -8, 20 ; player is facing left
	db 24, 20 ; player is facing right

BoulderDustAnimationOffsets:
; Each pair represents the x and y pixels offsets from the player of where the cut tree animation should be drawn
; These offsets represent 2 blocks away from the player
	db  8,  52 ; player is facing down
	db  8, -12 ; player is facing up
	db -24, 20 ; player is facing left
	db 40,  20 ; player is facing right

ReplaceTreeTileBlock:
; Determine the address of the tile block that contains the tile in front of the
; player (i.e. where the tree is) and replace it with the corresponding tile
; block that doesn't have the tree.
	push de
	ld a, [wCurMapWidth]
	add 6
	ld c, a
	ld b, 0
	ld d, 0
	ld hl, wCurrentTileBlockMapViewPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
	ld a, [wSpritePlayerStateData1FacingDirection]
	and a
	jr z, .down
	cp SPRITE_FACING_UP
	jr z, .up
	cp SPRITE_FACING_LEFT
	jr z, .left
; right
	ld a, [wXBlockCoord]
	and a
	jr z, .centerTileBlock
	jr .rightOfCenter
.down
	ld a, [wYBlockCoord]
	and a
	jr z, .centerTileBlock
	jr .belowCenter
.up
	ld a, [wYBlockCoord]
	and a
	jr z, .aboveCenter
	jr .centerTileBlock
.left
	ld a, [wXBlockCoord]
	and a
	jr z, .leftOfCenter
	jr .centerTileBlock
.belowCenter
	add hl, bc
.centerTileBlock
	add hl, bc
.aboveCenter
	ld e, $2
	add hl, de
	jr .next
.leftOfCenter
	ld e, $1
	add hl, bc
	add hl, de
	jr .next
.rightOfCenter
	ld e, $3
	add hl, bc
	add hl, de
.next
	pop de
	ld a, [hl]
	ld c, a
.loop ; find the matching tile block in the array
	ld a, [de]
	inc de
	inc de
	cp $ff
	ret z
	cp c
	jr nz, .loop
	dec de
	ld a, [de] ; replacement tile block from matching array entry
	ld [hl], a
	ret

INCLUDE "data/tilesets/cut_tree_blocks.asm"
