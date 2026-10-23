; b = new color for BG color 0 (usually white) for 4 frames
ChangeBGPalColor0_4Frames:
	call GetPredefRegisters
	ldh a, [rBGP]
	or b
	ldh [rBGP], a
	ld c, 4
	call DelayFrames
	ldh a, [rBGP]
	and %11111100
	ldh [rBGP], a
	ret

PredefShakeScreenVertically:
; GFX-1.0.7: keep the original 3-frame shake, but update WY during VBlank.
	call GetPredefRegisters
	ldh a, [hWY]
	push af
	ld a, 1
	ld [wDisableVBlankWYUpdate], a
	xor a
.loop
	ldh [hMutateWY], a
	call .MutateWY
	call .MutateWY
	dec b
	ld a, b
	jr nz, .loop
; GFX-1.0.7: restore the caller's WY instead of assuming it was zero.
	pop af
	ldh [hWY], a
	xor a
	ld [wDisableVBlankWYUpdate], a
	ret

.MutateWY
	ldh a, [hMutateWY]
	xor b
	ldh [hMutateWY], a
	ld c, 3
	jp .SetWYForFrames

.SetWYForFrames
; GFX-1.0.7: latch via hWY for one VBlank, then hold for two frames.
	ldh [hWY], a
	push bc
	xor a
	ld [wDisableVBlankWYUpdate], a
	ld c, 1
	call DelayFrames
	ld a, 1
	ld [wDisableVBlankWYUpdate], a
	pop bc
	dec c
	ret z
	jp DelayFrames

PredefShakeScreenHorizontally:
; Moves the window right and then back in a sequence of progressively smaller
; numbers of pixels, starting at b.
	call GetPredefRegisters
	xor a
.loop
	ldh [hMutateWX], a
	call .MutateWX
	ld c, 1
	call DelayFrames
	call .MutateWX
	dec b
	ld a, b
	jr nz, .loop

; restore normal WX
	ld a, 7
	ldh [rWX], a
	ret

.MutateWX
	ldh a, [hMutateWX]
	xor b
	ldh [hMutateWX], a
	bit 7, a ; negative?
	jr z, .skipZeroing
	xor a ; zero a if it's negative
.skipZeroing
	add 7
	ldh [rWX], a
	ld c, 4
	jp DelayFrames
