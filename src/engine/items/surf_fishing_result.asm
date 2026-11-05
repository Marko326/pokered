; RPP #383, CHS adaptation: preserve Surf player/mount sprites and OAM.
; No land FishingAnim is called while wWalkBikeSurfState = 2.
; Preserve the current CHS random wait (10 + 36..163 frames), separate
; from the result RNG, fish encounter data, and the 20-frame initial cast.
PresentSurfFishingResult::
	ld c, 10
	call DelayFrames
	call Random
	and $7f
	add 36
	ld c, a
	call DelayFrames
	ld a, [wRodResponse]
	and a
	ld hl, .noBite
	jr z, .showText
	cp 2
	ld hl, .noFishHere
	jr z, .showText
	; RPP #384: only a real bite bobs the Surf player and mount.
	; Toggle the screen Y low bit 10 times (3 frames each); an even
	; number of toggles restores the exact initial position.
	; No land rod tiles, rod OAM reservation or Surf state change.
	ld b, 10
.shakeSurf
	ld hl, wSpritePlayerStateData1YPixels
	ld a, [hl]
	xor 1
	ld [hl], a
	call Delay3
	dec b
	jr nz, .shakeSurf
	; Use the native emote path: it handles OAM space and redraw.
	xor a
	ld [wEmotionBubbleSpriteIndex], a
	ld [wWhichEmotionBubble], a ; EXCLAMATION_BUBBLE
	predef EmotionBubble
	ld hl, .gotBite
.showText
	jp PrintText
.noBite
	text_far _NoNibbleText
	text_end
.noFishHere
	text_far _NothingHereText
	text_end
.gotBite
	text_far _ItsABiteText
	text_end
