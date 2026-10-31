; ROM-1.20A: stable ROM0 interfaces for banked script/event callers.
; Both entry points have no register arguments and callers inspect
; wCurrentMenuItem (not the return value of A/HL/BC).
; Bankswitch restores the original caller bank before returning; LD
; instructions in the return stub do not alter the callee's flags.
YesNoChoice::
	farjp YesNoChoice_

YesNoChoicePokeCenter::
	farjp YesNoChoicePokeCenter_
