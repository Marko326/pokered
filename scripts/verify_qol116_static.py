#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sub = (ROOT / 'src/engine/menus/start_sub_menus.asm').read_text(encoding='utf-8')
fast = (ROOT / 'src/engine/menus/start_window_fast.asm').read_text(encoding='utf-8')
main = (ROOT / 'src/engine/menus/main_menu.asm').read_text(encoding='utf-8')
ver = (ROOT / 'src/data/game_version.asm').read_text(encoding='utf-8')


def block(text: str, start: str, end: str) -> str:
    a = text.index(start)
    b = text.index(end, a)
    return text[a:b]

pokedex = block(sub, 'StartMenu_Pokedex::', 'StartMenu_Pokemon::')
party = block(sub, 'StartMenu_Pokemon::', 'StartMenu_Item::')
item = block(sub, 'StartMenu_Item::', 'StartMenu_TrainerInfo::')
trainer = block(sub, 'StartMenu_TrainerInfo::', 'DrawTrainerInfo:')
options = block(sub, 'StartMenu_Option::', 'SwitchPartyMon::')
save = block(sub, 'StartMenu_SaveReset::', 'StartMenu_Option::')

checks = [
    ('formal version', ('db "QOL-1.17@"' in ver or 'db "DOR-1.19@"' in ver)),
    ('formal Options alignment', ('hlcoord 11, 0 ; QOL-1.17 正式标记为 8 字符' in main or 'hlcoord 11, 0 ; DOR-1.19 正式标记为 8 字符' in main)),
    ('Pokédex safe return', 'RestoreStartMenuFromPokedexWhite' in pokedex and 'jp StartMenuInputLoop' in pokedex and 'RedisplayStartMenu' not in pokedex),
    ('Party safe return', 'RestoreStartMenuFromPartyWhite' in party and 'jp StartMenuInputLoop' in party),
    ('Bag clean fast return', '.fastExitMenu' in item and 'RestoreStartMenuInputStateFromSaved' in item),
    ('Bag dirty no-white return', '.exitMenuDirtyDFS' in item and 'RestoreStartMenuFromItemNoWhite' in item and 'GBPalWhiteOutWithDelay3' not in block(item, '.exitMenuDirtyDFS', '.choseItem')),
    ('Bag dirty latch armed', '.choseItem' in item and 'ld [wStartMenuClosePending], a' in item),
    ('Trainer safe return', 'RestoreStartMenuFromTrainerWhite' in trainer and 'jp StartMenuInputLoop' in trainer),
    ('Options DFS-safe entry/return', (options.count('GBPalWhiteOutWithDelay3') >= 2 or options.count('farcall CoverFullScreenWithWhiteDelay3') >= 2) and 'RestoreStartMenuFromOptionsWhite' in options and 'jp StartMenuInputLoop' in options),
    ('Save semantics unchanged', 'predef SaveSAV' in save and 'call LoadScreenTilesFromBuffer2' in save and 'jp HoldTextDisplayOpen' in save),
    ('shared white helper', 'RestoreStartMenuFromPokedexWhite::' in fast and 'RestoreStartMenuFromPartyWhite::' in fast and 'RestoreStartMenuFromTrainerWhite::' in fast and 'RestoreStartMenuFromOptionsWhite::' in fast),
    ('Bag overlay helper has no palette call', 'RestoreStartMenuFromItemNoWhite::' in fast and 'call CopyStartMenuWindowFast' in fast and 'GBPalWhiteOut' not in block(fast, 'RestoreStartMenuFromItemNoWhite::', 'RestoreStartMenuInputStateFromSaved::') and 'LoadGBPal' not in block(fast, 'RestoreStartMenuFromItemNoWhite::', 'RestoreStartMenuInputStateFromSaved::')),
]

failed = []
for name, ok in checks:
    print(('PASS' if ok else 'FAIL') + ': ' + name)
    if not ok:
        failed.append(name)
if failed:
    raise SystemExit('QOL-1.17 static verification failed: ' + ', '.join(failed))
print('PASS: QOL-1.17 final START submenu return structure')
