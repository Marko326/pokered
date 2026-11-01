; This function applies the configurable menu repeat speeds below.
; OUTPUT: [hJoy5] = pressed buttons in usual format.
; hJoy7 = 0 keeps edge-only input; 1..5 select a row in MenuRepeatDelayTable.
; hJoy6 retains its original behavior: when zero, A/B held suppresses repeats.
; A fresh direction press still waits 30 frames before the first repeat.
JoypadLowSensitivity::
	call Joypad
	ldh a, [hJoy7] ; edge-only or repeat-speed mode?
	and a
	ldh a, [hJoyPressed] ; newly pressed buttons
	jr z, .storeButtonState
	ldh a, [hJoy7]
	cp JOY_REPEAT_MODE_START_MENU
	jr nz, .allHeldButtons
	; START menu repeats only Up/Down. A/B/START remain edge-triggered,
	; so holding START to open the menu cannot immediately close it again.
	push bc
	ldh a, [hJoyHeld]
	and D_UP | D_DOWN
	ld b, a
	ldh a, [hJoyPressed]
	or b
	pop bc
	jr .storeButtonState
.allHeldButtons
	ldh a, [hJoyHeld] ; all currently pressed buttons
.storeButtonState
	ldh [hJoy5], a
	ldh a, [hJoyPressed] ; newly pressed buttons
	and a ; have any buttons been newly pressed since last check?
	jr z, .noNewlyPressedButtons
.newlyPressedButtons
	ld a, 30 ; half a second delay
	ldh [hFrameCounter], a
	ret
.noNewlyPressedButtons
	ldh a, [hFrameCounter]
	and a ; is the delay over?
	jr z, .delayOver
.delayNotOver
	xor a
	ldh [hJoy5], a ; report no buttons as pressed
	ret
.delayOver
; if [hJoy6] = 0 and A or B is pressed, report no buttons as pressed
	ldh a, [hJoyHeld]
	and A_BUTTON | B_BUTTON
	jr z, .setShortDelay
	ldh a, [hJoy6] ; flag
	and a
	jr nz, .setShortDelay
	xor a
	ldh [hJoy5], a
.setShortDelay
	; hJoy7 is a 1-based speed-table selector while repeat is enabled.
	; Keep DE/HL intact because JoypadLowSensitivity is a shared helper.
	push hl
	push de
	ldh a, [hJoy7]
	and a
	jr z, .defaultRepeatDelay
	cp JOY_REPEAT_MODE_COUNT + 1
	jr nc, .defaultRepeatDelay
	ld e, a
	ld d, 0
	ld hl, MenuRepeatDelayTable - 1
	add hl, de
	ld a, [hl]
	and a
	jr nz, .restoreRepeatDelay
	; A zero table value is invalid; use the safe 5-frame fallback.
	ld a, 5
	jr .restoreRepeatDelay
.defaultRepeatDelay
	ld a, 5 ; safe fallback for edge-only/unknown modes
.restoreRepeatDelay
	pop de
	pop hl
	ldh [hFrameCounter], a
	ret

; QOL-1.15D: sample START during the menu's VBlank waits. The original
; opening START edge has already updated hJoyLast, so only a distinct
; release/re-press is queued. Preserve registers because callers use them
; as transfer counters/pointers.
CaptureStartMenuInput::
	push af
	push bc
	push de
	push hl
	call Joypad
	ldh a, [hJoyPressed]
	bit BIT_START, a
	jr z, .done
	ld a, 1
	ld [wStartMenuClosePending], a
.done
	pop hl
	pop de
	pop bc
	pop af
	ret

; Shared ROM0 gate for VBlank wait sites. Replacing repeated
; load/test/conditional-call sequences saves code without changing when
; Joypad is sampled or which registers/flags return to each caller.
CaptureStartMenuInputIfEnabled::
	ld a, [wStartMenuInputCapture]
	and a
	ret z
	jp CaptureStartMenuInput

; START-menu-only replacement for Delay3. Polling once per VBlank prevents
; a quick START tap during the cursor settle delay from disappearing.
StartMenuInputDelay3::
	ld c, 3
.loop
	call DelayFrame
	call CaptureStartMenuInput
	dec c
	jr nz, .loop
	ret

WaitForTextScrollButtonPress::
	ldh a, [hDownArrowBlinkCount1]
	push af
	ldh a, [hDownArrowBlinkCount2]
	push af
	xor a
	ldh [hDownArrowBlinkCount1], a
	ld a, $6
	ldh [hDownArrowBlinkCount2], a
.loop
	push hl
	ld a, [wTownMapSpriteBlinkingEnabled]
	and a
	jr z, .skipAnimation
	call TownMapSpriteBlinkingAnimation
.skipAnimation
	hlcoord 18, 17
	ld c, CHARVAL("─")
	call HandleDownArrowBlinkTiming
	pop hl
	call JoypadLowSensitivity
	predef CableClub_Run
	ldh a, [hJoy5]
	and A_BUTTON | B_BUTTON
	jr z, .loop
	pop af
	ldh [hDownArrowBlinkCount2], a
	pop af
	ldh [hDownArrowBlinkCount1], a
	ret

; (unless in link battle) waits for A or B being pressed and outputs the scrolling sound effect
ManualTextScroll::
	ld a, [wLinkState]
	cp LINK_STATE_BATTLING
	jr z, .inLinkBattle
	call WaitForTextScrollButtonPress
	ld a, SFX_PRESS_AB
	jp PlaySound
.inLinkBattle
	ld c, 65
	jp DelayFrames

; =============================================================================
; USER-EDITABLE MENU REPEAT SPEED TABLE
; Values are frames between repeated Up/Down moves at 60 Hz:
;   5 frames  = about 12 repeats/second (faster)
;  10 frames  = about  6 repeats/second (slower)
; The first repeat still waits 30 frames (0.5 seconds) after a fresh press.
; Change the numbers only; the row order is defined by JOY_REPEAT_MODE_*
; in constants/input_constants.asm. Values must be 1..255 (0 falls back
; to a safe 5-frame interval).
;
;   Menu / context                         Frames
MenuRepeatDelayTable::
	db 5  ; 1: Long lists (Bag, shop, Pokédex left list, Town Map)
	db 10 ; 2: Pokémon Party (including traditional SWITCH selection)
	db 10 ; 3: Bill's PC 12-box selector
	db 10 ; 4: Pokédex right-side DATA / CRY / AREA / QUIT menu
	db 10 ; 5: In-game START menu (opened with START on the overworld)

MenuRepeatDelayTableEnd::
ASSERT MenuRepeatDelayTableEnd - MenuRepeatDelayTable == JOY_REPEAT_MODE_COUNT
