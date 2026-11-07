#!/usr/bin/env python3
"""Static acceptance gate for ROM-1.42 Pokedex rating bilingual text.

Run after `python3 scripts/prepare_build.py`. This checks all 19 source labels,
the bilingual wrappers, dynamic counters, Hall of Fame buffer-copy semantics,
deterministic generation, and the fixed high ROMX bank. It does not invoke
RGBDS, link a ROM, or certify phone/emulator acceptance.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
BUILD = ROOT / "buildRB"
sys.path.insert(0, str(ROOT / "scripts"))
import generate_bilingual_dialogue as generator  # noqa: E402


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


EXPECTED_THRESHOLDS = [
    (10, "DexRatingText_Own0To9"),
    (20, "DexRatingText_Own10To19"),
    (30, "DexRatingText_Own20To29"),
    (40, "DexRatingText_Own30To39"),
    (50, "DexRatingText_Own40To49"),
    (60, "DexRatingText_Own50To59"),
    (70, "DexRatingText_Own60To69"),
    (80, "DexRatingText_Own70To79"),
    (90, "DexRatingText_Own80To89"),
    (100, "DexRatingText_Own90To99"),
    (110, "DexRatingText_Own100To109"),
    (120, "DexRatingText_Own110To119"),
    (130, "DexRatingText_Own120To129"),
    (140, "DexRatingText_Own130To139"),
    (150, "DexRatingText_Own140To149"),
    ("NUM_POKEMON + 1", "DexRatingText_Own150To151"),
]


def verify_threshold_table(rating_source: str) -> None:
    actual = re.findall(
        r"(?m)^\s*dbw\s+([^,]+),\s*(DexRatingText_Own[A-Za-z0-9]+)\s*$",
        rating_source,
    )
    normalized = [(value.strip(), label) for value, label in actual]
    expected = [(str(value), label) for value, label in EXPECTED_THRESHOLDS]
    require(
        normalized == expected,
        "Pokedex ownership threshold table or branch order changed",
    )


def verify_wrapper(source: str, label: str, error_prefix: str) -> None:
    wrapper_name = label[1:] if label.startswith("_") else label
    block = re.search(
        rf"(?ms)^{re.escape(wrapper_name)}:\s*\n"
        rf"\s*text_bilingual\s+{re.escape(label)},\s*{re.escape(label)}_EN\s*\n"
        rf"\s*text_end\b",
        source,
    )
    require(block is not None, f"{error_prefix}: {label}")


def main() -> None:
    version = read(SRC / "data" / "game_version.asm")
    require('db "ROM-1.42@"' in version, "game version is not ROM-1.42")

    main_asm = read(SRC / "main.asm")
    require(
        'INCLUDE "data/english_text/generated_pokedex_ratings.asm"' in main_asm,
        "generated Pokedex English include is missing from main.asm",
    )

    options = read(SRC / "engine" / "menus" / "options_bilingual.asm")
    require(
        "hlcoord 11, 0 ; ROM-1.42 is 8 characters" in options,
        "8-character ROM-1.42 version display is not right-aligned at x=11",
    )

    rating_source = read(SRC / "engine" / "events" / "pokedex_rating.asm")
    hof_source = read(SRC / "engine" / "movie" / "hall_of_fame.asm")
    for label in generator.POKEDEX_RATING_LABELS[:17]:
        verify_wrapper(rating_source, label, "missing bilingual engine wrapper")
    for label in ("_DexSeenOwnedText", "_DexRatingText"):
        verify_wrapper(hof_source, label, "missing bilingual Hall of Fame wrapper")

    verify_threshold_table(rating_source)

    # The Hall of Fame copies the selected wrapper until TX_END into a 180-byte
    # WRAM union. TX_BILINGUAL is 1 opcode + 6 pointer bytes + TX_END = 8 bytes.
    require(
        'cp CHARVAL("@")' in rating_source,
        "Hall of Fame wrapper copy no longer stops at the text terminator",
    )
    require(
        re.search(
            r"(?s)ld de, wDexRatingNumMonsSeen.*?inc de.*?"
            r"inc de ; de now points to wDexRatingText.*?\.copyRatingTextLoop",
            rating_source,
        ),
        "Hall of Fame rating wrapper is no longer copied after the two live counters",
    )
    wram = read(SRC / "ram" / "wram.asm")
    require(
        "UNION\nwVermilionDockTileMapBuffer:: ds 5 * BG_MAP_WIDTH + SCREEN_WIDTH" in wram,
        "expected 180-byte WRAM union was changed",
    )
    require("wDexRatingText:: db" in wram, "Hall of Fame rating scratch buffer is missing")
    macros = read(SRC / "macros" / "scripts" / "text.asm")
    require(
        "const TX_BILINGUAL ; $18" in macros and "const TX_END ; $50" in macros,
        "bilingual opcode or text terminator constants changed",
    )
    require(
        generator.LAST_ENGLISH_BANK + 1 == generator.POKEDEX_RATING_BANK,
        "map-dialogue bank reservation overlaps the Pokedex rating bank",
    )

    require(BUILD.is_dir(), "buildRB is missing; run python3 scripts/prepare_build.py first")
    expected, summary = generator.generated_pokedex_rating_data(
        *generator.load_english_index(SRC)
    )
    actual_path = BUILD / "data" / "english_text" / "generated_pokedex_ratings.asm"
    require(actual_path.is_file(), "generated Pokedex English data is missing")
    require(
        actual_path.read_text(encoding="utf-8") == expected,
        "buildRB Pokedex English data differs from deterministic generation",
    )

    data = read(actual_path)
    labels = re.findall(r"(?m)^([A-Za-z_][A-Za-z_0-9.]*_EN)::\s*$", data)
    require(len(labels) == 19, f"expected 19 English labels, found {len(labels)}")
    require(
        set(labels) == {f"{label}_EN" for label in generator.POKEDEX_RATING_LABELS},
        "generated Pokedex English label set differs from the reviewed list",
    )
    require(
        'SECTION "English Pokedex Ratings", ROMX, BANK[$70]' in data,
        "Pokedex English data is not isolated in ROMX bank $70",
    )
    quoted = re.findall(r'"(?:\\.|[^"\\])*"', data)
    require(
        not any("#" in literal for literal in quoted),
        "English Pokedex literals still contain # and may call the CHS PlacePOKe expansion",
    )
    for required in (
        "text_decimal hDexRatingNumMonsSeen, 1, 3",
        "text_decimal hDexRatingNumMonsOwned, 1, 3",
        "text_decimal wDexRatingNumMonsSeen, 1, 3",
        "text_decimal wDexRatingNumMonsOwned, 1, 3",
    ):
        require(required in data, f"live counter command was lost: {required}")

    print("PASS: ROM-1.42 Pokedex rating and Hall of Fame wrappers use text_bilingual")
    print("PASS: all 16 ownership thresholds and original branch order are unchanged")
    print("PASS: 19 original English labels generated deterministically in ROMX $70")
    print("PASS: live seen/owned counters remain text_decimal commands")
    print("PASS: #MON/#DEX expansions are literal POKé text in English copies")
    print("PASS: Hall of Fame can copy the 8-byte bilingual wrapper into the existing WRAM union")
    print("PASS: map-dialogue banks $62-$6F and Pokedex bank $70 cannot overlap")
    print(
        f"PASS: {summary['checked_lines']} English lines checked; "
        f"maximum visible width including 3-digit dynamic counters "
        f"{summary['max_dynamic_line_width']}/18; "
        f"{summary['special_replacements']} # expansions normalized"
    )
    print("NOTE: static checks only; no RGBDS build, ROM/MAP/SHA generation, or phone test")


if __name__ == "__main__":
    main()
