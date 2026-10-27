; 主菜单版本号唯一来源；正式版不带测试字母后缀。
; 放置在 ROM0，供 Bank 1 的主菜单直接读取。
SECTION "Game Version", ROM0

GameVersionText::
	db "MOV-1.8@"
