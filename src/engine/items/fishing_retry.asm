; RPP #084 / CHS: from Bag rod use, ask again only after no bite.
; The fishing animation has already printed its result and opened a text
; window. Reuse that window; no DisplayTextIDInit / map rebuild here.
PromptRepeatFishingRod::
	ld hl, .question
	call PrintText
	call YesNoChoice
	; Do not leak this Yes/No A/B press into the next overworld frame.
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ret

.question
	text_start
	; 要再钓一次吗？ -- CHS DFS two-byte glyph IDs (not UTF-8).
	db $12, $ec, $13, $f5, $07, $32, $13, $01
	db $06, $a4, $0c, $9e, $01, $f5, CHARVAL("@")
	text_end
