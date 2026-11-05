; RPP #031/#032 adapted for CHS: A-facing-tree/water field-move dialogue.
; Called by home/overworld.asm ONLY after hidden-object and NPC/sign checks.
; Uses the existing party move, badge, tile, water-pair and map restrictions.
TryCutSurfOnA::
	; No direct Surf shortcut when already on the water.
	ld a, [wWalkBikeSurfState]
	cp 2
	ret z
	predef GetTileAndCoordsInFrontOfPlayer

	; RPP #031: only tree tiles, not CUT's optional tall grass.
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	jr z, .outdoorTree
	cp GYM
	jp nz, .checkSurf
	; The Gym tree has 4 graphic quadrants.  The previous shortcut
	; only matched $50, so A did nothing at the other 3 edges.
	ld a, [wTileInFrontOfPlayer]
	cp $40
	jr z, .tree
	cp $41
	jr z, .tree
	cp $50
	jr z, .tree
	cp $51
	jr z, .tree
	jp .checkSurf
.outdoorTree
	; All four quadrants of the cut tree occur only in the 5
	; overworld CutTreeBlockSwaps blocks (not in decorative trees).
	ld a, [wTileInFrontOfPlayer]
	cp $2d
	jr z, .tree
	cp $2e
	jr z, .tree
	cp $3d
	jr z, .tree
	cp $3e
	jp nz, .checkSurf
.tree
	ld d, CUT
	call .findPartyMonWithMove
	jr nc, .cannotCut
	ld a, [wObtainedBadges]
	bit BIT_CASCADEBADGE, a
	jr z, .cannotCut
	call .openText
	ld hl, .wantCutText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .closeText
	; Match RPP #031: keep the normal success text and Cut animation,
	; but enter at Cut2 to skip the white palette / map rebuild of Party Cut.
	call GetPartyMonName2
	farcall UsedCutFromFieldA
	jp .closeText
.cannotCut
	call .openText
	ld hl, .canCutText
	call PrintText
	call ManualTextScroll
	jp .closeText

.checkSurf
	; Reuse the same tile and directional pair checks as SURFBOARD.
	farcall IsNextTileShoreOrWater
	ret c
	ld hl, TilePairCollisionsWater
	call CheckForTilePairCollisions2
	ret c
	ld d, SURF
	call .findPartyMonWithMove
	jp nc, .cannotSurf
	ld a, [wObtainedBadges]
	bit BIT_SOULBADGE, a
	jp z, .cannotSurf
	; IsSurfingAllowed may itself print a Cycling Road/Seafoam notice.
	call .openText
	farcall IsSurfingAllowed
	ld hl, wd728
	bit 1, [hl]
	res 1, [hl]
	jr z, .surfBlocked
	ld hl, .wantSurfText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .closeText
	; Match RPP TrySurf: prepare the Pokemon nickname first; the original
	; SURFBOARD routine prints its success text after changing Surf state.
	; Keep the textbox alive until that message has been shown, then close.
	call GetPartyMonName2
	ld a, SURFBOARD
	ld [wcf91], a
	ld [wPseudoItemID], a
	call UseItem
	jp .closeText
.surfBlocked
	; IsSurfingAllowed has already printed the reason for rejection.
	; An extra ManualTextScroll here diverged from RPP's normal lifecycle.
	jr .closeText
.cannotSurf
	call .openText
	ld hl, .calmWaterText
	call PrintText
	call ManualTextScroll
	; fall through
.closeText
	; CloseTextDisplay normally gets its saved bank from DisplayTextID.
	; We are not inside DisplayTextID, so provide exactly that stack slot.
	ldh a, [hLoadedROMBank]
	push af
	jp CloseTextDisplay

.openText
	call EnableAutoTextBoxDrawing
	ld a, 1 ; non-START dialogue; creates normal font/Window state
	ldh [hSpriteIndexOrTextID], a
	farcall DisplayTextIDInit
	ret

; d = move ID. Carry set when found, wWhichPokemon = party index.
; Never alter the party data or stored move list.
.findPartyMonWithMove
	ld a, [wPartyCount]
	and a
	jr z, .none
	ld b, a
	ld c, 0
	ld hl, wPartyMon1Moves
.mon
	ld e, NUM_MOVES
.move
	ld a, [hli]
	cp d
	jr z, .found
	dec e
	jr nz, .move
	push bc
	ld bc, wPartyMon2 - wPartyMon1 - NUM_MOVES
	add hl, bc
	pop bc
	inc c
	dec b
	jr nz, .mon
.none
	and a ; clear carry
	ret
.found
	ld a, c
	ld [wWhichPokemon], a
	scf
	ret

; All new Chinese text is encoded as CHS DFS double-byte glyph IDs.
; Do not replace it with UTF-8 bytes; see the ROM-1.35 #036 fix.
.wantCutText
	text_start
	db $12, $ec, $0f, $b1, $13, $81 ; 要使用
	db $0a, $cd, $09, $1c, $18, $38 ; 居合斩
	db $0c, $9e, $01, $f5, CHARVAL("@") ; 吗？
	text_end
.canCutText
	text_start
	db $18, $7a, $0b, $23, $0f, $ef ; 这棵树
	db $0b, $29, $0b, $0f, $01, $d7 ; 可砍！
	db CHARVAL("@")
	text_end
.wantSurfText
	text_start
	db $12, $ec, $0f, $b1, $13, $81 ; 要使用
	db $06, $48, $0b, $9f ; 冲浪
	db $0c, $9e, $01, $f5, CHARVAL("@") ; 吗？
	text_end
.calmWaterText
	text_start
	db $10, $08, $0c, $f2, $09, $2a ; 水面很
	db $0e, $05, $0a, $ac, $01, $03 ; 平静。
	db CHARVAL("@")
	text_end

; RPP #033: the front sprite's interaction is a boulder instead of an NPC
; script.  The A-button helper shares the dialog opening/closing convention
; already checked for Cut and Surf.  Return carry set when handled, clear for
; normal NPC/sign dialogue.  Bankswitch preserves flags; unlike RPP do not
; use wWhichTrade as a scratch return byte (it also selects real NPC trades).
HandleStrengthBoulderOnA::
	; The regular DisplayTextID path suppresses dialogue when these map
	; script flags are set.  Do not bypass those existing script guards.
	ld a, [wFlags_0xcd60]
	and (1 << 0) | (1 << 2)
	jp nz, .notBoulder
	ldh a, [hSpriteIndexOrTextID]
	and a
	jp z, .notBoulder
	ld b, a
	ld a, [wNumSprites]
	cp b
	jp c, .notBoulder ; sign IDs are not sprite IDs
	; CHS GetSpriteMovementByte2Pointer reads hSpriteIndex, NOT
	; hSpriteIndexOrTextID.  Index the map sprite table directly to avoid
	; corrupting the independent hSpriteIndex used by movement code.
	ld a, b
	dec a
	add a
	ld e, a
	ld d, 0
	ld hl, wMapSpriteData
	add hl, de
	ld a, [hl]
	cp BOULDER_MOVEMENT_BYTE_2
	jp nz, .notBoulder

	call TryCutSurfOnA.openText
	; If Strength is already enabled, do not ask to use it again.
	ld hl, wd728
	bit 0, [hl]
	jr nz, .alreadyActive
	; Keep RPP's order: party move first, Rainbow Badge second.
	ld d, STRENGTH
	call TryCutSurfOnA.findPartyMonWithMove
	jr nc, .cannotUse
	ld a, [wObtainedBadges]
	bit BIT_RAINBOWBADGE, a
	jr z, .cannotUse
	ld hl, .wantStrengthText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .closeHandled ; NO / B never activates Strength
	call GetPartyMonName2
	ld hl, wd728
	set 0, [hl]
	ld hl, .canMoveBouldersText
	call PrintText
	jr .closeHandled
.alreadyActive
	ld d, STRENGTH
	call TryCutSurfOnA.findPartyMonWithMove
	jr nc, .cannotUse
	call GetPartyMonName2
	ld hl, .canMoveBouldersText
	call PrintText
	jr .closeHandled
.cannotUse
	; Use the project's existing original boulder warning so its
	; translation, punctuation, and text-speed handling stay unchanged.
	ld hl, .boulderNeedsStrengthText
	call PrintText
	call ManualTextScroll
.closeHandled
	; This helper pushes its saved ROM bank and tail-jumps through
	; CloseTextDisplay.  CALL is safe: it returns here after Window cleanup.
	call TryCutSurfOnA.closeText
	scf ; handled boulder
	ret
.notBoulder
	and a ; clear carry, leave all NPC/sign state untouched
	ret

.wantStrengthText
	text_start
	db $12, $ec, $0f, $b1, $13, $81 ; 要使用
	db $08, $be, $0b, $d8 ; 怪力
	db $0c, $9e, $01, $f5, CHARVAL("@") ; 吗？
	text_end
.boulderNeedsStrengthText
	text_far _BoulderText
	text_end
.canMoveBouldersText
	text_far _CanMoveBouldersText
	text_end
