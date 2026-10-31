#!/usr/bin/env python3
"""Checks the CHS Party swap reuses existing DFS glyphs without palette white flash.
This is a *static* guard, not a real Game Boy / CGB game video test.
"""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def read(s):return (root/s).read_text(encoding='utf-8')
start=read('src/engine/menus/start_sub_menus.asm')
party=read('src/engine/menus/party_menu.asm')
home=read('src/home/pokemon.asm')
wram=read('src/ram/wram.asm')
assert 'farcall CoverFullScreenWithWhite' not in start.split('SwitchPartyMon::',1)[1].split('SwitchPartyMon_ClearGfx:',1)[0]
main=start.split('SwitchPartyMon::',1)[1].split('SwitchPartyMon_SaveNameTiles:',1)[0]
assert main.index('call SwitchPartyMon_SaveNameTiles') < main.index('call SwitchPartyMon_ClearGfx')
assert main.count('call SwitchPartyMon_ClearGfx')==2
assert 'jp RedrawPartyMenu_' in main
assert 'ld [wPartySwapRedrawPending], a' in main
assert 'call nz, RestorePartySwapNameTiles' in party
assert 'jp nz, .skipNamePaintForSwap' in party
assert 'jr nz, .skipNameStaticizeForSwap' in party
assert 'call DFSStaticize' in party
assert 'ldh [hAutoBGTransferEnabled], a ; FLH-1.20:' in party
assert 'call Delay3' in party
assert 'wPartySwapNameTileCache:: ds 2 * 2 * 8' in wram
assert 'ds 80 - (2 * 2 * 8 + 1)' in wram
assert 'wPartySwapRedrawPending:: db' in wram
assert 'db "ROM-1.22@"' in read('src/data/game_version.asm')
assert 'hlcoord 11, 0 ; ROM-1.22 正式标记为 8 字符' in read('src/engine/menus/main_menu.asm')
assert home.count('farcall SwitchPartyMon')==2
# Regression: a pristine Party entry, any regular redraw, and any sub-menu
# return MUST clear swap-only state, independent of prior WRAM contents.
first=party.split('DrawPartyMenu_::',1)[1].split('RedrawPartyMenu_::',1)[0]
assert first.index('xor a') < first.index('ld [wPartySwapRedrawPending], a') < first.index('call ClearScreen')
back=home.split('GoBackToPartyMenu::',1)[1].split('PartyMenuInit::',1)[0]
assert back.index('ld [wPartySwapRedrawPending], a') < back.index('call RedrawPartyMenu')
wrapper=home.split('RedrawPartyMenu::',1)[1].split('DrawPartyMenuCommon::',1)[0]
assert wrapper.index('ld [wPartySwapRedrawPending], a') < wrapper.index('ld hl, RedrawPartyMenu_')
# The actual swap must directly jump to the inner redraw so its flag survives.
assert 'jp RedrawPartyMenu_' in main and 'jp RedrawPartyMenu\n' not in main
# No change to full redraw of names except within an actual swap.
assert party.count('call DFSStaticize') >= 2

assert 'cp START_PARTY_MENU' in home
# Model byte coordinates of 2 rows x 8 columns per Party mon, for all six rows.
for count in range(2,7):
 for before in range(count):
  for after in range(count):
   if before==after:continue
   tiles=list(range(20*18))
   orig=tiles[:]
   def offs(i):return [2+2*20*i+20*r+c for r in range(2) for c in range(8)]
   saved_a=[tiles[k] for k in offs(before)]
   saved_b=[tiles[k] for k in offs(after)]
   for k in offs(before)+offs(after):tiles[k]=-1
   for k,v in zip(offs(after),saved_a):tiles[k]=v
   for k,v in zip(offs(before),saved_b):tiles[k]=v
   assert [tiles[k] for k in offs(before)]==[orig[k] for k in offs(after)]
   assert [tiles[k] for k in offs(after)]==[orig[k] for k in offs(before)]
   for i in range(count):
    if i in (before,after):continue
    assert [tiles[k] for k in offs(i)]==[orig[k] for k in offs(i)]
print('PASS: first-entry/submenu/direct-redraw clearing + original swap redraw + no white mask + glyph cache + version')
print('UNVERIFIED: actual ROM build, DMG/CGB runtime video, shared DFS cache side effects')
