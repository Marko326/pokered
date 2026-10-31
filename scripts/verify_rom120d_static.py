#!/usr/bin/env python3
"""ROM-1.20D map-header pointer relocation: static guard only, no linking/runtime claim."""
from pathlib import Path
import re
r=Path(__file__).resolve().parent.parent
read=lambda p:(r/p).read_text()
h=read('src/home.asm'); m=read('src/main.asm'); l=read('src/layout.link')
w=read('src/home/overworld.asm'); t=read('src/data/maps/map_header_pointers.asm')
assert 'INCLUDE "data/maps/map_header_pointers.asm"' not in h
assert m.count('INCLUDE "data/maps/map_header_pointers.asm"')==1
assert 'SECTION "Map Header Pointer Table", ROMX\nINCLUDE "data/maps/map_header_pointers.asm"' in m
assert re.search(r'ROMX \$2D(?:.|\n)*?\t"Map Header Pointer Table"',l)
assert t.count('\tdw ')==248, ('number of map-header entries changed', t.count('\tdw '))
assert 'table_width 2, MapHeaderPointers' in t and 'assert_table_length NUM_MAPS' in t
assert re.findall(r'\bMapHeaderPointers\b',w)==['MapHeaderPointers', 'MapHeaderPointers']
start=w.index('.readROMMapHeader\n'); end=w.index('; copy the first 10 bytes',start)
part=w[start:end]
expected='''\tldh a, [hLoadedROMBank]
\tpush af
\tld a, BANK(MapHeaderPointers)
\tldh [hLoadedROMBank], a
\tld [MBC1RomBank], a
\tld a, [hli]
\tld h, [hl]
\tld l, a ; hl = base of map header in the original map bank
\tpop de ; saved bank in D; DE is reset by the header-copy loop below
\tld a, d
\tldh [hLoadedROMBank], a
\tld [MBC1RomBank], a'''
assert expected in part
assert part.index('ld a, BANK(MapHeaderPointers)') < part.index('ld a, [hli]') < part.index('\tpop de')
assert w.index('call SwitchToMapRomBank',w.index('LoadMapHeader::'))<start
assert '\tld de, wCurMapTileset' in w[end:end+220], 'caller DE must be overwritten after restoring bank'
assert 'db "ROM-1.21@"' in read('src/data/game_version.asm')
assert 'hlcoord 11, 0 ; ROM-1.21' in read('src/engine/menus/main_menu.asm')
print('PASS ROM-1.20D: 248 original 16-bit pointers in $2D; lookup restores map bank before dereference (static only)')
