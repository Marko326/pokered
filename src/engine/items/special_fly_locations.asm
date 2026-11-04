; FLY-1.33: special Fly selectors with two independent axes.
; Reference: RPP's geographic left/right special destination selection.
; No new map IDs, no ROM0 code, no new save bytes or shifted WRAM labels.
;
; The 13 entries are the reference's Kanto destinations that physically
; exist in this CHS ROM. Mt. Moon Square is absent from CHS and excluded.
DEF NUM_SPECIAL_FLY_LOCATIONS EQU 13
DEF SPECIAL_FLY_MAGIC_0 EQU $53
DEF SPECIAL_FLY_MAGIC_1 EQU $46

EnsureSpecialFlySaveState:
	ld a, [wSpecialFlyMagic]
	cp SPECIAL_FLY_MAGIC_0
	jp nz, .initialize
	ld a, [wSpecialFlyMagic + 1]
	cp SPECIAL_FLY_MAGIC_1
	ret z
.initialize
	ld a, SPECIAL_FLY_MAGIC_0
	ld [wSpecialFlyMagic], a
	ld a, SPECIAL_FLY_MAGIC_1
	ld [wSpecialFlyMagic + 1], a
	xor a
	ld [wSpecialFlyVisitedFlag], a
	ld [wSpecialFlyVisitedFlag + 1], a
	ret

MarkSpecialFlyLocationVisited::
	call EnsureSpecialFlySaveState
	; Seafoam unlocks separately for the two real Route 20 entrance warps.
	ld a, [wCurMap]
	cp SEAFOAM_ISLANDS_1F
	jp nz, .normalMap
	ld a, [wWarpedFromWhichMap]
	cp ROUTE_20
	ret nz
	ld a, [wWarpedFromWhichWarp]
	and a
	jp z, .seafoamWest
	cp 1
	ret nz
	ld c, 10 ; Route 20 east entrance (58,9)
	jp .setBit
.seafoamWest
	ld c, 9 ; Route 20 west entrance (48,5)
	jp .setBit
.normalMap
	ld d, a
	ld hl, SpecialFlyVisitedMaps
.findMap
	ld a, [hli]
	cp $ff
	ret z
	cp d
	jp z, .matchedMap
	inc hl
	jp .findMap
.matchedMap
	ld c, [hl]
.setBit
	ld hl, wSpecialFlyVisitedFlag
	ld a, c
	cp 8
	jp c, .gotByte
	sub 8
	inc hl
.gotByte
	ld b, a
	and a ; bit index zero must not run a 256-iteration shift loop
	ld a, 1
	jp z, .maskReady
.maskLoop
	add a, a
	dec b
	jp nz, .maskLoop
.maskReady
	or [hl]
	ld [hl], a
	ret

; All maps below are genuine, loaded maps, not arbitrary Town Map browsing.
SpecialFlyVisitedMaps:
	db VIRIDIAN_FOREST, 0
	db DIGLETTS_CAVE_ROUTE_2, 1
	db MT_MOON_1F, 2
	db CERULEAN_CAVE_1F, 3
	db BILLS_HOUSE, 4
	; Healing-house entry unlocks the existing Rock Tunnel/Route 10 special Fly.
	; One selector and one saved bit: no duplicate icon or overlapping destination.
	db ROCK_TUNNEL_POKECENTER, 5
	db ROCK_TUNNEL_1F, 5
	db CELADON_MART_ROOF, 6
	db DIGLETTS_CAVE_ROUTE_11, 7
	db SAFARI_ZONE_GATE, 8
	db VICTORY_ROAD_1F, 11
	db POWER_PLANT, 12
	db $ff

BuildSpecialFlyLocationsList::
	call EnsureSpecialFlySaveState
	ld hl, wSpecialFlyLocationsList
	ld [hl], $ff ; leading sentinel outside shared Town Map coordinate byte
	inc hl
	ld de, SpecialFlyEntries
.loop
	ld a, [de]
	cp $ff
	jp z, .done
	ld c, a ; selector
	inc de
	inc de ; skip geographic anchor index
	ld a, [de]
	inc de
	push hl
	ld hl, wSpecialFlyVisitedFlag
	and a
	jp z, .firstFlagByte
	inc hl
.firstFlagByte
	ld b, [hl]
	pop hl
	ld a, [de]
	inc de
	and b
	jp z, .locked
	ld a, c
	jp .store
.locked
	ld a, $fe
.store
	ld [hli], a
	jp .loop
.done
	ld [hl], $ff
	ret

; Input DE=current city/special list pointer, wFlyDirectionInput contains
; the latest repeated direction key. Output DE=selected special pointer or 0
; (no unlocked special).  The caller's existing list is never overwritten.
MoveSpecialFlyCursor::
	ld a, [wFlyLocationsAxis]
	and a
	jp nz, .fromSpecial
	ld a, [de]
	cp ROUTE_4
	jp z, .mtMoonHeal
	cp ROUTE_10
	jp z, .rockHeal
	cp NUM_CITY_MAPS
	jp nc, .unavailable
	ld e, a
	ld d, 0
	ld hl, FlyCityAnchorPositions
	add hl, de
	ld c, [hl]
	jp .fromCityAnchor
.mtMoonHeal
	ld c, 8
	jp .fromCityAnchor
.rockHeal
	ld c, 21
.fromCityAnchor
	; SpecialFlyEntries uses the preferred browsing order, not sorted
	; geographic anchors (Power Plant 23 precedes Route 11 Diglett Cave 19).
	; Examine every unlocked special to find the closest eligible anchor
	; in the requested direction, independent of its position in the list.
	; Keep the best list pointer on the stack; no extra WRAM is needed.
	ld de, 0
	push de ; best pointer = 0; balanced on all scan exits
	ld hl, SpecialFlyAnchorPositions
	ld de, wSpecialFlyLocationsList + 1
	ld b, $ff ; best distance (all actual distances are below $ff)
.scanCityCandidates
	ld a, [de]
	cp $ff
	jr z, .cityScanDone
	cp $fe
	jr z, .nextCityCandidate ; locked special
	ld a, [wFlyDirectionInput]
	bit BIT_D_RIGHT, a
	jr z, .cityLeftDistance
	ld a, [hl]
	sub c ; special anchor - current city anchor
	jr c, .nextCityCandidate
	jr .compareCityDistance
.cityLeftDistance
	ld a, c
	sub [hl] ; current city anchor - special anchor
	jr c, .nextCityCandidate
.compareCityDistance
	cp b
	jr nc, .nextCityCandidate ; on equal distance keep first table item
	ld b, a
	pop af ; discard old best pointer
	push de ; store this unlocked candidate list pointer
.nextCityCandidate
	inc hl
	inc de
	jr .scanCityCandidates
.cityScanDone
	pop de ; restore selected pointer, balancing the local stack
	ld a, d
	or e
	jp nz, .found
	; No candidate on this side: preserve existing first/last wrap rules.
	ld a, [wFlyDirectionInput]
	bit BIT_D_RIGHT, a
	jp nz, .firstUnlocked
	jp .lastUnlocked
.fromSpecial
	ld a, [wFlyDirectionInput]
	bit BIT_D_RIGHT, a
	jp nz, .nextSpecial
	ld b, NUM_SPECIAL_FLY_LOCATIONS
.prevSpecial
	dec de
	ld a, [de]
	cp $ff
	jp nz, .tryPrev
	ld de, wSpecialFlyLocationsList + NUM_SPECIAL_FLY_LOCATIONS
	ld a, [de]
.tryPrev
	cp $fe
	jp nz, .found
	dec b
	jp nz, .prevSpecial
	jp .unavailable
.nextSpecial
	ld b, NUM_SPECIAL_FLY_LOCATIONS
.nextLoop
	inc de
	ld a, [de]
	cp $ff
	jp nz, .tryNext
	ld de, wSpecialFlyLocationsList + 1
	ld a, [de]
.tryNext
	cp $fe
	jp nz, .found
	dec b
	jp nz, .nextLoop
	jp .unavailable
.firstUnlocked
	ld de, wSpecialFlyLocationsList + 1
	ld b, NUM_SPECIAL_FLY_LOCATIONS
.firstLoop
	ld a, [de]
	cp $fe
	jp nz, .found
	inc de
	dec b
	jp nz, .firstLoop
	jp .unavailable
.lastUnlocked
	ld de, wSpecialFlyLocationsList + NUM_SPECIAL_FLY_LOCATIONS
	ld b, NUM_SPECIAL_FLY_LOCATIONS
.lastLoop
	ld a, [de]
	cp $fe
	jp nz, .found
	dec de
	dec b
	jp nz, .lastLoop
.unavailable
	ld de, 0
	ret
.found
	ld a, 1
	ld [wFlyLocationsAxis], a
	ret

; Return to the nearest visited city in the corresponding Up/Down geographic
; direction from the selected special site; no changes to city visit flags.
FlySpecialToCityCursor::
	ld a, e
	sub LOW(wSpecialFlyLocationsList + 1)
	ld e, a
	ld d, 0
	ld hl, SpecialFlyAnchorPositions
	add hl, de
	ld c, [hl]
	ld a, [wFlyDirectionInput]
	bit BIT_D_UP, a
	jp nz, .up
	ld hl, FlySortedCityAnchors + (NUM_CITY_MAPS - 1) * 2
	ld b, NUM_CITY_MAPS
.downLoop
	ld a, [hl]
	cp c
	jp nc, .downSkip
	inc hl
	ld a, [hl]
	dec hl
	call .visitedCity
	jp c, .foundCity
.downSkip
	dec hl
	dec hl
	dec b
	jp nz, .downLoop
	ld hl, FlySortedCityAnchors + (NUM_CITY_MAPS - 1) * 2
	jp .lastCity
.up
	ld hl, FlySortedCityAnchors
	ld b, NUM_CITY_MAPS
.upLoop
	ld a, [hli]
	cp c
	ld a, [hli]
	jp c, .upSkip
	jp z, .upSkip
	call .visitedCity
	jp c, .foundCity
.upSkip
	dec b
	jp nz, .upLoop
	ld hl, FlySortedCityAnchors
	jp .firstCity
.firstCity
	ld b, NUM_CITY_MAPS
.firstLoop
	inc hl ; skip anchor index
	ld a, [hli]
	call .visitedCity
	jp c, .foundCity
	dec b
	jp nz, .firstLoop
	jp .fallbackCity
.lastCity
	ld b, NUM_CITY_MAPS
.lastLoop
	inc hl
	ld a, [hl]
	dec hl
	call .visitedCity
	jp c, .foundCity
	dec hl
	dec hl
	dec b
	jp nz, .lastLoop
.fallbackCity
	ld de, wFlyLocationsList
.foundCity
	xor a
	ld [wFlyLocationsAxis], a
	ret
.visitedCity
	; A=city ID, HL=anchor scan cursor. Preserve HL and B.
	push hl
	ld e, a
	ld d, 0
	ld hl, wFlyLocationsList
	add hl, de
	ld a, [hl]
	cp $fe
	jp z, .notVisited
	cp $ff
	jp z, .notVisited
	ld d, h
	ld e, l
	pop hl
	scf
	ret
.notVisited
	pop hl
	and a
	ret

; Geographic positions use the RPP TownMapOrder after adapting its map IDs
; to CHS and omitting Mt. Moon Square (which does not exist in this ROM).
FlyCityAnchorPositions:
	; PALLET, VIRIDIAN, PEWTER, CERULEAN, LAVENDER, VERMILION,
	; CELADON, FUCHSIA, CINNABAR, INDIGO, SAFFRON.
	db 0, 2, 6, 11, 24, 17, 28, 39, 46, 51, 30
FlyCityAnchorPositionsEnd:
ASSERT FlyCityAnchorPositionsEnd - FlyCityAnchorPositions == NUM_CITY_MAPS
FlySortedCityAnchors:
	db  0, PALLET_TOWN
	db  2, VIRIDIAN_CITY
	db  6, PEWTER_CITY
	db 11, CERULEAN_CITY
	db 17, VERMILION_CITY
	db 24, LAVENDER_TOWN
	db 28, CELADON_CITY
	db 30, SAFFRON_CITY
	db 39, FUCHSIA_CITY
	db 46, CINNABAR_ISLAND
	db 51, INDIGO_PLATEAU
FlySortedCityAnchorsEnd:
ASSERT FlySortedCityAnchorsEnd - FlySortedCityAnchors == NUM_CITY_MAPS * 2

SpecialFlyAnchorPositions:
	db 4, 5, 8, 10, 14, 21, 23, 19, 29, 40, 43, 44, 50
SpecialFlyAnchorPositionsEnd:
ASSERT SpecialFlyAnchorPositionsEnd - SpecialFlyAnchorPositions == NUM_SPECIAL_FLY_LOCATIONS

MACRO special_fly_entry
	db \1, \2, \3 / 8, 1 << (\3 % 8)
ENDM
SpecialFlyEntries:
	; selector, geographic TownMapOrder index, saved bit index.
	; Keep each saved bit attached to its destination. Special-axis browsing
	; follows the city-axis sweep, which differs from geographic TownMapOrder.
	special_fly_entry VIRIDIAN_FOREST,         4,  0
	special_fly_entry DIGLETTS_CAVE_ROUTE_2,   5,  1
	special_fly_entry MT_MOON_1F,             8,  2
	special_fly_entry CERULEAN_CAVE_1F,       10, 3
	special_fly_entry BILLS_HOUSE,            14, 4
	special_fly_entry ROCK_TUNNEL_1F,         21, 5
	special_fly_entry POWER_PLANT,            23, 12
	special_fly_entry DIGLETTS_CAVE_ROUTE_11, 19, 7
	special_fly_entry CELADON_MART_ROOF,      29, 6
	special_fly_entry SAFARI_ZONE_GATE,       40, 8
	special_fly_entry SEAFOAM_ISLANDS_1F,     43, 10 ; east Seafoam
	special_fly_entry SPECIAL_FLY_SEAFOAM_WEST_SELECTOR, 44, 9 ; west Seafoam
	special_fly_entry VICTORY_ROAD_1F,        50, 11
SpecialFlyEntriesEnd:
	db $ff
ASSERT (SpecialFlyEntriesEnd - SpecialFlyEntries) == NUM_SPECIAL_FLY_LOCATIONS * 4
; A dedicated UNION view keeps the list entirely out of wTownMapCoords,
; without allocating WRAM or touching saved state.
ASSERT NUM_SPECIAL_FLY_LOCATIONS + 2 == 15
ASSERT wSpecialFlyLocationsList == wBuffer + 1
ASSERT wSpecialFlyLocationsList + NUM_SPECIAL_FLY_LOCATIONS + 1 <= wBuffer + 27

TryLoadSpecialFlyWarpData::
; Input D = selector; copy actual map/warp and set carry on match.
	ld hl, SpecialFlyWarpData
.loop
	ld a, [hli]
	cp $ff
	ret z ; carry clear
	cp d
	jp z, .found
	ld bc, 7 ; actual map ID plus 6 warp bytes
	add hl, bc
	jp .loop
.found
	ld a, [hli]
	ld [wDestinationMap], a
	ld [wCurMap], a
	ld de, wCurrentTileBlockMapViewPointer
	ld c, 6
.copy
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jp nz, .copy
	scf
	ret

; Use the exact RPP landing positions adapted to CHS's matching real map
; widths and actual map IDs.  These are 6-byte fly_warp records.
SpecialFlyWarpData:
	db VIRIDIAN_FOREST, VIRIDIAN_FOREST
	fly_warp VIRIDIAN_FOREST, 16, 46
	db DIGLETTS_CAVE_ROUTE_2, ROUTE_2
	fly_warp ROUTE_2, 12, 10
	db MT_MOON_1F, ROUTE_4
	fly_warp ROUTE_4, 11, 6
	db CERULEAN_CAVE_1F, CERULEAN_CITY
	fly_warp CERULEAN_CITY, 4, 12
	db BILLS_HOUSE, ROUTE_25
	fly_warp ROUTE_25, 45, 4
	db ROCK_TUNNEL_1F, ROUTE_10
	fly_warp ROUTE_10, 11, 20
	db CELADON_MART_ROOF, CELADON_MART_ROOF
	fly_warp CELADON_MART_ROOF, 12, 4
	db DIGLETTS_CAVE_ROUTE_11, ROUTE_11
	fly_warp ROUTE_11, 4, 6
	db SAFARI_ZONE_GATE, FUCHSIA_CITY
	fly_warp FUCHSIA_CITY, 18, 4
	db SPECIAL_FLY_SEAFOAM_WEST_SELECTOR, ROUTE_20
	fly_warp ROUTE_20, 48, 6
	db SEAFOAM_ISLANDS_1F, ROUTE_20
	fly_warp ROUTE_20, 58, 10
	db VICTORY_ROAD_1F, ROUTE_23
	fly_warp ROUTE_23, 4, 32
	db POWER_PLANT, ROUTE_10
	fly_warp ROUTE_10, 6, 40
SpecialFlyWarpDataEnd:
	db $ff
ASSERT (SpecialFlyWarpDataEnd - SpecialFlyWarpData) == NUM_SPECIAL_FLY_LOCATIONS * 8
