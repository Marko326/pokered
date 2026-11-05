; ROM-1.37 / RPP #382: single continuous text per post-gift NPC.
; Original CHS greeting / HM03 explanation is reproduced verbatim from
; the current translation export; only new instructional pages are appended.
; Keep one TX_FAR + one PrintText so the last original sentence remains
; visible until a real page-button press. DFS two-byte glyphs are from
; src/charmap.txt; no XLSX or generated translation files are modified.

FishingGuruOldRodRepeatText::
	text_start
	db $12, $a1, $01, $0a, $01, $0a ; 呀——
	db CHARVAL("<LINE>")
	db CHARVAL("<PLAYER>"), $01, $d7 ; <PLAYER>！
	db CHARVAL("<PARA>")
	db $19, $60, $0a, $98 ; 最近
	db CHARVAL("<LINE>")
	db $07, $32, $06, $f7, $0f, $09, $09, $1b, $0d, $60, $01, $d7 ; 钓得如何呢！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $13, $f5, $0a, $68, $0d, $6b, $08, $80 ; 对了，再教你个
	db CHARVAL("<LINE>")
	db $07, $32, $13, $a1, $0a, $f1, $0e, $8f, $01, $d7 ; 钓鱼诀窍！
	db CHARVAL("<PARA>")
	db $11, $d2, $06, $a9, $05, $3b, $05, $26, $0b, $c3 ; 先从背包里
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $13, $01, $06, $a4, $07, $32, $08, $42, $01, $03 ; 使用一次钓竿。
	db CHARVAL("<PARA>")
	db $13, $1d, $09, $42, $18, $41, $13, $f6, $04, $d8, $05, $7d, $01, $e2 ; 以后站在岸边，
	db CHARVAL("<LINE>")
	db $0c, $f2, $07, $84, $10, $08, $0c, $f2, $04, $d6 ; 面对水面按
	db CHARVAL("<CONT>")
	db "SELECT", $01, $e2, $0a, $c7, $0d, $64, $18, $a7, $0a, $6f, $07, $32, $13, $a1, $01, $d7 ; SELECT，就能直接钓鱼！
	db CHARVAL("<PARA>")
	db $04, $d6, "SELECT", $09, $a3, $0f, $b1, $13, $81 ; 按SELECT会使用
	db CHARVAL("<LINE>")
	db $0f, $69, $06, $a4, $12, $85, $06, $f8, $07, $32, $08, $42, $01, $03 ; 上次选的钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $06, $a9, $05, $3b, $05, $26, $0b, $c3, $0f, $b1, $13, $81 ; 从背包里使用
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
	db CHARVAL("<PARA>")
	db $05, $b7, $0c, $f2, $11, $fc, $10, $08, $0c, $f2, $0f, $a9, $01, $e2 ; 不面向水面时，
	db CHARVAL("<LINE>")
	db $04, $d6, "SELECT", $0e, $f2, $0e, $d9 ; 按SELECT仍然
	db CHARVAL("<CONT>")
	db $0b, $29, $13, $1d, $0e, $3b, $19, $30, $12, $41, $06, $13, $01, $03 ; 可以骑自行车。
	done

FishingGuruGoodRodRepeatText::
	text_start
	db $12, $a1, $01, $0a, $01, $0a ; 呀——
	db CHARVAL("<LINE>")
	db CHARVAL("<PLAYER>"), $01, $d7 ; <PLAYER>！
	db CHARVAL("<PARA>")
	db $19, $60, $0a, $98 ; 最近
	db CHARVAL("<LINE>")
	db $07, $32, $06, $f7, $0f, $09, $09, $1b, $0d, $60, $01, $d7 ; 钓得如何呢！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $13, $f5, $0a, $68, $0d, $6b, $08, $80 ; 对了，再教你个
	db CHARVAL("<LINE>")
	db $07, $32, $13, $a1, $0a, $f1, $0e, $8f, $01, $d7 ; 钓鱼诀窍！
	db CHARVAL("<PARA>")
	db $11, $d2, $06, $a9, $05, $3b, $05, $26, $0b, $c3 ; 先从背包里
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $13, $01, $06, $a4, $07, $32, $08, $42, $01, $03 ; 使用一次钓竿。
	db CHARVAL("<PARA>")
	db $13, $1d, $09, $42, $18, $41, $13, $f6, $04, $d8, $05, $7d, $01, $e2 ; 以后站在岸边，
	db CHARVAL("<LINE>")
	db $0c, $f2, $07, $84, $10, $08, $0c, $f2, $04, $d6 ; 面对水面按
	db CHARVAL("<CONT>")
	db "SELECT", $01, $e2, $0a, $c7, $0d, $64, $18, $a7, $0a, $6f, $07, $32, $13, $a1, $01, $d7 ; SELECT，就能直接钓鱼！
	db CHARVAL("<PARA>")
	db $04, $d6, "SELECT", $09, $a3, $0f, $b1, $13, $81 ; 按SELECT会使用
	db CHARVAL("<LINE>")
	db $0f, $69, $06, $a4, $12, $85, $06, $f8, $07, $32, $08, $42, $01, $03 ; 上次选的钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $06, $a9, $05, $3b, $05, $26, $0b, $c3, $0f, $b1, $13, $81 ; 从背包里使用
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
	db CHARVAL("<PARA>")
	db $05, $b7, $0c, $f2, $11, $fc, $10, $08, $0c, $f2, $0f, $a9, $01, $e2 ; 不面向水面时，
	db CHARVAL("<LINE>")
	db $04, $d6, "SELECT", $0e, $f2, $0e, $d9 ; 按SELECT仍然
	db CHARVAL("<CONT>")
	db $0b, $29, $13, $1d, $0e, $3b, $19, $30, $12, $41, $06, $13, $01, $03 ; 可以骑自行车。
	done

FishingGuruSuperRodRepeatText::
	text_start
	db $12, $a1, $01, $0a, $01, $0a ; 呀——
	db CHARVAL("<LINE>")
	db CHARVAL("<PLAYER>"), $01, $d7 ; <PLAYER>！
	db CHARVAL("<PARA>")
	db $09, $9a, $06, $f1, $18, $a4, $0e, $70, $06, $f8, $07, $10, $07, $1e ; 回到之前的地点
	db CHARVAL("<LINE>")
	db $13, $81, $0b, $cb, $08, $ec, $07, $32, $08, $42, $01, $e2 ; 用厉害钓竿，
	db CHARVAL("<CONT>")
	db $09, $7b, $09, $a3, $07, $32, $0f, $69, $05, $b7, $10, $dc, $06, $f8, $05, $2e, $0b, $29, $0c, $da, $01, $d7 ; 还会钓上不同的宝可梦！
	db CHARVAL("<PARA>")
	db $13, $f6, $08, $81, $18, $cc, $07, $10, $07, $cb ; 在各种地方
	db CHARVAL("<LINE>")
	db $07, $6c, $07, $32, $07, $32, $0b, $10, $04, $eb, $01, $d7 ; 都钓钓看吧！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $13, $f5, $0a, $68, $0d, $6b, $08, $80 ; 对了，再教你个
	db CHARVAL("<LINE>")
	db $07, $32, $13, $a1, $0a, $f1, $0e, $8f, $01, $d7 ; 钓鱼诀窍！
	db CHARVAL("<PARA>")
	db $11, $d2, $06, $a9, $05, $3b, $05, $26, $0b, $c3 ; 先从背包里
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $13, $01, $06, $a4, $07, $32, $08, $42, $01, $03 ; 使用一次钓竿。
	db CHARVAL("<PARA>")
	db $13, $1d, $09, $42, $18, $41, $13, $f6, $04, $d8, $05, $7d, $01, $e2 ; 以后站在岸边，
	db CHARVAL("<LINE>")
	db $0c, $f2, $07, $84, $10, $08, $0c, $f2, $04, $d6 ; 面对水面按
	db CHARVAL("<CONT>")
	db "SELECT", $01, $e2, $0a, $c7, $0d, $64, $18, $a7, $0a, $6f, $07, $32, $13, $a1, $01, $d7 ; SELECT，就能直接钓鱼！
	db CHARVAL("<PARA>")
	db $04, $d6, "SELECT", $09, $a3, $0f, $b1, $13, $81 ; 按SELECT会使用
	db CHARVAL("<LINE>")
	db $0f, $69, $06, $a4, $12, $85, $06, $f8, $07, $32, $08, $42, $01, $03 ; 上次选的钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $06, $a9, $05, $3b, $05, $26, $0b, $c3, $0f, $b1, $13, $81 ; 从背包里使用
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
	db CHARVAL("<PARA>")
	db $05, $b7, $0c, $f2, $11, $fc, $10, $08, $0c, $f2, $0f, $a9, $01, $e2 ; 不面向水面时，
	db CHARVAL("<LINE>")
	db $04, $d6, "SELECT", $0e, $f2, $0e, $d9 ; 按SELECT仍然
	db CHARVAL("<CONT>")
	db $0b, $29, $13, $1d, $0e, $3b, $19, $30, $12, $41, $06, $13, $01, $03 ; 可以骑自行车。
	done

FishingGuruOldGoodRodRepeatTextNoBike::
	text_start
	db $12, $a1, $01, $0a, $01, $0a ; 呀——
	db CHARVAL("<LINE>")
	db CHARVAL("<PLAYER>"), $01, $d7 ; <PLAYER>！
	db CHARVAL("<PARA>")
	db $19, $60, $0a, $98 ; 最近
	db CHARVAL("<LINE>")
	db $07, $32, $06, $f7, $0f, $09, $09, $1b, $0d, $60, $01, $d7 ; 钓得如何呢！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $13, $f5, $0a, $68, $0d, $6b, $08, $80 ; 对了，再教你个
	db CHARVAL("<LINE>")
	db $07, $32, $13, $a1, $0a, $f1, $0e, $8f, $01, $d7 ; 钓鱼诀窍！
	db CHARVAL("<PARA>")
	db $11, $d2, $06, $a9, $05, $3b, $05, $26, $0b, $c3 ; 先从背包里
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $13, $01, $06, $a4, $07, $32, $08, $42, $01, $03 ; 使用一次钓竿。
	db CHARVAL("<PARA>")
	db $13, $1d, $09, $42, $18, $41, $13, $f6, $04, $d8, $05, $7d, $01, $e2 ; 以后站在岸边，
	db CHARVAL("<LINE>")
	db $0c, $f2, $07, $84, $10, $08, $0c, $f2, $04, $d6 ; 面对水面按
	db CHARVAL("<CONT>")
	db "SELECT", $01, $e2, $0a, $c7, $0d, $64, $18, $a7, $0a, $6f, $07, $32, $13, $a1, $01, $d7 ; SELECT，就能直接钓鱼！
	db CHARVAL("<PARA>")
	db $04, $d6, "SELECT", $09, $a3, $0f, $b1, $13, $81 ; 按SELECT会使用
	db CHARVAL("<LINE>")
	db $0f, $69, $06, $a4, $12, $85, $06, $f8, $07, $32, $08, $42, $01, $03 ; 上次选的钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $06, $a9, $05, $3b, $05, $26, $0b, $c3, $0f, $b1, $13, $81 ; 从背包里使用
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
done

FishingGuruSuperRodRepeatTextNoBike::
	text_start
	db $12, $a1, $01, $0a, $01, $0a ; 呀——
	db CHARVAL("<LINE>")
	db CHARVAL("<PLAYER>"), $01, $d7 ; <PLAYER>！
	db CHARVAL("<PARA>")
	db $09, $9a, $06, $f1, $18, $a4, $0e, $70, $06, $f8, $07, $10, $07, $1e ; 回到之前的地点
	db CHARVAL("<LINE>")
	db $13, $81, $0b, $cb, $08, $ec, $07, $32, $08, $42, $01, $e2 ; 用厉害钓竿，
	db CHARVAL("<CONT>")
	db $09, $7b, $09, $a3, $07, $32, $0f, $69, $05, $b7, $10, $dc, $06, $f8, $05, $2e, $0b, $29, $0c, $da, $01, $d7 ; 还会钓上不同的宝可梦！
	db CHARVAL("<PARA>")
	db $13, $f6, $08, $81, $18, $cc, $07, $10, $07, $cb ; 在各种地方
	db CHARVAL("<LINE>")
	db $07, $6c, $07, $32, $07, $32, $0b, $10, $04, $eb, $01, $d7 ; 都钓钓看吧！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $13, $f5, $0a, $68, $0d, $6b, $08, $80 ; 对了，再教你个
	db CHARVAL("<LINE>")
	db $07, $32, $13, $a1, $0a, $f1, $0e, $8f, $01, $d7 ; 钓鱼诀窍！
	db CHARVAL("<PARA>")
	db $11, $d2, $06, $a9, $05, $3b, $05, $26, $0b, $c3 ; 先从背包里
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $13, $01, $06, $a4, $07, $32, $08, $42, $01, $03 ; 使用一次钓竿。
	db CHARVAL("<PARA>")
	db $13, $1d, $09, $42, $18, $41, $13, $f6, $04, $d8, $05, $7d, $01, $e2 ; 以后站在岸边，
	db CHARVAL("<LINE>")
	db $0c, $f2, $07, $84, $10, $08, $0c, $f2, $04, $d6 ; 面对水面按
	db CHARVAL("<CONT>")
	db "SELECT", $01, $e2, $0a, $c7, $0d, $64, $18, $a7, $0a, $6f, $07, $32, $13, $a1, $01, $d7 ; SELECT，就能直接钓鱼！
	db CHARVAL("<PARA>")
	db $04, $d6, "SELECT", $09, $a3, $0f, $b1, $13, $81 ; 按SELECT会使用
	db CHARVAL("<LINE>")
	db $0f, $69, $06, $a4, $12, $85, $06, $f8, $07, $32, $08, $42, $01, $03 ; 上次选的钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $06, $a9, $05, $3b, $05, $26, $0b, $c3, $0f, $b1, $13, $81 ; 从背包里使用
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
done

SurfFishingRepeatText::
	text_start
	db $0c, $e4, $06, $81, $12, $8b, $11, $ba, $0e, $44, $01, $e6, $01, $e9 ; 秘传学习器０３
	db CHARVAL("<LINE>")
	db $0f, $bf, $01, $10, $06, $48, $0b, $9f, $01, $11, $01, $d7 ; 是“冲浪”！
	db CHARVAL("<PARA>")
	db $13, $8e, $0c, $01, $10, $70, $01, $e2, $0d, $6b, $05, $be, $18, $18, $0c, $c0, $19, $20, $01, $d7 ; 有了它，你猜怎么着！
	db CHARVAL("<LINE>")
	db $0a, $cd, $0e, $d9, $0b, $29, $13, $1d, $06, $2d, $19, $20, $05, $2e, $0b, $29, $0c, $da ; 居然可以乘着宝可梦
	db CHARVAL("<CONT>")
	db $13, $f6, $10, $08, $0f, $69, $0e, $70, $0a, $94, $01, $d7 ; 在水上前进！
	db CHARVAL("<PARA>")
	db $07, $a8, $0e, $92, $01, $e2, $18, $7a, $0b, $29, $0f, $bf, $0c, $e4, $06, $81, $12, $8b, $11, $ba, $0e, $44, $01, $e2 ; 而且，这可是秘传学习器，
	db CHARVAL("<LINE>")
	db $05, $b7, $08, $c4, $0f, $b1, $13, $81, $07, $90, $0f, $73, $06, $a4 ; 不管使用多少次
	db CHARVAL("<CONT>")
	db $10, $70, $07, $6c, $05, $b7, $09, $a3, $12, $09, $0f, $9f, $01, $d7 ; 它都不会消失！
	db CHARVAL("<PARA>")
	db $0d, $64, $09, $b3, $06, $f7, $18, $7a, $0c, $c0, $05, $1d, $06, $f8, $0a, $37, $0d, $fb, $01, $e2 ; 能获得这么棒的奖品，
	db CHARVAL("<LINE>")
	db $0d, $6b, $18, $7e, $0f, $bf, $10, $7d, $19, $3b, $13, $e7, $0c, $01, $01, $d7 ; 你真是太走运了！
	db CHARVAL("<PARA>")
	db $07, $84, $0c, $01, $01, $e2, $06, $48, $0b, $9f, $0f, $a9 ; 对了，冲浪时
	db CHARVAL("<LINE>")
	db $12, $f4, $0d, $64, $07, $32, $13, $a1, $0d, $9c, $01, $d7 ; 也能钓鱼哦！
	db CHARVAL("<PARA>")
	db $13, $f6, $10, $08, $0f, $69, $06, $c8, $0b, $06, $05, $3b, $05, $26, $01, $e2 ; 在水上打开背包，
	db CHARVAL("<LINE>")
	db $0f, $b1, $13, $81, $11, $f5, $12, $ec, $06, $f8, $07, $32, $08, $42, $01, $03 ; 使用想要的钓竿。
	db CHARVAL("<PARA>")
	db $18, $a4, $09, $42, $04, $d6, "SELECT", $01, $e2 ; 之后按SELECT，
	db CHARVAL("<LINE>")
	db $0a, $c7, $0d, $64, $13, $f5, $06, $a4, $0f, $b1, $13, $81 ; 就能再次使用
	db CHARVAL("<CONT>")
	db $18, $7a, $08, $83, $07, $32, $08, $42, $01, $03 ; 这根钓竿。
	db CHARVAL("<PARA>")
	db $11, $f5, $09, $7d, $07, $32, $08, $42, $06, $f8, $09, $72, $01, $e2 ; 想换钓竿的话，
	db CHARVAL("<LINE>")
	db $09, $9a, $06, $f1, $05, $3b, $05, $26, $0b, $c3, $12, $85, $18, $11 ; 回到背包里选择
	db CHARVAL("<CONT>")
	db $0c, $27, $13, $01, $08, $83, $0a, $c7, $09, $0d, $01, $03 ; 另一根就好。
	done
