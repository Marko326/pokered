; ROM-1.30 CGB-only location sign (native CHS font, map-entry-only trigger).
; The DMG frame loop never calls this module. The CGB Window uses its own
; tile data in VRAM bank 1, instead of CHS DFS / NPC sprite tiles in bank 0.
; No new saved variables, no edits to the existing Town Map/Fly names.
; ROM-1.31 formal scope: 11 cities, Routes 1-25, five basic landmarks
; and #217/#218/#220/#222/#225 physical floor/area identities.
; New Game / Continue entry is silent; transitions preserve neutral maps.

DEF MAP_NAME_SIGN_SPECIAL_BASE EQU $80
DEF MAP_NAME_SIGN_VIRIDIAN_FOREST EQU MAP_NAME_SIGN_SPECIAL_BASE + 0
DEF MAP_NAME_SIGN_MT_MOON         EQU MAP_NAME_SIGN_SPECIAL_BASE + 1
DEF MAP_NAME_SIGN_ROCK_TUNNEL     EQU MAP_NAME_SIGN_SPECIAL_BASE + 2
DEF MAP_NAME_SIGN_DIGLETTS_CAVE   EQU MAP_NAME_SIGN_SPECIAL_BASE + 3
DEF MAP_NAME_SIGN_POWER_PLANT     EQU MAP_NAME_SIGN_SPECIAL_BASE + 4
DEF MAP_NAME_SIGN_SILPH_CO_1F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 5
DEF MAP_NAME_SIGN_SILPH_CO_2F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 6
DEF MAP_NAME_SIGN_SILPH_CO_3F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 7
DEF MAP_NAME_SIGN_SILPH_CO_4F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 8
DEF MAP_NAME_SIGN_SILPH_CO_5F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 9
DEF MAP_NAME_SIGN_SILPH_CO_6F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 10
DEF MAP_NAME_SIGN_SILPH_CO_7F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 11
DEF MAP_NAME_SIGN_SILPH_CO_8F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 12
DEF MAP_NAME_SIGN_SILPH_CO_9F     EQU MAP_NAME_SIGN_SPECIAL_BASE + 13
DEF MAP_NAME_SIGN_SILPH_CO_10F    EQU MAP_NAME_SIGN_SPECIAL_BASE + 14
DEF MAP_NAME_SIGN_SILPH_CO_11F    EQU MAP_NAME_SIGN_SPECIAL_BASE + 15
DEF MAP_NAME_SIGN_BASE_LABELS     EQU 36
DEF MAP_NAME_SIGN_LOCAL_LABELS    EQU 41 ; cities/routes + 5 basic landmarks, bank $3D
DEF MAP_NAME_SIGN_EXT_A_LABELS    EQU 47 ; Silph + #218 + #220 in bank $2E
DEF MAP_NAME_SIGN_EXT_B_LABELS    EQU 19 ; #222 + #225 in bank $2F
DEF MAP_NAME_SIGN_SPECIAL_LABELS  EQU 71 ; 5 basic + 11 Silph + 55 new
DEF MAP_NAME_SIGN_POKEMON_TOWER_1F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 16
DEF MAP_NAME_SIGN_POKEMON_TOWER_2F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 17
DEF MAP_NAME_SIGN_POKEMON_TOWER_3F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 18
DEF MAP_NAME_SIGN_POKEMON_TOWER_4F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 19
DEF MAP_NAME_SIGN_POKEMON_TOWER_5F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 20
DEF MAP_NAME_SIGN_POKEMON_TOWER_6F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 21
DEF MAP_NAME_SIGN_POKEMON_TOWER_7F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 22
DEF MAP_NAME_SIGN_POKEMON_MANSION_1F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 23
DEF MAP_NAME_SIGN_POKEMON_MANSION_2F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 24
DEF MAP_NAME_SIGN_POKEMON_MANSION_3F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 25
DEF MAP_NAME_SIGN_POKEMON_MANSION_B1F          EQU MAP_NAME_SIGN_SPECIAL_BASE + 26
DEF MAP_NAME_SIGN_ROCKET_HIDEOUT_B1F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 27
DEF MAP_NAME_SIGN_ROCKET_HIDEOUT_B2F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 28
DEF MAP_NAME_SIGN_ROCKET_HIDEOUT_B3F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 29
DEF MAP_NAME_SIGN_ROCKET_HIDEOUT_B4F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 30
DEF MAP_NAME_SIGN_GAME_CORNER                  EQU MAP_NAME_SIGN_SPECIAL_BASE + 31
DEF MAP_NAME_SIGN_SAFARI_ZONE_CENTER           EQU MAP_NAME_SIGN_SPECIAL_BASE + 32
DEF MAP_NAME_SIGN_SAFARI_ZONE_EAST             EQU MAP_NAME_SIGN_SPECIAL_BASE + 33
DEF MAP_NAME_SIGN_SAFARI_ZONE_NORTH            EQU MAP_NAME_SIGN_SPECIAL_BASE + 34
DEF MAP_NAME_SIGN_SAFARI_ZONE_WEST             EQU MAP_NAME_SIGN_SPECIAL_BASE + 35
DEF MAP_NAME_SIGN_MT_MOON_1F                   EQU MAP_NAME_SIGN_SPECIAL_BASE + 36
DEF MAP_NAME_SIGN_MT_MOON_B1F                  EQU MAP_NAME_SIGN_SPECIAL_BASE + 37
DEF MAP_NAME_SIGN_MT_MOON_B2F                  EQU MAP_NAME_SIGN_SPECIAL_BASE + 38
DEF MAP_NAME_SIGN_ROCK_TUNNEL_1F               EQU MAP_NAME_SIGN_SPECIAL_BASE + 39
DEF MAP_NAME_SIGN_ROCK_TUNNEL_B1F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 40
DEF MAP_NAME_SIGN_VICTORY_ROAD_1F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 41
DEF MAP_NAME_SIGN_VICTORY_ROAD_2F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 42
DEF MAP_NAME_SIGN_VICTORY_ROAD_3F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 43
DEF MAP_NAME_SIGN_CERULEAN_CAVE_1F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 44
DEF MAP_NAME_SIGN_CERULEAN_CAVE_2F             EQU MAP_NAME_SIGN_SPECIAL_BASE + 45
DEF MAP_NAME_SIGN_CERULEAN_CAVE_B1F            EQU MAP_NAME_SIGN_SPECIAL_BASE + 46
DEF MAP_NAME_SIGN_SEAFOAM_ISLANDS_1F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 47
DEF MAP_NAME_SIGN_SEAFOAM_ISLANDS_B1F          EQU MAP_NAME_SIGN_SPECIAL_BASE + 48
DEF MAP_NAME_SIGN_SEAFOAM_ISLANDS_B2F          EQU MAP_NAME_SIGN_SPECIAL_BASE + 49
DEF MAP_NAME_SIGN_SEAFOAM_ISLANDS_B3F          EQU MAP_NAME_SIGN_SPECIAL_BASE + 50
DEF MAP_NAME_SIGN_SEAFOAM_ISLANDS_B4F          EQU MAP_NAME_SIGN_SPECIAL_BASE + 51
DEF MAP_NAME_SIGN_CELADON_MART_1F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 52
DEF MAP_NAME_SIGN_CELADON_MART_2F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 53
DEF MAP_NAME_SIGN_CELADON_MART_3F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 54
DEF MAP_NAME_SIGN_CELADON_MART_4F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 55
DEF MAP_NAME_SIGN_CELADON_MART_5F              EQU MAP_NAME_SIGN_SPECIAL_BASE + 56
DEF MAP_NAME_SIGN_CELADON_MART_ROOF            EQU MAP_NAME_SIGN_SPECIAL_BASE + 57
DEF MAP_NAME_SIGN_CELADON_MANSION_1F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 58
DEF MAP_NAME_SIGN_CELADON_MANSION_2F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 59
DEF MAP_NAME_SIGN_CELADON_MANSION_3F           EQU MAP_NAME_SIGN_SPECIAL_BASE + 60
DEF MAP_NAME_SIGN_CELADON_MANSION_ROOF         EQU MAP_NAME_SIGN_SPECIAL_BASE + 61
DEF MAP_NAME_SIGN_MUSEUM_1F                    EQU MAP_NAME_SIGN_SPECIAL_BASE + 62
DEF MAP_NAME_SIGN_MUSEUM_2F                    EQU MAP_NAME_SIGN_SPECIAL_BASE + 63
DEF MAP_NAME_SIGN_SS_ANNE_1F                   EQU MAP_NAME_SIGN_SPECIAL_BASE + 64
DEF MAP_NAME_SIGN_SS_ANNE_2F                   EQU MAP_NAME_SIGN_SPECIAL_BASE + 65
DEF MAP_NAME_SIGN_SS_ANNE_3F                   EQU MAP_NAME_SIGN_SPECIAL_BASE + 66
DEF MAP_NAME_SIGN_SS_ANNE_B1F                  EQU MAP_NAME_SIGN_SPECIAL_BASE + 67
DEF MAP_NAME_SIGN_SS_ANNE_BOW                  EQU MAP_NAME_SIGN_SPECIAL_BASE + 68
DEF MAP_NAME_SIGN_SS_ANNE_KITCHEN              EQU MAP_NAME_SIGN_SPECIAL_BASE + 69
DEF MAP_NAME_SIGN_SS_ANNE_CAPTAINS_ROOM        EQU MAP_NAME_SIGN_SPECIAL_BASE + 70
ASSERT MAP_NAME_SIGN_SPECIAL_BASE + MAP_NAME_SIGN_SPECIAL_LABELS < $ff

; EnterMap has already loaded the destination and armed its normal delay.
; Prime only non-Fly warp-pad destinations so the destination floor label is
; ready before EnterMapAnim reveals the bottom of the target scene.
PrimeCGBMapNameSignForWarpPad::
	ld a, [wMapNameSignInitialized]
	and a
	ret z ; startup is silent; only later map transitions show signs
	ld a, [wd732]
	bit 3, a ; warp pad (Fly is separately identified below)
	ret z
	ld a, [wFlags_D733]
	bit 7, a ; Fly out of battle keeps its dedicated landing delay
	ret nz
	ld a, 1
	ld [wMapNameSignPending], a
	jp UpdateCGBMapNameSign

UpdateCGBMapNameSign::
	ld a, [wMapNameSignInitialized]
	and a
	jr nz, .initialized
	inc a
	ld [wMapNameSignInitialized], a
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	; Initialize the effective map identity without showing a sign.
	; Battle return also calls EnterMap and queues a map sign: if the
	; first Continue/New Game has not seeded this identity, the first
	; battle in the same map would compare against $ff and falsely pop it.
	call MapNameSignResolveRuntimeMap
	ld a, $ff ; unsupported/neutral maps keep the first real entry eligible
	jr nc, .initialIdentityResolved
	ld a, b ; existing city, route or supported landmark identity
.initialIdentityResolved
	ld [wMapNameSignEffectiveMap], a
	; New Game / Continue do not display an entry popup. Reset the
	; pending entry armed by EnterMap; future real map transitions still arm
	; the sign through EnterMap / CheckMapConnections as before.
	xor a
	ld [wMapNameSignTimer], a
	ld [wMapNameSignInitialMap], a ; reserved for WRAM layout compatibility
	ld [wMapNameSignPending], a
	ret

.initialized
	; A frame/step is not a map transition. Only the map loader arms it.
	ld a, [wMapNameSignPending]
	and a
	jr nz, .mapChanged

	ld a, [wMapNameSignTimer]
	and a
	ret z
	; Other code may already have reclaimed the Window.
	ldh a, [hWY]
	cp MAP_NAME_SIGN_Y
	jp nz, HideCGBMapNameSign
	ldh a, [rWY]
	cp MAP_NAME_SIGN_Y
	jp nz, HideCGBMapNameSign
	ldh a, [hAutoBGTransferEnabled]
	and a
	jp nz, HideCGBMapNameSign
	ld hl, wMapNameSignTimer
	dec [hl]
	ret nz
	jp HideCGBMapNameSign

.mapChanged
	; Only real map transitions are pending, including Fly landing.
	; Display time remains a full 120 frames once the sign is visible.
	cp 1
	jr z, .readyToDraw
	dec a
	ld [wMapNameSignPending], a
	ret
.readyToDraw
	; Every popup now comes from a real map transition, not startup.
	; Ordinary interiors stay neutral; physical floors still resolve normally.
	call MapNameSignResolveRuntimeMap
	jr nc, .notOutdoor
	ld a, [wMapNameSignEffectiveMap]
	cp b
	jr nz, .show
	; Same effective landmark cancels any old popup instead of re-showing it.
	ld a, b
	ld [wMapNameSignLastRawMap], a
	xor a
	ld [wMapNameSignPending], a
	jp HideCGBMapNameSign
.notOutdoor
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	xor a
	ld [wMapNameSignPending], a
	jp HideCGBMapNameSign

.show
	; Shared CGB Window is safe only when no menu/text/VRAM upload owns it.
	ldh a, [hAutoBGTransferEnabled]
	and a
	ret nz
	ldh a, [hRedrawRowOrColumnMode]
	and a
	ret nz
	ldh a, [hVBlankCopyBGSource]
	and a
	ret nz
	ldh a, [rLCDC]
	bit 7, a
	ret z
	ld a, [wCurMap]
	ld [wMapNameSignLastRawMap], a
	ld a, b
	ld [wMapNameSignEffectiveMap], a
	xor a
	ld [wMapNameSignPending], a

	; #215-style continuous refresh: if the previous sign is still visible,
	; keep its frame on screen while the new 36 glyph tiles are rendered into
	; the inactive bank-1 buffer. Switch only the 36 Window tile IDs in one
	; fresh VBlank, so the frame never disappears and partial glyph uploads are
	; never visible.
	ld a, [wMapNameSignAttrsActive]
	and a
	jr z, .showFresh
	ldh a, [hWY]
	cp MAP_NAME_SIGN_Y
	jr nz, .showFreshAfterReclaim
	ldh a, [rWY]
	cp MAP_NAME_SIGN_Y
	jr nz, .showFreshAfterReclaim
	call MapNameSignRefreshVisible
	ld a, MAP_NAME_SIGN_FRAMES
	ld [wMapNameSignTimer], a
	ret

.showFreshAfterReclaim
	call HideCGBMapNameSign
.showFresh
	; Fresh popup uses the original buffer and writes the complete frame/map.
	xor a
	ld [wMapNameSignLabelBuffer], a

	; Short direct VRAM writes are synchronized by STAT mode checks.
	; The normal interrupt handler assumes VBK 0: mask its interrupt source
	; until VBK is restored, without changing the caller's IME state.
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, 1
	ldh [rVBK], a
	; The CHS CGB palette 0 follows the Red/Blue overworld tint.
	; Unlike RPP, CHS palette 7 also holds a tinted boot palette, not a
	; neutral text palette. Use dedicated BG palette 5 for white/black.
	call MapNameSignSetNeutralPalette

	; Original textbox-border tiles $80-$88 and native DFS glyphs $90-$b3.
	ld hl, MapNameSignFrame1bpp
	ld de, $8800
	ld bc, 9 * 8
	call MapNameSignCopy1bppAsOpaque2bpp
	ld de, $8900
	call MapNameSignCopyCurrentLabelToVRAM

	; Tile IDs go into Window map 1 in bank 0, not the live map BG.
	xor a
	ldh [rVBK], a
	ld hl, MapNameSignWindowTiles
	ld de, $9c00
	ld b, 4
.copyTileRows
	push bc
	ld c, 20
.copyTileColumn
	ld a, [hli]
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .copyTileColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .copyTileRows

	; CGB attribute: neutral palette 5, VRAM bank 1, BG priority. Every pixel
	; of the sign uses color 1 or 3 (never 0), so sprites do not bleed
	; through the Window; no Bank $01 OAM logic needs modification.
	ld a, 1
	ldh [rVBK], a
	ld de, $9c00
	ld b, 4
.copyAttrRows
	push bc
	ld c, 20
.copyAttrColumn
	ld a, %10001101
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .copyAttrColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .copyAttrRows

	xor a
	ldh [rVBK], a
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ld a, 1
	ld [wMapNameSignAttrsActive], a
	ld a, MAP_NAME_SIGN_FRAMES
	ld [wMapNameSignTimer], a
	ld a, 7
	ldh [rWX], a
	ld a, MAP_NAME_SIGN_Y
	ldh [hWY], a
	ldh [rWY], a
	ret

; Resolve the currently loaded physical map to an effective sign identity.
; Carry set: B = supported identity. Carry clear: neutral/unsupported indoor map.
; Ordinary interiors and gates deliberately remain neutral, preserving the previous
; effective city/route/landmark until the player reaches another supported map.
MapNameSignResolveRuntimeMap:
	ld a, [wCurMap]
	cp FIRST_INDOOR_MAP
	jr nc, .special
	cp NUM_CITY_MAPS
	jr c, .external
	cp FIRST_ROUTE_MAP
	jr c, .unsupported ; unused raw map $0b
.external
	ld b, a
	scf
	ret

.special
	ld c, a
	ld hl, MapNameSignSpecialMapTable
.loop
	ld a, [hli]
	cp $ff
	jr z, .unsupported
	cp c
	jr z, .found
	inc hl
	jr .loop
.found
	ld b, [hl]
	scf
	ret
.unsupported
	and a ; clear carry
	ret

MapNameSignSpecialMapTable:
	; Neutral maps are intentionally excluded. Their current identity persists
	; while playing; startup no longer requests an initial sign.
	db VIRIDIAN_FOREST, MAP_NAME_SIGN_VIRIDIAN_FOREST
	db DIGLETTS_CAVE, MAP_NAME_SIGN_DIGLETTS_CAVE
	db POWER_PLANT, MAP_NAME_SIGN_POWER_PLANT
	db SILPH_CO_1F, MAP_NAME_SIGN_SILPH_CO_1F
	db SILPH_CO_2F, MAP_NAME_SIGN_SILPH_CO_2F
	db SILPH_CO_3F, MAP_NAME_SIGN_SILPH_CO_3F
	db SILPH_CO_4F, MAP_NAME_SIGN_SILPH_CO_4F
	db SILPH_CO_5F, MAP_NAME_SIGN_SILPH_CO_5F
	db SILPH_CO_6F, MAP_NAME_SIGN_SILPH_CO_6F
	db SILPH_CO_7F, MAP_NAME_SIGN_SILPH_CO_7F
	db SILPH_CO_8F, MAP_NAME_SIGN_SILPH_CO_8F
	db SILPH_CO_9F, MAP_NAME_SIGN_SILPH_CO_9F
	db SILPH_CO_10F, MAP_NAME_SIGN_SILPH_CO_10F
	db SILPH_CO_11F, MAP_NAME_SIGN_SILPH_CO_11F
	; RPP #218: map to the actual floor / area (not Town Map aliases).
	db POKEMON_TOWER_1F, MAP_NAME_SIGN_POKEMON_TOWER_1F
	db POKEMON_TOWER_2F, MAP_NAME_SIGN_POKEMON_TOWER_2F
	db POKEMON_TOWER_3F, MAP_NAME_SIGN_POKEMON_TOWER_3F
	db POKEMON_TOWER_4F, MAP_NAME_SIGN_POKEMON_TOWER_4F
	db POKEMON_TOWER_5F, MAP_NAME_SIGN_POKEMON_TOWER_5F
	db POKEMON_TOWER_6F, MAP_NAME_SIGN_POKEMON_TOWER_6F
	db POKEMON_TOWER_7F, MAP_NAME_SIGN_POKEMON_TOWER_7F
	db POKEMON_MANSION_1F, MAP_NAME_SIGN_POKEMON_MANSION_1F
	db POKEMON_MANSION_2F, MAP_NAME_SIGN_POKEMON_MANSION_2F
	db POKEMON_MANSION_3F, MAP_NAME_SIGN_POKEMON_MANSION_3F
	db POKEMON_MANSION_B1F, MAP_NAME_SIGN_POKEMON_MANSION_B1F
	db ROCKET_HIDEOUT_B1F, MAP_NAME_SIGN_ROCKET_HIDEOUT_B1F
	db ROCKET_HIDEOUT_B2F, MAP_NAME_SIGN_ROCKET_HIDEOUT_B2F
	db ROCKET_HIDEOUT_B3F, MAP_NAME_SIGN_ROCKET_HIDEOUT_B3F
	db ROCKET_HIDEOUT_B4F, MAP_NAME_SIGN_ROCKET_HIDEOUT_B4F
	db GAME_CORNER, MAP_NAME_SIGN_GAME_CORNER
	; RPP #220: map to the actual floor / area (not Town Map aliases).
	db SAFARI_ZONE_CENTER, MAP_NAME_SIGN_SAFARI_ZONE_CENTER
	db SAFARI_ZONE_EAST, MAP_NAME_SIGN_SAFARI_ZONE_EAST
	db SAFARI_ZONE_NORTH, MAP_NAME_SIGN_SAFARI_ZONE_NORTH
	db SAFARI_ZONE_WEST, MAP_NAME_SIGN_SAFARI_ZONE_WEST
	db MT_MOON_1F, MAP_NAME_SIGN_MT_MOON_1F
	db MT_MOON_B1F, MAP_NAME_SIGN_MT_MOON_B1F
	db MT_MOON_B2F, MAP_NAME_SIGN_MT_MOON_B2F
	db ROCK_TUNNEL_1F, MAP_NAME_SIGN_ROCK_TUNNEL_1F
	db ROCK_TUNNEL_B1F, MAP_NAME_SIGN_ROCK_TUNNEL_B1F
	db VICTORY_ROAD_1F, MAP_NAME_SIGN_VICTORY_ROAD_1F
	db VICTORY_ROAD_2F, MAP_NAME_SIGN_VICTORY_ROAD_2F
	db VICTORY_ROAD_3F, MAP_NAME_SIGN_VICTORY_ROAD_3F
	db CERULEAN_CAVE_1F, MAP_NAME_SIGN_CERULEAN_CAVE_1F
	db CERULEAN_CAVE_2F, MAP_NAME_SIGN_CERULEAN_CAVE_2F
	db CERULEAN_CAVE_B1F, MAP_NAME_SIGN_CERULEAN_CAVE_B1F
	db SEAFOAM_ISLANDS_1F, MAP_NAME_SIGN_SEAFOAM_ISLANDS_1F
	db SEAFOAM_ISLANDS_B1F, MAP_NAME_SIGN_SEAFOAM_ISLANDS_B1F
	db SEAFOAM_ISLANDS_B2F, MAP_NAME_SIGN_SEAFOAM_ISLANDS_B2F
	db SEAFOAM_ISLANDS_B3F, MAP_NAME_SIGN_SEAFOAM_ISLANDS_B3F
	db SEAFOAM_ISLANDS_B4F, MAP_NAME_SIGN_SEAFOAM_ISLANDS_B4F
	; RPP #222: map to the actual floor / area (not Town Map aliases).
	db CELADON_MART_1F, MAP_NAME_SIGN_CELADON_MART_1F
	db CELADON_MART_2F, MAP_NAME_SIGN_CELADON_MART_2F
	db CELADON_MART_3F, MAP_NAME_SIGN_CELADON_MART_3F
	db CELADON_MART_4F, MAP_NAME_SIGN_CELADON_MART_4F
	db CELADON_MART_5F, MAP_NAME_SIGN_CELADON_MART_5F
	db CELADON_MART_ROOF, MAP_NAME_SIGN_CELADON_MART_ROOF
	db CELADON_MANSION_1F, MAP_NAME_SIGN_CELADON_MANSION_1F
	db CELADON_MANSION_2F, MAP_NAME_SIGN_CELADON_MANSION_2F
	db CELADON_MANSION_3F, MAP_NAME_SIGN_CELADON_MANSION_3F
	db CELADON_MANSION_ROOF, MAP_NAME_SIGN_CELADON_MANSION_ROOF
	db MUSEUM_1F, MAP_NAME_SIGN_MUSEUM_1F
	db MUSEUM_2F, MAP_NAME_SIGN_MUSEUM_2F
	; RPP #225: map to the actual floor / area (not Town Map aliases).
	db SS_ANNE_1F, MAP_NAME_SIGN_SS_ANNE_1F
	db SS_ANNE_2F, MAP_NAME_SIGN_SS_ANNE_2F
	db SS_ANNE_3F, MAP_NAME_SIGN_SS_ANNE_3F
	db SS_ANNE_B1F, MAP_NAME_SIGN_SS_ANNE_B1F
	db SS_ANNE_BOW, MAP_NAME_SIGN_SS_ANNE_BOW
	db SS_ANNE_KITCHEN, MAP_NAME_SIGN_SS_ANNE_KITCHEN
	db SS_ANNE_CAPTAINS_ROOM, MAP_NAME_SIGN_SS_ANNE_CAPTAINS_ROOM
	; Cabins/roof room share the corresponding real deck or rooftop identity.
	db CELADON_MANSION_ROOF_HOUSE, MAP_NAME_SIGN_CELADON_MANSION_ROOF
	db SS_ANNE_1F_ROOMS, MAP_NAME_SIGN_SS_ANNE_1F
	db SS_ANNE_2F_ROOMS, MAP_NAME_SIGN_SS_ANNE_2F
	db SS_ANNE_B1F_ROOMS, MAP_NAME_SIGN_SS_ANNE_B1F
	db $ff
; Render the current effective label into DE in VRAM bank 1.
MapNameSignCopyCurrentLabelToVRAM:
	push de
	ld a, [wMapNameSignEffectiveMap]
	cp MAP_NAME_SIGN_SILPH_CO_1F
	jr nc, .externalIndex
	cp MAP_NAME_SIGN_SPECIAL_BASE
	jr nc, .specialIndex
	cp FIRST_ROUTE_MAP
	jr c, .labelIndexReady
	dec a ; skip unused map $0b; routes follow the eleven cities
	jr .labelIndexReady
.specialIndex
	sub MAP_NAME_SIGN_SPECIAL_BASE
	add MAP_NAME_SIGN_BASE_LABELS
.labelIndexReady
	ld e, a
	ld d, 0
	ld hl, MapNameSignLabelPointers
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	ld bc, 18 * 2 * 8
	jp MapNameSignCopy1bppAsOpaque2bpp
.externalIndex
	; Execute the decoder inside the source bank: never switch away from
	; bank $3D while executing the $3D decoder. Bankswitch restores the bank.
	pop de
	cp MAP_NAME_SIGN_CELADON_MART_1F
	jr nc, .externalB
	ld b, BANK(MapNameSignCopyExtendedBank2E)
	ld hl, MapNameSignCopyExtendedBank2E
	jp Bankswitch
.externalB
	ld b, BANK(MapNameSignCopyExtendedBank2F)
	ld hl, MapNameSignCopyExtendedBank2F
	jp Bankswitch

; Keep the visible frame while changing landmarks. The inactive label buffer is
; safe to rewrite during visible scanlines; only the 36 tile IDs are swapped in
; one fresh VBlank.
MapNameSignRefreshVisible:
	; Keep interrupt sources masked from the bank-1 glyph upload through the
	; fresh-VBlank tile-ID swap, matching the #215 ownership rule.
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, [wMapNameSignLabelBuffer]
	xor 1
	ld [wMapNameSignLabelBuffer], a
	and a
	jr z, .buffer0
	ld de, $8b40 ; tile $b4, 36 tiles through $d7
	jr .bufferReady
.buffer0
	ld de, $8900 ; tile $90, 36 tiles through $b3
.bufferReady
	ld a, 1
	ldh [rVBK], a
	call MapNameSignCopyCurrentLabelToVRAM
	xor a
	ldh [rVBK], a

	; Match RPP #215's ownership rule: keep interrupt sources masked while
	; waiting for a *fresh* VBlank. If the normal VBlank handler runs first,
	; most of the transfer window is already gone and the two 18-tile rows can
	; be only partially switched, producing mixed top/bottom Chinese glyphs.
	call MapNameSignWaitFreshVBlank
	ld a, [wMapNameSignLabelBuffer]
	and a
	ld a, $90
	jr z, .tileBaseReady
	ld a, $b4
.tileBaseReady
	call MapNameSignWriteVisibleLabelTileIDs
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ret

; A = first tile id for the 36 label tiles. Called at the start of VBlank.
MapNameSignWriteVisibleLabelTileIDs:
	ld c, a
	ld de, $9c00 + BG_MAP_WIDTH + 1
	ld b, 18
.row1
	ld a, c
	ld [de], a
	inc c
	inc de
	dec b
	jr nz, .row1
	ld de, $9c00 + 2 * BG_MAP_WIDTH + 1
	ld b, 18
.row2
	ld a, c
	ld [de], a
	inc c
	inc de
	dec b
	jr nz, .row2
	ret

MapNameSignWaitFreshVBlank:
	; If called during the current VBlank, wait for it to end first so all 36
	; tile-ID writes belong to one new VBlank window.
.waitCurrentVBlankEnd
	ldh a, [rLY]
	cp 144
	jr nc, .waitCurrentVBlankEnd
.waitNextVBlank
	ldh a, [rLY]
	cp 144
	jr c, .waitNextVBlank
	ret

HideCGBMapNameSign::
	; Called explicitly before dialogue/START overwrites Window BG $9c00.
	xor a
	ld [wMapNameSignTimer], a
	ld a, [wMapNameSignAttrsActive]
	and a
	ret z
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ldh [rWY], a
	xor a
	ld [wMapNameSignAttrsActive], a
	ld a, [rIE]
	push af
	xor a
	ld [rIE], a
	ld a, 1
	ldh [rVBK], a
	; Restore bank-zero Window ownership for all four modified rows.
	; START and dialogue continue using their existing screen tile writer.
	ld de, $9c00
	ld b, 4
.clearRows
	push bc
	ld c, 20
.clearColumn
	xor a
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec c
	jr nz, .clearColumn
	pop bc
	call MapNameSignSkipMapRowPadding
	dec b
	jr nz, .clearRows
	xor a
	ldh [rVBK], a
	call MapNameSignDropPendingVBlank
	pop af
	ld [rIE], a
	ret

; Palette 5 is private to this CGB-only Window.  Its color 1 is white
; (the opaque background) and its color 3 is black (the glyph/border ink).
; The 1bpp -> 2bpp blitter below produces only indexes 1 and 3.
MapNameSignSetNeutralPalette:
	ld a, $a8 ; index $28 = BG palette 5, enable auto-increment
	ldh [rBGPI], a
	ld hl, .colors
	ld b, 8
.copy
	ld a, [hli]
	call MapNameSignWaitVRAM
	ldh [rBGPD], a
	dec b
	jr nz, .copy
	ret
.colors
	RGB 31, 31, 31 ; color 0: white (unused)
	RGB 31, 31, 31 ; color 1: opaque white background
	RGB 16, 16, 16 ; color 2: gray (unused)
	RGB  0,  0,  0 ; color 3: black ink

; Wait for VRAM access in visible scanline modes. Preserve the byte in A.
MapNameSignWaitVRAM:
	push af
.wait
	ldh a, [rSTAT]
	and %10
	jr nz, .wait
	pop af
	ret

; 1bpp input rows -> opaque bank-1 2bpp output rows:
; background color 1 and ink color 3, both higher priority than OBJ.
MapNameSignCopy1bppAsOpaque2bpp:
.copyRow
	ld a, $ff
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	ld a, [hli]
	call MapNameSignWaitVRAM
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copyRow
	ret

MapNameSignSkipMapRowPadding:
	ld a, e
	add 32 - 20
	ld e, a
	ret nc
	inc d
	ret

MapNameSignDropPendingVBlank:
	ld a, [rIF]
	res VBLANK, a
	ld [rIF], a
	ret

MapNameSignWindowTiles:
	db $85
	REPT 18
		db $81
	ENDR
	db $86
	db $83
	FOR i, 18
		db $90 + i
	ENDR
	db $84
	db $83
	FOR i, 18
		db $a2 + i
	ENDR
	db $84
	db $87
	REPT 18
		db $82
	ENDR
	db $88

MapNameSignFrame1bpp:
	INCBIN "gfx/map_name_sign/frame.1bpp"
MapNameSignFrameEnd:
	ASSERT MapNameSignFrameEnd - MapNameSignFrame1bpp == 9 * 8
MapNameSignLabelPointers:
	FOR i, MAP_NAME_SIGN_LOCAL_LABELS
		dw MapNameSignLabelData + i * (18 * 2 * 8)
	ENDR
MapNameSignLabelData:
	; Index 0..10: towns; 11..35: Routes 1..25.
	; Index 36..40: five basic landmarks. All floor/area signs are banked.
	INCBIN "gfx/map_name_sign/labels.1bpp"
MapNameSignLabelDataEnd:
	ASSERT MapNameSignLabelDataEnd - MapNameSignLabelData == MAP_NAME_SIGN_LOCAL_LABELS * 18 * 2 * 8
