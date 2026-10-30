#!/usr/bin/env python3
"""FLH-1.20 flicker-fix contracts; static only, not ROM testing."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
get = lambda p: (root / p).read_text(encoding="utf-8")
version = get("src/data/game_version.asm")
main = get("src/engine/menus/main_menu.asm")
end = get("src/engine/battle/end_of_battle.asm")
party = get("src/engine/menus/party_menu.asm")
battle = get("src/engine/battle/core.asm")
assert 'db "FLH-1.20@"' in version
assert 'hlcoord 11, 0 ; FLH-1.20 正式标记为 8 字符' in main
# Party redraw stays hidden until the complete BG is ready.
redraw = party.split('RedrawPartyMenu_::', 1)[1].split('PartyMenuItemUseMessagePointers:', 1)[0]
assert redraw.lstrip().startswith('xor a\n\tldh [hAutoBGTransferEnabled], a')
assert 'ld a, 1\n\tldh [hAutoBGTransferEnabled], a\n\tcall Delay3' in redraw
assert 'ldh a, [rBGP]\n\tand a\n\tret nz' in redraw
assert redraw.index('ret nz') < redraw.index('ld a, [wIsInBattle]')
# Battle Party direct-return and per-mon action-menu contracts are preserved.
deselect = battle.split('.partyMonDeselected', 1)[1].split('.switchedMon', 1)[0]
assert deselect.lstrip().startswith('xor a\n\tldh [hAutoBGTransferEnabled], a')
quit_party = battle.split('.quitPartyMenu', 1)[1].split('.partyMonDeselected', 1)[0]
assert 'call DisplayBattleMenu.drawBattleMenu' in quit_party
assert 'call Delay3' in quit_party
assert 'jp DisplayBattleMenu.handleBattleMenuInput' in quit_party
# DMG battle Window is hidden only after whiteout; CGB skips the new hide.
block = end.split('call WaitForSoundToFinish', 1)[1].split('ld a, $ff', 1)[0]
assert 'call GBPalWhiteOut' in block
assert block.index('call GBPalWhiteOut') < block.index('ldh a, [hCGB]')
assert 'jr nz, .battleWindowHidden' in block
assert 'ld a, SCREEN_HEIGHT_PX' in block
assert 'ldh [hWY], a' in block
assert 'ldh [rWY], a' in block
print('PASS FLH-1.20: Party flicker fixes and DMG battle-return Window hide preserved (static only)')
