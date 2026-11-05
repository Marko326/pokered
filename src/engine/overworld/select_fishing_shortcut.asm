; RPP #381 CHS adaptation: shore SELECT with a remembered BAG rod.
; Land: only facing water is intercepted. Surf: SELECT works on water.
; Saved magic and rod ID use three already-reserved game-progress bytes.
; The magic rejects stale bytes from older saves; the Bag is checked at use.
TrySelectShoreFishing::
	; RPP #383: while Surfing, use the same last Bag rod from SELECT.
	; On land, retain the original facing-water check / bicycle fallback.
	ld a, [wWalkBikeSurfState]
	cp 2
	jr z, .checkRod
	predef GetTileAndCoordsInFrontOfPlayer
	farcall IsNextTileShoreOrWater
	jp c, .notShore
.checkRod

	ld a, [wLastBagFishingRodMagic]
	cp $a7
	jp nz, .noRecordedRod
	ld a, [wLastBagFishingRodMagic + 1]
	cp $5c
	jp nz, .noRecordedRod
	ld a, [wLastBagFishingRod]
	cp OLD_ROD
	jp c, .noRecordedRod
	cp SUPER_ROD + 1
	jp nc, .noRecordedRod
	ld b, a
	push bc
	call IsItemInBag
	pop bc
	jp z, .missingRod

	; DisplayTextIDInit creates a proper CHS/DFS text window.
	; A SELECT cast is already in overworld; preserve the live window
	; in both land and Surf states, without a second map redraw.
	push bc
	call .openText
	pop bc
	ld a, b
	ld [wcf91], a
	ld [wd11e], a
	call GetItemName
	call CopyToStringBuffer
	xor a
	ld [wPseudoItemID], a
	ld a, $80
	ld [wRepeatFishingRod], a
	call UseItem ; original rod RNG, FishingAnim, no-bite retry
	xor a
	ld [wPseudoItemID], a
	ld [wRepeatFishingRod], a ; no shortcut state survives this SELECT
	call .closeText
	scf
	ret

.noRecordedRod
	call .openText
	ld hl, FirstBagRodText
	jr .showNotice
.missingRod
	call .openText
	ld hl, MissingBagRodText
.showNotice
	call PrintText
	call ManualTextScroll ; wait for A/B, do not flash the notice
	call .closeText
	scf ; water-facing SELECT is consumed, even without a rod
	ret
.notShore
	and a ; clear carry: fall back to the original bike shortcut
	ret

.openText
	call EnableAutoTextBoxDrawing
	ld a, 1
	ldh [hSpriteIndexOrTextID], a
	farcall DisplayTextIDInit
	ret
.closeText
	; CloseTextDisplay expects the saved ROM bank on the stack.
	ldh a, [hLoadedROMBank]
	push af
	jp CloseTextDisplay

; Only called from a deliberate START-BAG Use choice. No menu, RNG,
; fishing response or stored save data is otherwise modified.
RememberBagFishingRod::
	ld a, [wcf91]
	cp OLD_ROD
	ret c
	cp SUPER_ROD + 1
	ret nc
	ld [wLastBagFishingRod], a
	ld a, $a7
	ld [wLastBagFishingRodMagic], a
	ld a, $5c
	ld [wLastBagFishingRodMagic + 1], a
	ret

FirstBagRodText::
	text_start
	 db $0e, $ab, $11, $d2, $13, $f6, $05, $3b, $05, $26 ; 请先在背包
	db "<LINE>"
	 db $0f, $b1, $13, $81, $07, $32, $08, $42, $01, $03 ; 使用钓竿。
	 db CHARVAL("@")
	text_end
MissingBagRodText::
	text_start
	 db $07, $32, $08, $42, $05, $b7, $13, $f6, $05, $3b, $05, $26, $01, $03 ; 钓竿不在背包。
	 db CHARVAL("@")
	text_end
