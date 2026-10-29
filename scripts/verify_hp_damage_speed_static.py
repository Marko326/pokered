#!/usr/bin/env python3
"""Static contract & integer-boundary checks for CHS QOL-1.17.

This is NOT an assembler, emulator or runtime test. It does not certify RGBDS
bank placement or tile-display timing. Run make red/blue with RGBDS 1.0.4 and
perform the scoped gameplay checks before treating runtime behavior as verified.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ENGINE = (ROOT / "src/engine/battle/damage_hp_animation.asm").read_text()
CORE = (ROOT / "src/engine/battle/core.asm").read_text()
HPBAR = (ROOT / "src/engine/gfx/hp_bar.asm").read_text()
VCOPY = (ROOT / "src/home/vcopy.asm").read_text()
MAIN = (ROOT / "src/main.asm").read_text()
LINK = (ROOT / "src/layout.link").read_text()
RAM = (ROOT / "src/ram/wram.asm").read_text()
NAMES = (ROOT / "src/home/names.asm").read_text()


def check(label: str, value: bool) -> None:
    if not value:
        raise AssertionError(f"FAIL: {label}")
    print(f"PASS: {label}")


check("opposing damage hook used at exactly two real-HP subtractors", CORE.count("callfar UpdateAttackDamageHPBar") == 2)
check("original generic HP engine retained", "UpdateHPBar:\nUpdateHPBar2:" in HPBAR)
check("original short HP engine retained", "UpdateShortHPBar:" in HPBAR)
check("damage wrapper has turn/HUD self-damage guard", "ldh a, [hWhoseTurn]" in ENGINE and "cp b\n\tjr nz, .original" in ENGINE)
check("small damage and self-hits use original predef", "predef UpdateHPBar2" in ENGINE)
check("new code in helper Bank $2D", '"Battle Damage HP Animation"' in MAIN and 'ROMX $2D' in LINK and '"Battle Damage HP Animation"' in LINK.split('ROMX $2D', 1)[1].split('ROMX $3C', 1)[0])
check("HP scratch bytes replace existing two reserved bytes", "wHPBarTempHP:: dw\n" in RAM and "wHPBarDamageSpeed:: db\nwHPBarDamagePhase:: db\n\tds 9\nwHPBarHPDifference:: dw" in RAM)
check("accelerated path uses direct tile-only VBlank transfers", "ld b, 2" in ENGINE and "ld b, 1" in ENGINE and "ldh [hVBlankCopyBGNumRows], a" in ENGINE)
check("CHS existing VBlank BG path does not copy CGB attributes", "jr TransferBgRows" in VCOPY and "bit 7, b" not in VCOPY)
check("CGB/SGB HP palette handling not replaced by RPP regional palette code", "call GetHealthBarColor" in ENGINE and "call RunPaletteCommand" in ENGINE and "rSVBK" not in ENGINE)
check("player HP number uses CHS display offset", "ld de, $15" in ENGINE and "call PrintNumber" in ENGINE)
check("final faint redraw clears sliver", ".fainted\n\tld e, 0\n\tld c, 0" in ENGINE)
check("BG transfer state restored after accelerated animation", "push af\n\txor a\n\tldh [hAutoBGTransferEnabled], a" in ENGINE and "pop af\n\tldh [hAutoBGTransferEnabled], a" in ENGINE)
check("CHS name mode implementation not touched", "wENGNameMark" in NAMES)
check("bilanguage naming rule recorded but not implemented", (ROOT / "docs/NAME_LANGUAGE_COMPATIBILITY.md").exists())


def asm_tier(damage, maximum):
    """Model the four threshold comparisons in the port, not runtime ASM."""
    two = (2 * damage) & 0xFFFF
    four = (2 * two) & 0xFFFF
    if four < maximum: return 0
    if two < maximum: return 1
    if four < 3 * maximum: return 2
    return 3


def direct_ratio_tier(damage, maximum):
    if 4 * damage < maximum: return 0
    if 2 * damage < maximum: return 1
    if 4 * damage < 3 * maximum: return 2
    return 3

# Gen I max-HP range; check all integer boundaries up to 714 HP.
for max_hp in range(1, 715):
    for damage in range(max_hp + 1):
        actual = asm_tier(damage, max_hp)
        expect = direct_ratio_tier(damage, max_hp)
        if actual != expect:
            raise AssertionError((max_hp, damage, actual, expect))
print("PASS: integer tier boundaries over 255,970 effective-damage cases")

for max_hp, damage, expected in ((100, 24, 0), (100, 25, 1), (100, 49, 1),
                                 (100, 50, 2), (100, 74, 2), (100, 75, 3),
                                 (100, 100, 3), (714, 0, 0), (714, 714, 3)):
    check(f"threshold {damage}/{max_hp}", asm_tier(damage, max_hp) == expected)

print("PASS: QOL-1.17 static contracts (does not certify ROM compilation/emulator rendering)")
