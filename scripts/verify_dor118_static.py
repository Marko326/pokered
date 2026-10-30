#!/usr/bin/env python3
"""DOR-1.18 source structure checks only; not RGBDS, emulator or hardware validation."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
get=lambda p:(root/p).read_text(encoding="utf-8")
code=get("src/home/overworld.asm")
door=code.split("PlayMapChangeSound::",1)[1].split("CheckIfInOutsideMap::",1)[0]
mapload=code.split("LoadMapData::",1)[1].split("SwitchToMapRomBank::",1)[0]
assert "ldh a, [hCGB]\n\tand a\n\tjp nz, GBFadeOutToBlack" in door
assert "jp GBDoorFadeOutToBlackVBlank" in door
assert mapload.index("call LoadPlayerSpriteGraphics") < mapload.index(".restoreRomBank\n\t; DMG: release")
assert ".keepDMGMapGuard" in mapload
fade=get("src/home/fade.asm")
assert "ld c, 8" in fade.split("GBDoorFadeOutToBlackVBlank::",1)[1].split("GBFadeOutToBlack::",1)[0]
assert any(x in get("src/data/game_version.asm") for x in ("DOR-1.18@", "DOR-1.19@", "FLH-1.20@"))
assert any(x in get("src/engine/menus/main_menu.asm") for x in ("hlcoord 11, 0 ; DOR-1.18", "hlcoord 11, 0 ; DOR-1.19", "hlcoord 11, 0 ; FLH-1.20"))
assert "wDoorFadePending:: db\nwDoorFadeBGP:: db\nwDoorFadeOBP0:: db\nwDoorFadeOBP1:: db\nwDoorFadeRestore:: db\nds 19" in get("src/ram/wram.asm")
print("PASS DOR-1.18: DMG-only VBlank fade, delayed DMG map guard, 4x8-frame fade, version alignment")
