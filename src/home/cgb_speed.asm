; CPU-1.6: CGB-only CPU speed switching. Keep the tested CGB palettes untouched.
; Called from ROM0 or ROMX; the STOP sequence stays in fixed bank 0.

GBCSetCPU1xSpeed::
	push af
	ldh a, [hCGB]
	and a
	jr z, .done
	ldh a, [rKEY1]
	bit 7, a
	call nz, CGBSwitchCPUSpeed
.done
	pop af
	ret

GBCSetCPU2xSpeed::
	push af
	ldh a, [hCGB]
	and a
	jr z, .done
	ldh a, [rKEY1]
	bit 7, a
	call z, CGBSwitchCPUSpeed
.done
	pop af
	ret

CGBSwitchCPUSpeed:
	; Prevent interrupts during KEY1/STOP. The callers run with IME on.
	di
	ldh a, [rIE]
	push af
	xor a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	ld a, 1
	ldh [rKEY1], a
	stop
	pop af
	ldh [rIE], a
	ei
	ret
