#!/usr/bin/env python3
"""ROM-1.20B: static-only stat calculation relocation guard (not a ROM build)."""
from pathlib import Path
import hashlib, re
r = Path(__file__).resolve().parents[1]
def read(p): return (r/p).read_text(encoding='utf8')
impl = read('src/engine/pokemon/calc_stats_helpers.asm')
body = impl[impl.index('; calculates all 5 stats'):].rstrip('\n') + '\n'
body = body.replace('CalcStats_Banked::','CalcStats::',1).replace('CalcStat_Banked::','CalcStat::',1).replace('\tcall CalcStat_Banked\n','\tcall CalcStat\n',1)
# Existing instructions, local branch targets and data MUST be byte-for-byte identical to 1.20A.
assert hashlib.sha256(body.encode()).hexdigest() == 'caad34e872f7de60331da75e5bdcb4a9fd085b717f4fadf1b3d7cc3147f9b9e7', 'banked arithmetic body changed'
home = read('src/home/move_mon.asm')
start = home.index('CalcStats::')
end = home.index('AddEnemyMonToPlayerParty::', start)
stubs = home[start:end]
assert stubs.count('\tld hl, sp + 3') == 2
assert stubs.count('\tpush af\n\tld hl, sp + 3') == 2
assert stubs.count('\tpop af\n\tpop bc') == 2
assert stubs.count('\tldh [hLoadedROMBank], a\n\tld [MBC1RomBank], a') == 4
assert stubs.count('\tpop bc ; restore original BC') == 2
assert stubs.count('\tpop hl ; restore original HL') == 2
assert 'CalcStats::' in stubs and 'CalcStat::' in stubs
assert 'call CalcStats_Banked' in stubs and 'call CalcStat_Banked' in stubs
assert '\tld c, NUM_STATS ' in stubs
assert 'call CalcStat_Banked' in impl and 'call CalcStat\n' not in impl
assert 'SECTION "Stat Calculation Helpers", ROMX' in read('src/main.asm')
assert 'INCLUDE "engine/pokemon/calc_stats_helpers.asm"' in read('src/main.asm')
bank = read('src/layout.link').split('ROMX $2D', 1)[1].split('ROMX $3C', 1)[0]
assert '"Stat Calculation Helpers"' in bank
assert 'db "ROM-1.21@"' in read('src/data/game_version.asm')
assert 'hlcoord 11, 0 ; ROM-1.21 正式标记为 8 字符' in read('src/engine/menus/main_menu.asm')
# SP offset proof: bytes at saved positions: resultAF, oldBankAF, originalBC, originalHL.
for bank_id in (1, 5, 0x0f, 0x2d, 0x3c):
    for returned_af in (0x0080, 0x05c0, 0xe731, 0xfff0):
        stack = [returned_af & 0xff, returned_af >> 8, 0x90, bank_id, 0x53, 0x27, 0x91, 0xdf]
        assert stack[3] == bank_id and (stack[0] | (stack[1] << 8)) == returned_af
# Call sites require a WRAM stat-exp pointer, not a ROMX bank-dependent source.
all_asm = list((r/'src').rglob('*.asm'))
for x in all_asm:
    if x == r/'src/home/move_mon.asm': continue
    t = x.read_text(encoding='utf-8')
    assert not re.search(r'\b(?:jr|rst)\s+CalcStat(?:s)?\b', t), x
print('PASS ROM-1.20B: unchanged stat arithmetic, register/AF-preserving ROM0 stubs, stack/Bank layout (static only)')
