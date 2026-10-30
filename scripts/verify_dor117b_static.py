#!/usr/bin/env python3
"""DOR-1.17B source-structure checks; not a ROM build or gameplay test."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
read = lambda path: (root / path).read_text(encoding="utf-8")
map_src = read("src/home/overworld.asm")
map_loader = map_src.split("LoadMapData::", 1)[1].split("SwitchToMapRomBank::", 1)[0]
copy = read("src/home/copy.asm").split("CopyData::", 1)[1]
vblank = read("src/home/vblank.asm").split("VBlank::", 1)[1].split("DelayFrame::", 1)[0]
hram = read("src/ram/hram.asm")
assert "call DisableLCD" not in map_loader
assert "hMapLoadVRAMSafeFlag" in map_loader
assert "call z, EnableLCD" in map_loader
assert "call CopyData ; safe" in map_loader
assert "and %10" in copy and "[rSTAT]" in copy and "\tdi" in copy and "\tei" in copy
assert "cp $80" in copy and "cp $a0" in copy
assert "call VBlankCopy" in vblank and "call VBlankCopyDouble" in vblank
assert "hMapLoadVRAMSafeFlag:: db\nhCGBBGP:: db" in hram
assert ('DOR-1.17B@' in read("src/data/game_version.asm")
        or 'DOR-1.17C@' in read("src/data/game_version.asm")
        or 'DOR-1.17D@' in read("src/data/game_version.asm")
        or 'DOR-1.18@' in read("src/data/game_version.asm")
        or 'DOR-1.19@' in read("src/data/game_version.asm")
        or 'FLH-1.20@' in read("src/data/game_version.asm"))
assert ("hlcoord 10, 0 ; DOR-1.17B" in read("src/engine/menus/main_menu.asm")
        or "hlcoord 10, 0 ; DOR-1.17C" in read("src/engine/menus/main_menu.asm")
        or "hlcoord 10, 0 ; DOR-1.17D" in read("src/engine/menus/main_menu.asm")
        or "hlcoord 11, 0 ; DOR-1.18" in read("src/engine/menus/main_menu.asm")
        or "hlcoord 11, 0 ; DOR-1.19" in read("src/engine/menus/main_menu.asm")
        or "hlcoord 11, 0 ; FLH-1.20" in read("src/engine/menus/main_menu.asm"))
print("PASS: DOR-1.17B structure, LCD-on map copy, VBlank queues, HRAM layout, version")
