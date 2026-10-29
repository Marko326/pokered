; QOL-1.17 CHS port of Red++ BATTLE-5.19.9 (battle direct-damage only).
; No nickname/save changes. See docs/HP_DAMAGE_SPEED_PORT.md for deltas.
; Generic UpdateHPBar2 / UpdateShortHPBar remain untouched.
; QOL-1.17 / source Red++ BATTLE-5.19.9
; Direct opponent-target damage uses exact effective-HP-loss percentages.
;
; Only ordinary attacks where the acting side and target HUD are opposite mons
; use the accelerated path (hWhoseTurn == wHPBarType):
;   < 25% max HP loss = original UpdateHPBar2, unchanged
;   25% - <50%         = normal    : 1 pixel / 1 frame
;   50% - <75%         = fast      : 2 pixels / 1 frame
;   >=75%               = very fast : 4 pixels / 1 frame
;
; Confusion self-damage and Jump Kick / Hi Jump Kick crash damage have
; hWhoseTurn != wHPBarType and therefore also keep original UpdateHPBar2.
; Healing, ordinary recoil, items and other generic HP-bar callers never enter
; this wrapper and retain their existing cadence.
;
; BATTLE-5.19.9 smooth display refinement:
; accelerated damage temporarily disables normal one-third AutoBG transfer.
; Each real animation wait requests a TILE-ONLY VBlank row copy, so battle
; Pokemon palette attributes are left untouched. Enemy HUD copies one row;
; player HUD copies two rows so its numeric HP remains synchronized.
; The >=75% tier uses 4 visible pixels/frame to retain the punch of the older
; chunkier AutoBG presentation while still updating every display frame.

DEF HP_DAMAGE_SPEED_NORMAL    EQU 1
DEF HP_DAMAGE_SPEED_FAST      EQU 2
DEF HP_DAMAGE_SPEED_VERY_FAST EQU 3

UpdateAttackDamageHPBar:
	; The normal player->enemy and enemy->player paths have matching turn/HUD
	; selectors (0/0 or 1/1). Self-inflicted paths deliberately mismatch.
	ldh a, [hWhoseTurn]
	ld b, a
	ld a, [wHPBarType]
	cp b
	jr nz, .original

	; Calculate effective damage = old HP - new HP. wHPBar* HP values are
	; little-endian, while wHPBarHPDifference is big-endian for TX_NUM.
	ld a, [wHPBarOldHP]
	ld c, a
	ld a, [wHPBarOldHP + 1]
	ld b, a
	ld a, [wHPBarNewHP]
	ld e, a
	ld a, [wHPBarNewHP + 1]
	ld d, a
	ld a, c
	sub e
	ld e, a
	ld a, b
	sbc d
	ld d, a
	ld a, e
	ld [wHPBarHPDifference + 1], a
	ld a, d
	ld [wHPBarHPDifference], a

	; Classify against max HP without division. BC = damage, DE = max HP.
	; 25%: 4D >= M. 50%: 2D >= M. 75%: 4D >= 3M.
	ld b, d
	ld c, e
	ld a, [wHPBarMaxHP]
	ld e, a
	ld a, [wHPBarMaxHP + 1]
	ld d, a

	ld h, b
	ld l, c
	add hl, hl ; 2 * damage
	ld b, h
	ld c, l   ; keep 2 * damage in BC
	add hl, hl ; 4 * damage
	call .compareHLDE
	jr c, .original ; 4D < M => strictly below 25%

	ld h, b
	ld l, c
	call .compareHLDE
	jr c, .normal ; 2D < M => 25% - <50%

	; BC currently holds 2D. Build 4D in BC and 3M in HL.
	add hl, hl
	ld b, h
	ld c, l
	ld h, d
	ld l, e
	add hl, hl
	add hl, de
	ld a, b
	cp h
	jr c, .fast
	jr nz, .veryFast
	ld a, c
	cp l
	jr c, .fast

.veryFast
	ld a, HP_DAMAGE_SPEED_VERY_FAST
	jr .setSpeed
.fast
	ld a, HP_DAMAGE_SPEED_FAST
	jr .setSpeed
.normal
	ld a, HP_DAMAGE_SPEED_NORMAL
.setSpeed
	ld [wHPBarDamageSpeed], a
	xor a
	ld [wHPBarDamagePhase], a

	; callab consumes HL, so rebuild the HUD tile pointer from wHPBarType.
	ld a, [wHPBarType]
	and a
	jr z, .enemyHUD
	coord hl, 10, 9
	jr .animate
.enemyHUD
	coord hl, 2, 2
.animate
	call AttackHPBar_AnimateDamage

	; Scratch state must never leak into a later battle/menu operation.
	xor a
	ld [wHPBarDamageSpeed], a
	ld [wHPBarDamagePhase], a
	ret

.original
	; BATTLE-5.19.7: <25% and self-inflicted damage use the unmodified original
	; animation, including numeric HP pacing and the original 2-frame pixel wait.
	ld a, [wHPBarType]
	and a
	jr z, .originalEnemyHUD
	coord hl, 10, 9
	predef UpdateHPBar2
	ret
.originalEnemyHUD
	coord hl, 2, 2
	predef UpdateHPBar2
	ret

.compareHLDE
	; Carry set iff unsigned HL < DE.
	ld a, h
	cp d
	ret nz
	ld a, l
	cp e
	ret

; Animate an accelerated direct-damage decrease one actual HP point at a time
; so the player's number still counts down, while visible timing is driven by
; bar pixels rather than by one DelayFrame per HP point.
; hl = HUD HP-bar tile pointer.
AttackHPBar_AnimateDamage:
	; Keep intermediate 1-pixel states in wTileMap from leaking through the
	; normal top/middle/bottom AutoBG cycle. Dedicated tile-only VBlank copies
	; below expose only the intended 1/2/4-pixel visible steps.
	ldh a, [hAutoBGTransferEnabled]
	push af
	xor a
	ldh [hAutoBGTransferEnabled], a

	; Keep the final target HP in DE while wHPBarNewHP temporarily walks toward it.
	ld a, [wHPBarNewHP]
	ld e, a
	ld a, [wHPBarNewHP + 1]
	ld d, a
.loop
	ld a, [wHPBarOldHP]
	ld c, a
	ld a, [wHPBarOldHP + 1]
	ld b, a
	ld a, b
	cp d
	jr nz, .step
	ld a, c
	cp e
	jr z, .done
.step
	push de
	dec bc
	ld a, c
	ld [wHPBarNewHP], a
	ld a, b
	ld [wHPBarNewHP + 1], a
	call AttackHPBar_CalcOldNewHPBarPixels
	ld a, e
	sub d
	call AttackHPBar_PrintHPNumber
	and a
	jr z, .noPixelDifference
	call AttackHPBar_AnimatePixels
.noPixelDifference
	ld a, [wHPBarNewHP]
	ld [wHPBarOldHP], a
	ld a, [wHPBarNewHP + 1]
	ld [wHPBarOldHP + 1], a
	pop de
	jr .loop

.done
	; Draw the exact final bar state. GetHPBarLength intentionally floors all
	; nonzero HP to at least 1 pixel, so handle 0 HP separately.
	ld a, d
	or e
	jr z, .fainted
	ld b, d
	ld c, e
	ld a, [wHPBarMaxHP]
	ld e, a
	ld a, [wHPBarMaxHP + 1]
	ld d, a
	call AttackHPBar_GetLength
	jr .drawFinal
.fainted
	ld e, 0
	ld c, 0
.drawFinal
	call AttackHPBar_PrintHPNumber
	ld d, 6
	call AttackDrawHPBarWithColor
	; Expose the exact final bar/number once, then restore the caller's AutoBG
	; state. No Delay3 is needed because this copy is not waiting for a third.
	call AttackHPBar_WaitVisibleFrame
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

; a = number of bar pixels to remove, e = current bar length in pixels.
AttackHPBar_AnimatePixels:
	push hl
.loop
	push af
	; Draw the next shorter state so the first visible accelerated frame moves.
	dec e
	ld d, 6
	call AttackDrawHPBarWithColor
	call WaitAttackDamageHPBarFrame
	pop af
	dec a
	jr nz, .loop
	pop hl
	ret

; Accelerated-path wait policy. 1 px/frame needs no phase; the 2 px/frame and
; 4 px/frame tiers carry phase across individual HP steps.
WaitAttackDamageHPBarFrame:
	ld a, [wHPBarDamageSpeed]
	cp HP_DAMAGE_SPEED_FAST
	jr z, .fast
	cp HP_DAMAGE_SPEED_VERY_FAST
	jr z, .veryFast
	; 25%-<50% and any unexpected value use one visible pixel per frame.
	jp AttackHPBar_WaitVisibleFrame
.fast
	; Submit two successive pixel states before exposing the latest one.
	ld a, [wHPBarDamagePhase]
	xor 1
	ld [wHPBarDamagePhase], a
	ret nz
	jp AttackHPBar_WaitVisibleFrame
.veryFast
	; Four visible pixels/frame restores the very-fast feel while the dedicated
	; copy keeps the motion regular instead of bunching several frames together.
	ld a, [wHPBarDamagePhase]
	inc a
	cp 4
	jr nc, .veryFastWait
	ld [wHPBarDamagePhase], a
	ret
.veryFastWait
	xor a
	ld [wHPBarDamagePhase], a
	jp AttackHPBar_WaitVisibleFrame

; Queue a TILE-ONLY row transfer for the next VBlank and wait exactly one frame.
 ; CHS VBlankCopyBgMap/TransferBgRows is already TILE ONLY; unlike RPP it
; does not copy CGB attributes. Schedule 1/2 normal rows, not bit-7 mode.
; Thus no changes to the battle palettes or ROM0 VBlank path are necessary.
AttackHPBar_WaitVisibleFrame:
	push bc
	push de
	push hl

	ld a, [wHPBarType]
	and a
	jr z, .enemyHUD

	; Player: row 9 contains the bar and row 10 contains numeric HP.
	coord hl, 0, 9
	ld de, 9 * BG_MAP_WIDTH
	ld b, 2
	jr .schedule

.enemyHUD
	; Enemy: only row 2 is needed.
	coord hl, 0, 2
	ld de, 2 * BG_MAP_WIDTH
	ld b, 1

.schedule
	; hVBlankCopyBGSource low byte doubles as the enable flag. Enable only after the
	; source high byte, destination and mode/count have all been prepared.
	xor a
	ldh [hVBlankCopyBGSource], a
	ld c, l
	ld a, h
	ldh [hVBlankCopyBGSource + 1], a
	ld a, b
	ldh [hVBlankCopyBGNumRows], a

	ldh a, [hAutoBGTransferDest]
	ld l, a
	ldh a, [hAutoBGTransferDest + 1]
	ld h, a
	add hl, de
	ld a, l
	ldh [hVBlankCopyBGDest], a
	ld a, h
	ldh [hVBlankCopyBGDest + 1], a

	ld a, c
	ldh [hVBlankCopyBGSource], a

	pop hl
	pop de
	pop bc
	jp DelayFrame

; Same HP-number update as UpdateHPBar_PrintHPNumber, but without DelayFrame.
; The original path never calls this routine.
AttackHPBar_PrintHPNumber:
	push af
	push de
	ld a, [wHPBarType]
	and a
	jr z, .done ; enemy HUD has no numeric HP display
	ld a, [wHPBarOldHP]
	ld [wHPBarTempHP + 1], a
	ld a, [wHPBarOldHP + 1]
	ld [wHPBarTempHP], a
	push hl
	; CHS battle layout displays the player's three-digit HP at +$15.
	; The status/party alternate positions never use this attack-only routine.
	ld de, $15
	add hl, de
	push hl
	ld a, CHARVAL(" ")
	ld [hli], a
	ld [hli], a
	ld [hli], a
	pop hl
	ld de, wHPBarTempHP
	lb bc, 2, 3
	call PrintNumber
	pop hl
.done
	pop de
	pop af
	ret

; Calculate old/new HP bar lengths from the shared HP animation variables.
; Returns d = new pixels, e = old pixels.
AttackHPBar_CalcOldNewHPBarPixels:
	push hl
	ld hl, wHPBarMaxHP
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	push de
	call AttackHPBar_GetLength
	ld a, e
	pop de
	pop bc
	push af
	call AttackHPBar_GetLength
	pop af
	ld d, e
	ld e, a
	pop hl
	ret

; bc * 48 / de, matching GetHPBarLength including its 1-pixel nonzero floor.
AttackHPBar_GetLength:
	push hl
	xor a
	ld hl, hMultiplicand
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld [hl], $30
	call Multiply
	ld a, d
	and a
	jr z, .maxHPSmaller256
	srl d
	rr e
	srl d
	rr e
	ldh a, [hMultiplicand + 1]
	ld b, a
	ldh a, [hMultiplicand + 2]
	srl b
	rr a
	srl b
	rr a
	ldh [hMultiplicand + 2], a
	ld a, b
	ldh [hMultiplicand + 1], a
.maxHPSmaller256
	ld a, e
	ldh [hDivisor], a
	ld b, $4
	call Divide
	ldh a, [hMultiplicand + 2]
	ld e, a
	pop hl
	and a
	ret nz
	ld e, $1
	ret

; Local copy of DrawHPBarWithColor so the attack-only engine can stay in a
; relocatable ROMX section without adding code to the nearly-full HP-bar bank.
AttackDrawHPBarWithColor:
	call DrawHPBar
	push bc
	push de
	push hl

	; Match CHS GetBattleHealthBarColor. RPP's CGB-specific attribute
	; palette path must NOT be copied into CHS's native GB shade mapping.
	ld a, [wHPBarType]
	and a
	ld hl, wEnemyHPBarColor
	jr z, .gotColorPointer
	ld hl, wPlayerHPBarColor
.gotColorPointer
	ld b, [hl]
	call GetHealthBarColor
	ld a, [hl]
	cp b
	jr z, .done
	ld b, SET_PAL_BATTLE
	call RunPaletteCommand
.done
	pop hl
	pop de
	pop bc
	ret
