DEF NOT_VISITED EQU $fe

DisplayTownMap:
	call LoadTownMap
	ld hl, wUpdateSpritesEnabled
	ld a, [hl]
	push af
	ld [hl], $ff
	push hl
	ld a, JOY_REPEAT_MODE_LONG_LIST
	ldh [hJoy7], a
	ld a, [wCurMap]
	push af
	ld b, $0
	call DrawPlayerOrBirdSprite ; player sprite
	hlcoord 1, 1 ;hlcoord 1, 0
	ld de, wcd6d
	call PlaceString
	ld hl, wShadowOAM
	ld de, wTileMapBackup
	ld bc, $10
	call CopyData
	ld hl, vSprites tile $04
	ld de, TownMapCursor
	lb bc, BANK(TownMapCursor), (TownMapCursorEnd - TownMapCursor) / $8
	call CopyVideoDataDouble
	; The cursor index shares scratch WRAM; initialize it after OAM setup.
	; Reuse the map selector saved above for .enterLoop.
	pop af
	push af
	call InitTownMapLocationFromPlayerMap
	pop af
	jr .enterLoop

.townMapLoop
	hlcoord 0, 0
	lb bc, 2, 11 ;lb bc, 1, 20
	call ClearScreenArea
	ld hl, TownMapOrder
	ld a, [wWhichTownMapLocation]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
.enterLoop
	ld de, wTownMapCoords
	call LoadTownMapEntry
	ld a, [de]
	push hl
	call TownMapCoordsToOAMCoords
	ld a, $4
	ld [wOAMBaseTile], a
	ld hl, wShadowOAMSprite04
	call WriteTownMapSpriteOAM ; town map cursor sprite
	pop hl
	ld de, wcd6d
.copyMapName
	ld a, [hli]
	ld [de], a
	inc de
	cp $50
	jr nz, .copyMapName
	hlcoord 1, 1 ;hlcoord 1, 0
	ld de, wcd6d
	call PlaceString
	ld hl, wShadowOAMSprite04
	ld de, wTileMapBackup + 16
	ld bc, $10
	call CopyData
.inputLoop
	call TownMapSpriteBlinkingAnimation
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and A_BUTTON | B_BUTTON | D_UP | D_DOWN
	jr nz, .normalInput
	; START/SELECT use physical edges, never the held-key repeat stream.
	ldh a, [hJoyPressed]
	and START | SELECT
	jr z, .inputLoop
	ld b, a
	ld a, SFX_TINK
	call PlaySound
	bit BIT_START, b
	jp nz, .pressedStart
	; SELECT: Pallet Town is entry 0 in the ordinary TownMapOrder.
	xor a
	ld [wWhichTownMapLocation], a
	jp .townMapLoop
.normalInput
	ld a, SFX_TINK
	call PlaySound
	bit 6, b
	jr nz, .pressedUp
	bit 7, b
	jr nz, .pressedDown
	xor a
	ld [wTownMapSpriteBlinkingEnabled], a
	ldh [hJoy7], a
	ld [wAnimCounter], a
	call ExitTownMap
	pop hl
	pop af
	ld [hl], a
	ret
.pressedUp
	ld a, [wWhichTownMapLocation]
	inc a
	cp TownMapOrderEnd - TownMapOrder ; number of list items + 1
	jr nz, .noOverflow
	xor a
.noOverflow
	ld [wWhichTownMapLocation], a
	jp .townMapLoop
.pressedDown
	ld a, [wWhichTownMapLocation]
	dec a
	cp -1
	jr nz, .noUnderflow
	ld a, TownMapOrderEnd - TownMapOrder - 1 ; number of list items
.noUnderflow
	ld [wWhichTownMapLocation], a
	jp .townMapLoop

.pressedStart
	; Teleport/blackout location, not the last town walked through.
	ld a, [wLastBlackoutMap]
	cp ROUTE_4
	jr z, .mtMoonCenter
	cp ROUTE_10
	jr z, .rockTunnelCenter
	cp NUM_CITY_MAPS
	jp nc, .inputLoop ; unknown/invalid recovery map: do nothing
	jr .findTownMapEntry
.mtMoonCenter
	ld a, MT_MOON_1F ; the Mt. Moon entry in TownMapOrder
	jr .findTownMapEntry
.rockTunnelCenter
	ld a, ROCK_TUNNEL_POKECENTER
.findTownMapEntry
	ld b, a ; desired map ID
	ld hl, TownMapOrder
	ld c, 0 ; list index
.scanTownMapOrder
	ld a, [hli]
	cp b
	jr z, .foundTownMapEntry
	inc c
	ld a, c
	cp TownMapOrderEnd - TownMapOrder
	jr c, .scanTownMapOrder
	jp .inputLoop ; no matching entry: keep the old cursor
.foundTownMapEntry
	ld a, c
	ld [wWhichTownMapLocation], a
	jp .townMapLoop

INCLUDE "data/maps/town_map_order.asm"

InitTownMapLocationFromPlayerMap:
; In: A = current player map selector. Out: wWhichTownMapLocation.
; Prefer the same selector in TownMapOrder (routes, towns, landmarks).
; For indoor maps not listed there, use the closest displayed map coordinate.
; This must run after Town Map graphics/OAM initialization because the cursor
; index shares scratch WRAM that drawing may overwrite.
	ld d, a
	ld hl, TownMapOrder
	ld b, 0
.exactLoop
	ld a, [hli]
	cp d
	jr nz, .nextExact
	ld a, b
	ld [wWhichTownMapLocation], a
	ret
.nextExact
	inc b
	ld a, b
	cp TownMapOrderEnd - TownMapOrder
	jr c, .exactLoop

	; Indoor/dungeon fallback: compare coordinates, not map IDs.
	ld a, d
	ld de, wTownMapCoords
	call LoadTownMapEntry
	ld a, [de]
	ld [wBuffer + 2], a ; player y/x, packed high/low nybbles
	ld a, $ff
	ld [wBuffer], a ; minimum Manhattan distance
	xor a
	ld [wBuffer + 1], a ; selected list index, default = Pallet
	ld [wBuffer + 3], a ; scanning list index
	ld hl, TownMapOrder
.coordLoop
	ld a, [hli]
	push hl
	ld de, wTownMapCoords
	call LoadTownMapEntry
	ld a, [de]
	ld b, a ; candidate packed y/x
	ld a, [wBuffer + 2]
	and $0f
	ld c, a
	ld a, b
	and $0f
	sub c
	jr nc, .xPositive
	cpl
	inc a
.xPositive
	ld c, a ; absolute x difference
	ld a, [wBuffer + 2]
	and $f0
	swap a
	ld b, a
	ld a, [de]
	and $f0
	swap a
	sub b
	jr nc, .yPositive
	cpl
	inc a
.yPositive
	add c ; Manhattan distance, at most 30
	ld b, a
	ld a, [wBuffer]
	cp b
	jr c, .nextCoord
	jr z, .nextCoord ; ties keep the first geographic entry
	ld a, b
	ld [wBuffer], a
	ld a, [wBuffer + 3]
	ld [wBuffer + 1], a
.nextCoord
	pop hl
	ld a, [wBuffer + 3]
	inc a
	ld [wBuffer + 3], a
	cp TownMapOrderEnd - TownMapOrder
	jp c, .coordLoop
	ld a, [wBuffer + 1]
	ld [wWhichTownMapLocation], a
	ret

TownMapCursor:
	INCBIN "gfx/town_map/town_map_cursor.1bpp"
TownMapCursorEnd:

LoadTownMap_Nest:
	call LoadTownMap
	ld hl, wUpdateSpritesEnabled
	ld a, [hl]
	push af
	ld [hl], $ff
	push hl
	call DisplayWildLocations
	call GetMonName
	call IncreaseDFSStack
	hlcoord 0, 1
	call PlaceString
	ld h, b
	ld l, c
	ld de, MonsNestText2
	ld a, [wd11e]
	cp OMASTAR ; 多刺菊石兽
	jr z, .shortnest
	cp MAGNETON ; 三合一磁怪
	jr z, .shortnest
	ld de, MonsNestText
.shortnest
	ld a, [wENGNameMark]
	cp 1
	jr z, .skipAdding
	call PlaceString
.skipAdding
	call DecreaseDFSStack
	call WaitForTextScrollButtonPress
	call ExitTownMap
	pop hl
	pop af
	ld [hl], a
	ret

MonsNestText:
	db "'s"
	; FALL THROUGH
MonsNestText2:
	db " nest@"

LoadTownMap_Fly::
	call ClearSprites
	call LoadTownMap
	call LoadPlayerSpriteGraphics
	call LoadFontTilePatterns
	ld de, BirdSprite
	ld hl, vSprites tile $04
	lb bc, BANK(BirdSprite), 12
	call CopyVideoData
	ld de, TownMapUpArrow
	ld hl, vChars1 tile $6d
	lb bc, BANK(TownMapUpArrow), (TownMapUpArrowEnd - TownMapUpArrow) / $8
	call CopyVideoDataDouble
	call BuildFlyLocationsList
	ld hl, wUpdateSpritesEnabled
	ld a, [hl]
	push af
	ld [hl], $ff
	push hl
	hlcoord 0, 1 ;hlcoord 0, 0
	ld de, ToText
	call PlaceString
	ld a, [wCurMap]
	ld b, $0
	call DrawPlayerOrBirdSprite
	ld hl, wFlyLocationsList
	decoord 10, 0 ;decoord 18, 0
.townMapFlyLoop
	ld a, CHARVAL(" ")
	ld [de], a
	push hl
	push hl
	hlcoord 4, 0 ;hlcoord 3, 0
	lb bc, 2, 6 ;lb bc, 1, 15
	call ClearScreenArea
	pop hl
	ld a, [hl]
	ld b, $4
	call DrawPlayerOrBirdSprite ; draw bird sprite
	hlcoord 4, 1 ;hlcoord 3, 0
	ld de, wcd6d
	call PlaceString
	ld c, 15
	call DelayFrames
	hlcoord 10, 0 ;hlcoord 18, 0
	ld [hl], CHARVAL("▲")
	hlcoord 10, 1 ;hlcoord 19, 0
	ld [hl], CHARVAL("▼")
	pop hl
.inputLoop
	push hl
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	pop hl
	and A_BUTTON | B_BUTTON | D_UP | D_DOWN
	jr nz, .normalFlyInput
	ldh a, [hJoyPressed]
	and START | SELECT
	jp nz, .shortcutPressed
	jr .inputLoop
.normalFlyInput
	bit 0, b
	jr nz, .pressedA
	ld a, SFX_TINK
	call PlaySound
	bit 6, b
	jr nz, .pressedUp
	bit 7, b
	jr nz, .pressedDown
	jr .pressedB
.pressedA
	ld a, SFX_HEAL_AILMENT
	call PlaySound
	ld a, [hl]
	ld [wDestinationMap], a
	ld hl, wd732
	set 3, [hl]
	inc hl
	set 7, [hl]
.pressedB
	xor a
	ld [wTownMapSpriteBlinkingEnabled], a
	call GBPalWhiteOutWithDelay3
	pop hl
	pop af
	ld [hl], a
	ret
.pressedUp
	decoord 10, 0 ;decoord 18, 0
	inc hl
	ld a, [hl]
	cp $ff
	jr z, .wrapToStartOfList
	cp NOT_VISITED
	jr z, .pressedUp ; skip past unvisited towns
	jp .townMapFlyLoop
.wrapToStartOfList
	ld hl, wFlyLocationsList
	jp .townMapFlyLoop
.pressedDown
	decoord 10, 1 ;decoord 19, 0
	dec hl
	ld a, [hl]
	cp $ff
	jr z, .wrapToEndOfList
	cp NOT_VISITED
	jr z, .pressedDown ; skip past unvisited towns
	jp .townMapFlyLoop
.wrapToEndOfList
	; One extra optional recovery-point entry, then the end sentinel.
	ld hl, wFlyLocationsList + NUM_CITY_MAPS + 1
	jr .pressedDown

.shortcutPressed
	ld b, a ; newly pressed START/SELECT bits
	ld a, SFX_TINK
	call PlaySound
	bit BIT_START, b
	jr nz, .shortcutLastHeal
	; SELECT selects Pallet only if that Fly destination is unlocked.
	ld a, [wFlyLocationsList]
	cp PALLET_TOWN
	jp nz, .inputLoop
	ld hl, wFlyLocationsList
	jr .shortcutFound
.shortcutLastHeal
	ld a, [wLastBlackoutMap]
	cp NUM_CITY_MAPS
	jr nc, .checkSpecialHeal
	; City slot is indexed by its map ID. Never jump to NOT_VISITED.
	ld e, a
	ld d, 0
	ld hl, wFlyLocationsList
	add hl, de
	ld a, [hl]
	cp e
	jp nz, .inputLoop
	jr .shortcutFound
.checkSpecialHeal
	cp ROUTE_4
	jr z, .checkSpecialEntry
	cp ROUTE_10
	jp nz, .inputLoop
.checkSpecialEntry
	ld b, a
	ld a, [wFlyLocationsList + NUM_CITY_MAPS]
	cp b
	jp nz, .inputLoop
	ld hl, wFlyLocationsList + NUM_CITY_MAPS
.shortcutFound
	decoord 10, 0
	jp .townMapFlyLoop ; update cursor only; A still confirms Fly

ToText:
	db "To@"

BuildFlyLocationsList:
	ld hl, wFlyAnimUsingCoordList
	ld [hl], $ff
	inc hl
	ld a, [wTownVisitedFlag]
	ld e, a
	ld a, [wTownVisitedFlag + 1]
	ld d, a
	lb bc, 0, NUM_CITY_MAPS
.loop
	srl d
	rr e
	ld a, NOT_VISITED
	jr nc, .notVisited
	ld a, b ; store the map number of the town if it has been visited
.notVisited
	ld [hl], a
	inc hl
	inc b
	dec c
	jr nz, .loop
	; No new visit/SRAM flag: expose a special Fly landing only after
	; healing at its Route 4 / Route 10 Pokémon Center.
	ld a, [wLastBlackoutMap]
	cp ROUTE_4
	jr z, .writeSpecialLocation
	cp ROUTE_10
	jr z, .writeSpecialLocation
	ld a, NOT_VISITED
.writeSpecialLocation
	ld [hli], a
	ld [hl], $ff
	ret

TownMapUpArrow:
	INCBIN "gfx/town_map/up_arrow.1bpp"
TownMapUpArrowEnd:

LoadTownMap:
	call GBPalWhiteOutWithDelay3
	call ClearScreen
	call UpdateSprites
	hlcoord 0, 0
	ld b, $12
	ld c, $12
	call TextBoxBorder
	call DisableLCD
	ld hl, WorldMapTileGraphics
	ld de, vChars2 tile $60
	ld bc, WorldMapTileGraphicsEnd - WorldMapTileGraphics
	ld a, BANK(WorldMapTileGraphics)
	call FarCopyData2
	ld hl, MonNestIcon
	ld de, vSprites tile $04
	ld bc, MonNestIconEnd - MonNestIcon
	ld a, BANK(MonNestIcon)
	call FarCopyDataDouble
	hlcoord 0, 0
	ld de, CompressedMap
.nextTile
	ld a, [de]
	and a
	jr z, .done
	ld b, a
	and $f
	ld c, a
	ld a, b
	swap a
	and $f
	add $60
.writeRunLoop
	ld [hli], a
	dec c
	jr nz, .writeRunLoop
	inc de
	jr .nextTile
.done
	call EnableLCD
	ld b, SET_PAL_TOWN_MAP
	call RunPaletteCommand
	call Delay3
	call GBPalNormal
	xor a
	ld [wAnimCounter], a
	inc a
	ld [wTownMapSpriteBlinkingEnabled], a
	ret

CompressedMap:
	INCBIN "gfx/town_map/town_map.rle"

ExitTownMap:
; clear town map graphics data and load usual graphics data
	xor a
	ld [wTownMapSpriteBlinkingEnabled], a
	call GBPalWhiteOut
	call ClearScreen
	call ClearSprites
	call LoadPlayerSpriteGraphics
	call LoadFontTilePatterns
	call UpdateSprites
	jp RunDefaultPaletteCommand

DrawPlayerOrBirdSprite:
; a = map number
; b = OAM base tile
	push af
	ld a, b
	ld [wOAMBaseTile], a
	pop af
	ld de, wTownMapCoords
	call LoadTownMapEntry
	ld a, [de]
	push hl
	call TownMapCoordsToOAMCoords
	call WritePlayerOrBirdSpriteOAM
	pop hl
	ld de, wcd6d
.loop
	ld a, [hli]
	ld [de], a
	inc de
	cp CHARVAL("@")
	jr nz, .loop
	ld hl, wShadowOAM
	ld de, wTileMapBackup
	ld bc, $a0
	jp CopyData

DisplayWildLocations:
	farcall FindWildLocationsOfMon
	call ZeroOutDuplicatesInList
	ld hl, wShadowOAM
	ld de, wTownMapCoords
.loop
	ld a, [de]
	cp $ff
	jr z, .exitLoop
	and a
	jr z, .nextEntry
	push hl
	call LoadTownMapEntry
	pop hl
	ld a, [de]
	cp $19 ; Cerulean Cave's coordinates
	jr z, .nextEntry ; skip Cerulean Cave
	call TownMapCoordsToOAMCoords
	ld a, $4 ; nest icon tile no.
	ld [hli], a
	xor a
	ld [hli], a
.nextEntry
	inc de
	jr .loop
.exitLoop
	ld a, l
	and a ; were any OAM entries written?
	jr nz, .drawPlayerSprite
; if no OAM entries were written, print area unknown text
	hlcoord 1, 7
	ld b, 2
	ld c, 15
	call TextBoxBorder
	hlcoord 2, 9
	ld de, AreaUnknownText
	call PlaceString
	jr .done
.drawPlayerSprite
	ld a, [wCurMap]
	ld b, $0
	call DrawPlayerOrBirdSprite
.done
	ld hl, wShadowOAM
	ld de, wTileMapBackup
	ld bc, $a0
	jp CopyData

AreaUnknownText:
	db " AREA UNKNOWN@"

TownMapCoordsToOAMCoords:
; in: lower nybble of a = x, upper nybble of a = y
; out: b and [hl] = (y * 8) + 24, c and [hl+1] = (x * 8) + 24
	push af
	and $f0
	srl a
	add 24
	ld b, a
	ld [hli], a
	pop af
	and $f
	swap a
	srl a
	add 24
	ld c, a
	ld [hli], a
	ret

WritePlayerOrBirdSpriteOAM:
	ld a, [wOAMBaseTile]
	and a
	ld hl, wShadowOAMSprite36 ; for player sprite
	jr z, WriteTownMapSpriteOAM
	ld hl, wShadowOAMSprite32 ; for bird sprite

WriteTownMapSpriteOAM:
	push hl

; Subtract 4 from c (X coord) and 4 from b (Y coord). However, the carry from c
; is added to b, so the net result is that only 3 is subtracted from b.
	lb hl, -4, -4
	add hl, bc

	ld b, h
	ld c, l
	pop hl

WriteAsymmetricMonPartySpriteOAM:
; Writes 4 OAM blocks for a helix mon party sprite, since it does not have
; a vertical line of symmetry.
	lb de, 2, 2
.loop
	push de
	push bc
.innerLoop
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a
	ld a, [wOAMBaseTile]
	ld [hli], a
	inc a
	ld [wOAMBaseTile], a
	xor a
	ld [hli], a
	inc d
	ld a, 8
	add c
	ld c, a
	dec e
	jr nz, .innerLoop
	pop bc
	pop de
	ld a, 8
	add b
	ld b, a
	dec d
	jr nz, .loop
	ret

WriteSymmetricMonPartySpriteOAM:
; Writes 4 OAM blocks for a mon party sprite other than a helix. All the
; sprites other than the helix one have a vertical line of symmetry which allows
; the X-flip OAM bit to be used so that only 2 rather than 4 tile patterns are
; needed.
	xor a
	ld [wSymmetricSpriteOAMAttributes], a
	lb de, 2, 2
.loop
	push de
	push bc
.innerLoop
	ld a, b
	ld [hli], a ; Y
	ld a, c
	ld [hli], a ; X
	ld a, [wOAMBaseTile]
	ld [hli], a ; tile
	ld a, [wSymmetricSpriteOAMAttributes]
	ld [hli], a ; attributes
	xor (1 << OAM_X_FLIP)
	ld [wSymmetricSpriteOAMAttributes], a
	inc d
	ld a, 8
	add c
	ld c, a
	dec e
	jr nz, .innerLoop
	pop bc
	pop de
	push hl
	ld hl, wOAMBaseTile
	inc [hl]
	inc [hl]
	pop hl
	ld a, 8
	add b
	ld b, a
	dec d
	jr nz, .loop
	ret

ZeroOutDuplicatesInList:
; replace duplicate bytes in the list of wild pokemon locations with 0
	ld de, wBuffer
.loop
	ld a, [de]
	inc de
	cp $ff
	ret z
	ld c, a
	ld l, e
	ld h, d
.zeroDuplicatesLoop
	ld a, [hl]
	cp $ff
	jr z, .loop
	cp c
	jr nz, .skipZeroing
	xor a
	ld [hl], a
.skipZeroing
	inc hl
	jr .zeroDuplicatesLoop

LoadTownMapEntry:
; in: a = map number
; out: lower nybble of [de] = x, upper nybble of [de] = y, hl = address of name
	cp FIRST_INDOOR_MAP
	jr c, .external
	ld bc, 4
	ld hl, InternalMapEntries
.loop
	cp [hl]
	jr c, .foundEntry
	add hl, bc
	jr .loop
.foundEntry
	inc hl
	jr .readEntry
.external
	ld hl, ExternalMapEntries
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
.readEntry
	ld a, [hli]
	ld [de], a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

; SAVE / Continue: show only the map name, no "current location" label.
; In: DE = first interior tile of the existing 13-column information box.
; Keep the previous conservative six-tile name limit to reduce live DFS
; glyph pressure while START and the Yes/No prompt share the text cache.
; Truncate at complete double-byte CHS characters (no split Hanzi).
; Do not DFSStaticize this line into vChars2 $40-$5f: those tile IDs are
; also live outdoor scenery on both DMG and CGB.
PrintCurrentMapOnSaveScreen::
	push de
	ld a, [wCurMap]
	ld de, wTownMapCoords
	call LoadTownMapEntry
	ld de, wBuffer
	ld c, 0 ; measured width in half-tile units, maximum six tiles
.copyName
	ld a, [hli]
	cp "@"
	jr z, .nameReady
	ld b, a
	; Match GetStrLength_Gen1's single- / double-code decision.
	and a
	jr z, .singleCode
	cp $14
	jr c, .doubleCode
	cp $2f
	jr nc, .singleCode
	bit 3, a
	jr nz, .doubleCode
.singleCode
	ld a, c
	add 2 ; one narrow character = 2 half tiles
	cp 13
	jr nc, .nameReady
	ld c, a
	ld a, b
	cp "_" ; Town Map line-break marker becomes space here
	jr nz, .checkShortcut
	ld a, " "
	jr .storeSingle
.checkShortcut
	; These tokens expand in PlaceString; use a stable one-tile label.
	cp "#"
	jr z, .shorten
	cp "<PKMN>"
	jr nz, .storeSingle
.shorten
	ld a, "P"
.storeSingle
	ld [de], a
	inc de
	jr .copyName
.doubleCode
	ld a, c
	add 3 ; one complete Hanzi = 3 half tiles
	cp 13
	jr nc, .nameReady
	ld c, a
	ld a, b
	ld [de], a
	inc de
	ld a, [hli] ; keep the second DFS byte together
	ld [de], a
	inc de
	jr .copyName
.nameReady
	ld a, "@"
	ld [de], a
	pop hl ; draw at the left edge; do not allocate fixed VRAM tiles
	ld de, wBuffer
	jp PlaceString

INCLUDE "data/maps/town_map_entries.asm"

INCLUDE "data/maps/names.asm"

MonNestIcon:
	INCBIN "gfx/town_map/mon_nest_icon.1bpp"
MonNestIconEnd:

TownMapSpriteBlinkingAnimation::
	ld a, [wAnimCounter]
	inc a
	cp 25
	jr z, .hideSprites
	cp 50
	jr nz, .done
; show sprites when the counter reaches 50
	ld hl, wTileMapBackup
	ld de, wShadowOAM
	ld bc, $90
	call CopyData
	xor a
	jr .done
.hideSprites
	ld hl, wShadowOAM
	ld b, $24
	ld de, $4
.hideSpritesLoop
	ld [hl], $a0
	add hl, de
	dec b
	jr nz, .hideSpritesLoop
	ld a, 25
.done
	ld [wAnimCounter], a
	jp DelayFrame
