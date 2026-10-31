#!/usr/bin/env python3
"""DOR-1.17C source-only checks; does not prove ROM builds or real hardware timing."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
get=lambda x:(root/x).read_text(encoding="utf-8")
fade=get('src/home/fade.asm')
entry=fade.split('LoadGBPal::',1)[1].split('GBFadeInFromBlack::',1)[0]
door=fade.split('GBDoorFadeOutToBlackVBlank::',1)[1].split('GBFadeOutToBlack::',1)[0]
vbl=get('src/home/vblank.asm')
mapcode=get('src/home/overworld.asm')
wr=get('src/ram/wram.asm')
assert 'jp GBDoorFadeOutToBlackVBlank' in mapcode.split('PlayMapChangeSound::',1)[1].split('CheckIfInOutsideMap::',1)[0]
assert 'ld b, 4' in door and 'ld c, 8' in door and 'call DelayFrames' in door
assert door.count('ld [wDoorFadePending], a')==1
assert door.index('ld [wDoorFadeOBP1], a') < door.index('ld [wDoorFadePending], a')
assert door.index('ld [wDoorFadeOBP0], a') < door.index('ld [wDoorFadePending], a')
assert door.index('ld [wDoorFadeBGP], a') < door.index('ld [wDoorFadePending], a')
assert 'ld [wDoorFadeRestore], a' in door
assert 'ld [wDoorFadePending], a' in entry and 'ld [wDoorFadeRestore], a' in entry
assert 'ldh [rBGP], a' in entry and 'ldh [rOBP1], a' in entry
assert vbl.index('ld a, [wDoorFadePending]') < vbl.index('call UpdateCGBDmgPalettes')
assert vbl.index('ldh [rBGP], a') < vbl.index('call UpdateCGBDmgPalettes')
assert vbl.index('ldh [rOBP0], a') < vbl.index('call UpdateCGBDmgPalettes')
assert vbl.index('ldh [rOBP1], a') < vbl.index('call UpdateCGBDmgPalettes')
assert 'wDoorFadePending:: db\nwDoorFadeBGP:: db\nwDoorFadeOBP0:: db\nwDoorFadeOBP1:: db\nwDoorFadeRestore:: db\nds 19' in wr
assert any(v in get('src/data/game_version.asm') for v in ('DOR-1.17C@','DOR-1.17D@','DOR-1.18@','DOR-1.19@','FLH-1.20@','ROM-1.20B@', 'ROM-1.21@'))
assert any(v in get('src/engine/menus/main_menu.asm') for v in ('hlcoord 10, 0 ; DOR-1.17C','hlcoord 10, 0 ; DOR-1.17D','hlcoord 11, 0 ; DOR-1.18','hlcoord 11, 0 ; DOR-1.19','hlcoord 11, 0 ; FLH-1.20','hlcoord 10, 0 ; ROM-1.20B', 'hlcoord 11, 0 ; ROM-1.21'))
print('PASS: DOR-1.17C door fade VBlank commit, palette restoration, unchanged stage count, version and WRAM padding')
