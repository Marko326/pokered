Route1_Script:
	jp EnableAutoTextBoxDrawing

Route1_TextPointers:
	dw Route1Text1
	dw Route1Text2
	dw Route1Text3

Route1Text1:
	text_asm
	CheckAndSetEvent EVENT_GOT_POTION_SAMPLE
	jr nz, .got_item
	ld hl, Route1ViridianMartSampleText
	call PrintText
	lb bc, POTION, 1
	call GiveItem
	jr nc, .bag_full
	ld hl, Route1Text_1cae8
	jr .done
.bag_full
	ld hl, Route1Text_1caf3
	jr .done
.got_item
	ld hl, Route1Text_1caee
.done
	call PrintText
	jp TextScriptEnd

Route1ViridianMartSampleText:
	text_far _Route1ViridianMartSampleText
	text_end

Route1Text_1cae8:
	text_far _Route1Text_1cae8
	sound_get_item_1
	text_end

Route1Text_1caee:
	text_far _Route1Text_1caee
	text_end

Route1Text_1caf3:
	text_far _Route1Text_1caf3
	text_end

Route1Text2:
    ; LANGUAGE phase 1 sample: reuse the global setting from OPTIONS.
    ; 0 = xlsx-imported CHS text, 1 = preserved original English text.
    text_asm
    ld a, [wOptions]
    bit 5, a
    ld hl, Route1Text2CHS
    jr z, .print
    ld hl, Route1Text2EN
.print
    call PrintText
    jp TextScriptEnd

Route1Text2CHS:
    text_far _Route1Text2
    text_end

Route1Text2EN:
    text_far _Route1Text2English
    text_end

Route1Text3:
	text_far _Route1Text3
	text_end
