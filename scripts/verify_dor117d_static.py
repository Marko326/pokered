#!/usr/bin/env python3
"""Retained DOR-1.17D implementation checks; not cycle or hardware verification."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
get=lambda p:(root/p).read_text(encoding='utf-8')
code=get('src/home/overworld.asm')
door=code.split('PlayMapChangeSound::',1)[1].split('CheckIfInOutsideMap::',1)[0]
mapload=code.split('LoadMapData::',1)[1].split('SwitchToMapRomBank::',1)[0]
assert 'ldh a, [hCGB]\n\tand a\n\tjp nz, GBFadeOutToBlack' in door
assert 'jp GBDoorFadeOutToBlackVBlank' in door
assert mapload.index('call LoadPlayerSpriteGraphics') < mapload.index('.restoreRomBank\n\t; DMG: release')
assert mapload.index('.keepDMGMapGuard') < mapload.index('call LoadPlayerSpriteGraphics')
assert mapload.count('ldh [hMapLoadVRAMSafeFlag], a')==4
fade=get('src/home/fade.asm')
assert 'ld c, 8' in fade.split('GBDoorFadeOutToBlackVBlank::',1)[1].split('GBFadeOutToBlack::',1)[0]
assert 'ld [wDoorFadeRestore], a' in fade
assert 'ld [wDoorFadePending], a' in fade.split('LoadGBPal::',1)[1].split('GBFadeInFromBlack::',1)[0]
vblank=get('src/home/vblank.asm')
assert vblank.index('ld a, [wDoorFadePending]') < vblank.index('call UpdateCGBDmgPalettes')
init=get('src/home/init.asm'); assert 'ld [wDoorFadePending], a' in init.split('home2_ret::',1)[1].split('\tei',1)[0]
assert 'ld [wDoorFadeRestore], a' in init.split('home2_ret::',1)[1].split('\tei',1)[0]
wr=get('src/ram/wram.asm')
assert 'wDoorFadePending:: db\nwDoorFadeBGP:: db\nwDoorFadeOBP0:: db\nwDoorFadeOBP1:: db\nwDoorFadeRestore:: db\nds 19' in wr
assert any(v in get('src/data/game_version.asm') for v in ('DOR-1.18@', 'DOR-1.19@'))
assert any(v in get('src/engine/menus/main_menu.asm') for v in ('hlcoord 11, 0 ; DOR-1.18', 'hlcoord 11, 0 ; DOR-1.19'))
print('PASS DOR-1.18: retained DOR-1.17D DMG fade route, delayed map guard, VBlank reveal, boot state, formal version')
