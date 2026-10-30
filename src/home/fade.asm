; These routines manage gradual fading
; (e.g., entering a doorway)
LoadGBPal::
	ld a, [wMapPalOffset] ; tells if wCurMap is dark (requires HM5_FLASH?)
	ld b, a
	ld hl, FadePal4
	ld a, l
	sub b
	ld l, a
	jr nc, .ok
	dec h
.ok
	; After a normal doorway warp, restore new-map shades at VBlank too.
	; Regular overworld LoadGBPal calls stay on the original fast path.
	ld a, [wDoorFadeRestore]
	and a
	jr z, .immediate
	xor a
	ld [wDoorFadeRestore], a
	ld a, [hli]
	ld [wDoorFadeBGP], a
	ld a, [hli]
	ld [wDoorFadeOBP0], a
	ld a, [hli]
	ld [wDoorFadeOBP1], a
	ld a, 1
	ld [wDoorFadePending], a
	ret
.immediate
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hli]
	ldh [rOBP1], a
	ret

GBFadeInFromBlack::
	ld hl, FadePal1
	ld b, 4
	jr GBFadeIncCommon

GBFadeOutToWhite::
	ld hl, FadePal6
	ld b, 3

GBFadeIncCommon:
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hli]
	ldh [rOBP1], a
	ld c, 8
	call DelayFrames
	dec b
	jr nz, GBFadeIncCommon
	ret

; DMG doorway-only fade. Each shade step commits in VBlank;
; CGB keeps the DOR-1.17B original fade unchanged.
GBDoorFadeOutToBlackVBlank::
	ld hl, FadePal4 + 2
	ld b, 4
.loop
	ld a, [hld]
	ld [wDoorFadeOBP1], a
	ld a, [hld]
	ld [wDoorFadeOBP0], a
	ld a, [hld]
	ld [wDoorFadeBGP], a
	ld a, 1
	ld [wDoorFadePending], a
	ld c, 8
	call DelayFrames
	dec b
	jr nz, .loop
	; One scheduled restoration in LoadGBPal after the new map is ready.
	ld a, 1
	ld [wDoorFadeRestore], a
	ret

GBFadeOutToBlack::
	ld hl, FadePal4 + 2
	ld b, 4
	jr GBFadeDecCommon

GBFadeInFromWhite::
	ld hl, FadePal7 + 2
	ld b, 3

GBFadeDecCommon:
	ld a, [hld]
	ldh [rOBP1], a
	ld a, [hld]
	ldh [rOBP0], a
	ld a, [hld]
	ldh [rBGP], a
	ld c, 8
	call DelayFrames
	dec b
	jr nz, GBFadeDecCommon
	ret

FadePal1:: db %11111111, %11111111, %11111111
FadePal2:: db %11111110, %11111110, %11111000
FadePal3:: db %11111001, %11100100, %11100100
FadePal4:: db %11100100, %11010000, %11100000
;                rBGP      rOBP0      rOBP1
FadePal5:: db %11100100, %11010000, %11100000
FadePal6:: db %10010000, %10000000, %10010000
FadePal7:: db %01000000, %01000000, %01000000
FadePal8:: db %00000000, %00000000, %00000000
