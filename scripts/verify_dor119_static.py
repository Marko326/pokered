#!/usr/bin/env python3
"""DOR-1.19 menu/DMG/CGB regression structure only; not ROM testing."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
get = lambda p: (root / p).read_text(encoding="utf-8")
version = get('src/data/game_version.asm')
main = get('src/engine/menus/main_menu.asm')
party = get('src/engine/menus/party_menu.asm')
vblank = get('src/home/vblank.asm')
win = get('src/engine/menus/start_window_fast.asm')
sub = get('src/engine/menus/start_sub_menus.asm')
pokedex = get('src/engine/menus/pokedex.asm')
assert 'db "DOR-1.19@"' in version
assert 'hlcoord 11, 0 ; DOR-1.19 正式标记为 8 字符' in main
# CGB sprite OAM attribute encoding, no extra 40-object VBlank scan.
assert 'DEF OAM_OBP1      EQU (1 << OAM_OBP_NUM) | %00000001' in get('src/constants/oam_constants.asm')
assert 'and %11110000\n\tld [de], a' in get('src/engine/gfx/sprite_oam.asm')
assert 'call CGBFixOAMPalettes' not in vblank
assert 'call UpdateCGBDmgPalettes' in vblank
assert vblank.index('call VBlankCopyDouble') < vblank.index('call hDMARoutine')
# Party CGB battle and DMG first-frame reveals both gated with LCD off.
reveal = party.split('.done\n', 1)[1].split('.printItemUseMessage', 1)[0]
assert all(s in reveal for s in ('ld a, [wIsInBattle]', 'ldh a, [hCGB]',
    'call DisableLCD', 'call GBPalNormal', 'call UpdateCGBDmgPalettes',
    'call hDMARoutine', 'call EnableLCD', '.normalReveal', '.cgbFieldReveal'))
assert 'call DisableLCD\n\tcall GBPalNormal\n\tcall EnableLCD' in reveal
# START full-screen children: DMG palette cover and reveal at LCD boundary.
for label, cal in (('RevealFullScreenLoadGBPal::','LoadGBPal'),
                   ('RevealFullScreenGBPalNormal::','GBPalNormal'),
                   ('CoverFullScreenWithWhite::','GBPalWhiteOut')):
    assert win.count(label) == 1
    body = win.split(label, 1)[1].split('::', 1)[0]
    assert all(s in body for s in (f'jp nz, {cal}', 'call DisableLCD',
                                   f'call {cal}', 'jp EnableLCD'))
assert 'jp RevealFullScreenLoadGBPal' in win
assert 'farcall RevealFullScreenLoadGBPal' in main
assert 'call CoverFullScreenWithWhite\n\tjp Delay3' in win
options = sub.split('StartMenu_Option::', 1)[1].split('SwitchPartyMon::', 1)[0]
assert options.count('farcall CoverFullScreenWithWhiteDelay3') == 2
trainer = sub.split('StartMenu_TrainerInfo::', 1)[1].split('DrawTrainerInfo:', 1)[0]
assert trainer.count('farcall CoverFullScreenWithWhite') == 2
assert 'farcall RevealFullScreenGBPalNormal' in trainer
assert 'ShowPokedexMenu:\n\tfarcall CoverFullScreenWithWhite' in pokedex
assert 'farcall CoverFullScreenWithWhiteDelay3' in pokedex
assert 'call Delay3\n\tfarcall RevealFullScreenGBPalNormal\n\tcall HandleMenuInput' in pokedex
assert 'RestoreStartMenuFromItemNoWhite::' in win
print('PASS DOR-1.19: CGB OAM, DMG Party, START full-screen transitions, formal version (static only)')
