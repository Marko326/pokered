#!/usr/bin/env python3
"""Static acceptance gate for ROM-1.42 player-information bilingual labels.

Run after `python3 scripts/prepare_build.py`. Checks the three existing
Excel-imported UI files without changing the workbook or its CHS strings.
This does not invoke RGBDS or certify ROM/MAP/phone acceptance.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
BUILD = ROOT / "buildRB"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    version = read(SRC / "data" / "game_version.asm")
    require('db "ROM-1.42@"' in version, "game version is not ROM-1.42")

    main_source = read(SRC / "engine" / "menus" / "main_menu.asm")
    trainer_source = read(SRC / "engine" / "menus" / "start_sub_menus.asm")
    hof_source = read(SRC / "engine" / "movie" / "hall_of_fame.asm")

    require(main_source.count("call GetSaveScreenInfoText") == 2,
            "Continue and Save screens must share the language-aware label selector")
    require(
        "GetSaveScreenInfoText:\n"
        "\tld de, SaveScreenInfoText\n"
        "\tld a, [wOptions]\n"
        "\tbit 5, a\n"
        "\tret z\n"
        "\tld de, SaveScreenInfoTextEnglish\n"
        "\tret" in main_source,
        "Continue/Save selector must choose English only when LANGUAGE bit 5 is set",
    )
    require(
        'db   "PLAY","ER"\n'
        '\tnext "BAD","GES    "\n'
        '\tnext "POKé","DEX    "\n'
        '\tnext "TI","ME@"' in main_source,
        "English Continue/Save labels must remain split around Excel CHS replacement keys",
    )

    for label, english_label, branch_label in (
        ("TrainerInfo_BadgesText", "TrainerInfo_BadgesTextEnglish", ".badgesTextReady"),
        ("TrainerInfo_NameMoneyTimeText", "TrainerInfo_NameMoneyTimeTextEnglish", ".nameMoneyTimeTextReady"),
    ):
        require(
            f"ld de, {label}\n\tld a, [wOptions]\n\tbit 5, a\n"
            f"\tjr z, {branch_label}\n\tld de, {english_label}\n"
            f"{branch_label}\n\tcall PlaceString" in trainer_source,
            f"Trainer Card selector missing for {label}",
        )
    require(
        'db   "NA","ME/"\n'
        '\tnext "MO","NEY/"\n'
        '\tnext "TI","ME/@"' in trainer_source
        and 'db $76,"BAD","GES",$76,"@"' in trainer_source,
        "Trainer Card English labels must avoid the workbook's exact CHS keys",
    )

    for label, english_label, branch_label in (
        ("HoFPlayTimeText", "HoFPlayTimeTextEnglish", ".playTimeLabelReady"),
        ("HoFMoneyText", "HoFMoneyTextEnglish", ".moneyLabelReady"),
    ):
        require(
            f"ld de, {label}\n\tld a, [wOptions]\n\tbit 5, a\n"
            f"\tjr z, {branch_label}\n\tld de, {english_label}\n"
            f"{branch_label}\n\tcall PlaceString" in hof_source,
            f"Hall of Fame selector missing for {label}",
        )
    require('db "PLAY", " TIME@"' in hof_source and 'db "MON", "EY@"' in hof_source,
            "Hall of Fame English labels must avoid the workbook's exact CHS keys")

    # Dynamic values and the previously accepted Pokedex bilingual content are
    # intentionally untouched by this label-only pass.
    for token in (
        "call PrintNumBadges", "call PrintNumOwnedMons", "call PrintPlayTime",
        "ld de, wPlayerName", "ld de, wPlayerMoney", "ld de, wPlayTimeHours",
        "ld de, wPlayTimeMinutes",
    ):
        require(token in main_source + trainer_source + hof_source,
                f"dynamic player data path was removed: {token}")
    require("text_bilingual _DexSeenOwnedText, _DexSeenOwnedText_EN" in hof_source,
            "existing Hall of Fame Pokedex count wrapper was lost")
    require("text_bilingual _DexRatingText, _DexRatingText_EN" in hof_source,
            "existing Hall of Fame Pokedex rating wrapper was lost")

    require(BUILD.is_dir(), "buildRB is missing; run python3 scripts/prepare_build.py first")
    built = {
        "main": read(BUILD / "engine" / "menus" / "main_menu.asm"),
        "trainer": read(BUILD / "engine" / "menus" / "start_sub_menus.asm"),
        "hof": read(BUILD / "engine" / "movie" / "hall_of_fame.asm"),
    }
    expected_chs = {
        "main": (
            '; 主人公 from: "PLAYER"',
            '; 持有徽章     枚 from: "BADGES    "',
            '; #图鉴   只 from: "#DEX    "',
            '; 游戏时间@ from: "TIME@"',
        ),
        "trainer": (
            '; 主人公/ from: "NAME/"',
            '; 零花钱/ from: "MONEY/"',
            '; 游戏时间/@ from: "TIME/@"',
            '; ぁ#徽章ぁ@ from: $76,"BADGES",$76,"@"',
        ),
        "hof": (
            '; 游戏时间@ from: "PLAY TIME@"',
            '; 零花钱@ from: "MONEY@"',
        ),
    }
    for screen, markers in expected_chs.items():
        for marker in markers:
            require(marker in built[screen],
                    f"{screen} CHS workbook replacement missing from build: {marker}")

    for screen, marker in (
        ("main", 'SaveScreenInfoTextEnglish:\n\tdb   "PLAY","ER"'),
        ("trainer", 'TrainerInfo_NameMoneyTimeTextEnglish:\n\tdb   "NA","ME/"'),
        ("trainer", 'TrainerInfo_BadgesTextEnglish:\n\tdb $76,"BAD","GES",$76,"@"'),
        ("hof", 'HoFPlayTimeTextEnglish:\n\tdb "PLAY", " TIME@"'),
        ("hof", 'HoFMoneyTextEnglish:\n\tdb "MON", "EY@"'),
    ):
        require(marker in built[screen],
                f"{screen} English alternate was rewritten or lost during XLSX import")

    print("PASS: Continue and Save info select PLAYER/BADGES/POKéDEX/TIME by LANGUAGE bit 5")
    print("PASS: Trainer Card selects NAME/MONEY/TIME/BADGES without changing live values")
    print("PASS: Hall of Fame selects PLAY TIME/MONEY while preserving Pokedex bilingual text")
    print("PASS: existing data.xlsx still generates the Chinese labels in all three screens")
    print("PASS: split English strings survive the existing XLSX importer unchanged")
    print("NOTE: static/build-preparation checks only; no RGBDS build, ROM/MAP/SHA, or phone test")


if __name__ == "__main__":
    main()
