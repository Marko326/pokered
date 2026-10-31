; ROM-1.21 正式版本标识；主菜单与设置界面共用。
; 放置在 ROM0，供 Bank 1 的主菜单直接读取。
SECTION "Game Version", ROM0

GameVersionText::
	db "ROM-1.21@"
