SECTION "Game Version", ROM0

; One shared read-only build version for menu displays.
; ROM0 lets ROMX menu code read this text without bank switching.
GameVersionText::
	db "MUS-1.0.6@"
