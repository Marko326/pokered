; START 菜单加速与输入响应优化正式版标识；主菜单与设置菜单共用。
; 放置在 ROM0，供 Bank 1 的主菜单直接读取。
SECTION "Game Version", ROM0

GameVersionText::
	db "QOL-1.15@"
