; FLY-1.34: RPP-style logical geography for Route 20 / Seafoam Islands.
; This is Town Map metadata only: it never changes physical map IDs, warps,
; collision, map connections, or the Fly landing records.
;
; ClassifyRoute20SeafoamTownMap:
;   in:  wCurMap, wXCoord, wYCoord, wWalkBikeSurfState
;   out: carry set and D=logical Town Map selector when handled.
;        carry clear and D=unchanged otherwise.
ClassifyRoute20SeafoamTownMap::
	ld a, [wCurMap]
	cp ROUTE_20
	jr z, .route20

	; Seafoam 1F is separate from the contiguous B1F-B4F map-ID range.
	cp SEAFOAM_ISLANDS_1F
	jr z, .seafoamInterior
	ld a, [wCurMap]
	cp SEAFOAM_ISLANDS_B1F
	jr c, .notHandled
	cp SEAFOAM_ISLANDS_B4F + 1
	jr c, .seafoamInterior

.notHandled
	and a ; clear carry for the generic map selector path
	ret

.seafoamInterior
	; The source is recorded only on an external Route 20 -> Seafoam 1F warp
	; and therefore survives all internal floor transitions.
	ld a, [wSeafoamEntranceSource]
	cp 1
	jr z, .seafoamWest
	ld d, SEAFOAM_ISLANDS_B1F ; east / unknown fallback
	scf
	ret
.seafoamWest
	ld d, UNUSED_MAP_F1
	scf
	ret

.route20
	ld a, [wWalkBikeSurfState]
	cp 2 ; Surf
	jr z, .water

	; Non-Surf standing positions: only the two actual Seafoam island bodies
	; get island selectors. Other land on Route 20 remains SeaRoute 20.
	; West island body: 44 <= x < 55 and y < 10.
	; East island body: 55 <= x < 68 and 6 <= y < 18.
	ld a, [wXCoord]
	cp 44
	jr c, .seaRoute20
	cp 55
	jr c, .checkWestIsland
	cp 68
	jr nc, .seaRoute20
	ld a, [wYCoord]
	cp 6
	jr c, .seaRoute20
	cp 18
	jr nc, .seaRoute20
	ld d, SEAFOAM_ISLANDS_B1F
	scf
	ret

.checkWestIsland
	ld a, [wYCoord]
	cp 10
	jr nc, .seaRoute20
	ld d, UNUSED_MAP_F1
	scf
	ret

.water
	; Follow the CHS Route 20 shoreline using the RPP coordinate bands.
	; Boundary X: 62 (Y<10), 64 (10-11), 65 (12-13),
	; 66 (14-15), then 64 (Y>=16).
	ld a, [wYCoord]
	cp 10
	jr c, .boundary62
	cp 12
	jr c, .boundary64
	cp 14
	jr c, .boundary65
	cp 16
	jr c, .boundary66
	ld b, 64
	jr .checkBoundary
.boundary62
	ld b, 62
	jr .checkBoundary
.boundary64
	ld b, 64
	jr .checkBoundary
.boundary65
	ld b, 65
	jr .checkBoundary
.boundary66
	ld b, 66
.checkBoundary
	ld a, [wXCoord]
	cp b
	jr nc, .seaRoute19
.seaRoute20
	ld d, UNUSED_MAP_F2
	scf
	ret
.seaRoute19
	ld d, UNUSED_MAP_F3
	scf
	ret

GetFlyTownMapPlayerMap::
; Return the logical Town Map area for the current player position.
; Route 20/Seafoam classification takes priority over individual landing
; overrides. D is preserved by farcall/callab callers.
	ld a, [wCurMap]
	ld d, a
	call ClassifyRoute20SeafoamTownMap
	ret c

	ld hl, FlyTownMapPlayerOverrides
.loop
	ld a, [hli]
	cp $ff
	ret z
	cp d
	jr nz, .skipEntry

	; The anchor tile and the immediately lower tile both belong to the
	; landmark. This covers the actual CHS Fly landing tile plus the approach.
	ld a, [wYCoord]
	ld b, a
	ld a, [hli] ; anchor Y
	cp b
	jr z, .checkX
	inc a
	cp b
	jr nz, .skipX
.checkX
	ld a, [hli] ; anchor X
	ld b, a
	ld a, [wXCoord]
	cp b
	jr nz, .skipSelector
	ld d, [hl]
	ret
.skipX
	inc hl ; skip anchor X
.skipSelector
	inc hl ; skip selector
	jr .loop
.skipEntry
	inc hl ; skip anchor Y
	inc hl ; skip anchor X
	inc hl ; skip selector
	jr .loop

FlyTownMapPlayerOverrides:
	; actual map, anchor Y, anchor X, Town Map selector
	db ROUTE_4,        5, 11, MT_MOON_1F
	db ROUTE_10,      19, 11, ROCK_TUNNEL_1F
	db ROUTE_10,      39,  6, POWER_PLANT
	db CERULEAN_CITY, 11,  4, CERULEAN_CAVE_1F
	db ROUTE_25,       3, 45, BILLS_HOUSE
	db FUCHSIA_CITY,   3, 18, SAFARI_ZONE_GATE
	db ROUTE_23,      31,  4, VICTORY_ROAD_1F
	db ROUTE_2,        9, 12, DIGLETTS_CAVE_ROUTE_2
	db ROUTE_11,       5,  4, DIGLETTS_CAVE_ROUTE_11
	; Real landmark entrances that are not Fly landing anchors.
	db ROUTE_4,        5, 18, MT_MOON_1F
	db ROUTE_4,        5, 24, MT_MOON_1F
	db ROUTE_10,      17,  8, ROCK_TUNNEL_1F
	db ROUTE_10,      53,  8, ROCK_TUNNEL_1F
	db $ff

UpdateSeafoamEntranceSource::
; Remember which Route 20 entrance was used to enter Seafoam Islands 1F.
; Route20 warp index 0 = west/red-side entrance; index 1 = east entrance.
	ld a, [wCurMap]
	cp SEAFOAM_ISLANDS_1F
	ret nz
	ld a, [wWarpedFromWhichMap]
	cp ROUTE_20
	ret nz
	ld a, [wWarpedFromWhichWarp]
	and a
	jr z, .west
	cp 1
	ret nz
	ld a, 2
	ld [wSeafoamEntranceSource], a
	ret
.west
	ld a, 1
	ld [wSeafoamEntranceSource], a
	ret

BuildPokedexTownMapLocations::
; Rewrite wild-location maps to the same logical Town Map selectors used by
; Town Map and Fly. Keep the final wBuffer byte for the $ff terminator.
	farcall FindWildLocationsOfMon
	ld hl, wBuffer
	ld b, 0 ; bit 0 = Route 20 seen, bit 1 = Seafoam interior seen
	ld c, 29 ; wBuffer has 30 bytes; reserve one for the final $ff
.scan
	ld a, [hl]
	cp $ff
	jr z, .appendLogicalLocations
	cp ROUTE_20
	jr z, .route20
	cp SEAFOAM_ISLANDS_1F
	jr z, .seafoam
	cp SEAFOAM_ISLANDS_B1F
	jr c, .next
	cp SEAFOAM_ISLANDS_B4F + 1
	jr c, .seafoam
.next
	inc hl
	dec c
	jr nz, .scan
	jr .terminate
.route20
	ld [hl], UNUSED_MAP_F2 ; Cinnabar-side SeaRoute 20
	set 0, b
	jr .next
.seafoam
	ld [hl], UNUSED_MAP_F1 ; west/upper Seafoam island
	set 1, b
	jr .next

.appendLogicalLocations
	; Each append is optional; never overwrite the reserved terminator byte.
	bit 0, b
	jr z, .noRoute20East
	ld a, c
	and a
	jr z, .terminate
	ld [hl], UNUSED_MAP_F3 ; Fuchsia-side SeaRoute 19
	inc hl
	dec c
.noRoute20East
	bit 1, b
	jr z, .terminate
	ld a, c
	and a
	jr z, .terminate
	ld [hl], SEAFOAM_ISLANDS_1F ; east/lower Seafoam island
	inc hl
	dec c
.terminate
	ld [hl], $ff

	; wOAMBaseTile is scratch during the Nest Map icon pass. Save the logical
	; player selector there for DisplayWildLocations' final player-marker draw.
	call GetFlyTownMapPlayerMap
	ld a, d
	ld [wOAMBaseTile], a
	ret
