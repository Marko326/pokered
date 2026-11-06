; CHS / RPP #086 Fly guide: repeat conversation only.
; Original four translated lines are reproduced verbatim from _G1RB.json;
; new special-Fly instructions follow in this SAME text stream.
FlyHouseExplanationWithSpecialFlyTips::
	text_start
	db $0c, $e4, $06, $81, $12, $8b, $11, $ba, $0e, $44, $01, $e6, $01, $e8 ; 秘传学习器０２
	db CHARVAL("<LINE>")
	db $0f, $bf, $01, $10, $07, $d7, $11, $f2, $01, $11, $01, $d7 ; 是“飞翔”！
	db CHARVAL("<CONT>")
	db $18, $7a, $0f, $bf, $08, $80, $07, $d5, $06, $01, $07, $cb, $05, $81, $06, $f8, $18, $68, $0f, $b5, $01, $d7 ; 这是个非常方便的招式！
	db CHARVAL("<PARA>")
	db $0d, $6b, $12, $ec, $11, $0b, $0f, $60, $0f, $b1, $13, $81, $0d, $9c, $01, $d7 ; 你要妥善使用哦！
	db CHARVAL("<PARA>")
	; First teach the ordinary town selector (Up/Down + A), then the
	; optional visited-special-location axis (Left/Right).
	db $13, $f6, $07, $d7, $12, $41, $07, $10, $10, $ec, $0f, $69, $01, $e2 ; 在飞行地图上，
	db CHARVAL("<LINE>")
	db $04, $d6, $01, $76, $01, $77, $12, $85, $18, $11, $06, $29, $18, $8a, $01, $e2 ; 按↑↓选择城镇，
	db CHARVAL("<CONT>")
	db $04, $d6, "A", $0a, $24, $07, $d7, $11, $31, $0d, $31, $06, $f8, $07, $10, $01, $d7 ; 按A键飞往目的地！
	db CHARVAL("<PARA>")
	db $04, $d6, $01, $75, $01, $74, $0e, $90, $09, $7d ; 按←→切换
	db CHARVAL("<LINE>")
	db $0e, $c3, $08, $e5, $06, $f8, $10, $aa, $0f, $da, $07, $10, $07, $1e, $01, $03 ; 去过的特殊地点。
	done
