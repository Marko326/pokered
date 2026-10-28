#!/usr/bin/env python3
"""Source-level guards for the QOL-1.15D regressions; not an emulator test."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
start = (root / "src/home/start_menu.asm").read_text()
window = (root / "src/home/window.asm").read_text()
joypad = (root / "src/home/joypad2.asm").read_text()

submenus = start.split(".displayMenuItem", 1)[1].split("; EXIT falls through", 1)[0]
assert submenus.index("push af") < submenus.index("call SaveScreenTilesToBuffer2")
assert submenus.index("\n\txor a\n") < submenus.index("\n\tpop af\n") < submenus.index("\n\tcp 0\n")
for index, label in enumerate(("StartMenu_Pokedex", "StartMenu_Pokemon", "StartMenu_Item",
                              "StartMenu_TrainerInfo", "StartMenu_SaveReset", "StartMenu_Option")):
    assert f"cp {index}\n\tjp z, {label}" in submenus, (index, label)

menu_init = window.split("\n.loop1\n", 1)[1].split("\n.loop2\n", 1)[0]
assert menu_init.index("call PlaceMenuCursor") < menu_init.index("call StartMenuInputDelay3")
assert "jr nz, .loop2" not in menu_init, "Pending START must never skip visibility wait"
assert "call Delay3" in menu_init, "Non-START menus retain their existing settling delay"
assert "ld a, [wStartMenuClosePending]" in window.split("\n.loop2\n", 1)[1]
assert "ld a, START" in window and "ldh [hJoy5], a" in window

# Queue capacity is exactly one Boolean slot, set only on an independent START edge.
capture = joypad.split("CaptureStartMenuInput::", 1)[1].split("StartMenuInputDelay3::", 1)[0]
assert "ldh a, [hJoyPressed]" in capture and "bit BIT_START, a" in capture
assert "ld a, 1\n\tld [wStartMenuClosePending], a" in capture
assert "inc [wStartMenuClosePending]" not in capture
assert "ld c, 3" in joypad.split("StartMenuInputDelay3::", 1)[1]

print("PASS: six-way menu dispatch preserves A; visible 3-frame delay precedes queued START; single-edge Boolean queue")
