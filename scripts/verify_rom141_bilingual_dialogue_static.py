#!/usr/bin/env python3
"""Static acceptance gate for the ROM-1.41 map-dialogue bilingual pipeline.

Run after `python scripts/prepare_build.py`. This verifier checks source wiring,
re-generates into a temporary directory, compares deterministic build outputs,
and resolves every CHS/English pointer. It does not invoke RGBDS or link a ROM.
"""
from __future__ import annotations

import re
import sys
import tempfile
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


def asm_labels(paths: list[Path]) -> set[str]:
    labels: set[str] = set()
    for path in paths:
        try:
            content = read(path)
        except UnicodeDecodeError:
            continue
        labels.update(re.findall(r"(?m)^([A-Za-z_][A-Za-z_0-9.]*)::?\s*$", content))
    return labels


def main() -> None:
    version = read(SRC / "data" / "game_version.asm")
    require('db "ROM-1.41@"' in version, "game version is not ROM-1.41")

    macros = read(SRC / "macros" / "scripts" / "text.asm")
    require("const TX_BILINGUAL ; $18" in macros, "TX_BILINGUAL opcode is not $18")
    require("MACRO text_bilingual" in macros, "text_bilingual macro is missing")
    require("dab \\1 ; CHS far pointer" in macros, "CHS far pointer is missing")
    require("dab \\2 ; English far pointer" in macros, "English far pointer is missing")

    home = read(SRC / "home" / "text.asm")
    require(home.index("cp TX_BILINGUAL") < home.index("cp TX_SOUND_POKEDEX_RATING"),
            "TX_BILINGUAL must be dispatched before the generic sound-command range")
    handler = home[home.index("TextCommand_BILINGUAL::"):home.index("TextCommand_FAR_ReadPointer::")]
    require("ld a, [wOptions]" in handler and "bit 5, a" in handler,
            "bilingual handler does not select using LANGUAGE bit 5")
    require(
        re.search(r"(?s)\.english.*?inc hl\s+inc hl\s+inc hl\s+jr TextCommand_FAR_ReadPointer", handler),
        "English branch must skip the three-byte CHS pointer",
    )
    require(
        re.search(
            r"(?s)ld a, \[hli\]\s+ld e, a\s+ld a, \[hli\]\s+ld d, a"
            r"\s+ld a, \[hli\]\s+inc hl\s+inc hl\s+inc hl"
            r"\s+jr TextCommand_FAR_Load",
            handler,
        ),
        "Chinese branch must skip the three-byte English pointer after reading CHS",
    )
    far_handler = home[home.index("TextCommand_FAR_ReadPointer::"):home.index("TextCommandJumpTable::")]
    require("call TextCommandProcessor" in far_handler, "shared far-text processor path is missing")
    require("ld [MBC1RomBank], a" in far_handler, "shared far-text bank switch is missing")

    main_asm = read(SRC / "main.asm")
    require('INCLUDE "data/english_text/generated_dialogue.asm"' in main_asm,
            "generated English dialogue include is missing from main.asm")
    preparer = read(ROOT / "scripts" / "prepare_build.py")
    require("run_dialogue_generator(stage)" in preparer,
            "full import stage does not generate bilingual dialogue")
    require("run_dialogue_generator(BUILD)" in preparer,
            "incremental sync does not regenerate bilingual dialogue")

    require(BUILD.is_dir(), "buildRB is missing; run python scripts/prepare_build.py first")
    with tempfile.TemporaryDirectory(prefix="rom141c-static-") as temp:
        summary = generator.generate(SRC, Path(temp))
        expected_data = Path(temp) / "data" / "english_text" / "generated_dialogue.asm"
        actual_data = BUILD / "data" / "english_text" / "generated_dialogue.asm"
        require(actual_data.is_file(), "buildRB generated English dialogue data is missing")
        require(actual_data.read_bytes() == expected_data.read_bytes(),
                "buildRB English dialogue data differs from deterministic generator output")

        expected_refs = []
        for rel in summary["generated_files"]:
            if not rel.startswith("scripts/"):
                continue
            expected = Path(temp) / rel
            actual = BUILD / rel
            require(actual.is_file(), f"buildRB script is missing: {rel}")
            require(actual.read_bytes() == expected.read_bytes(),
                    f"buildRB script differs from generator output: {rel}")

    english_data = read(BUILD / "data" / "english_text" / "generated_dialogue.asm")
    english_labels = set(re.findall(
        r"(?m)^([A-Za-z_][A-Za-z_0-9.]*_EN)::\s*$", english_data
    ))
    banks = [int(x, 16) for x in re.findall(
        r'(?m)^SECTION "English Dialogue \d+", ROMX, BANK\[\$(\w+)\]', english_data
    )]
    require(len(english_labels) == 1941, f"expected 1941 English labels, found {len(english_labels)}")
    require(len(banks) == 14 and banks == list(range(0x62, 0x70)),
            f"expected 14 fixed English ROMX banks $62-$6F, found {banks}")

    bilingual_refs: list[tuple[str, str, str]] = []
    for path in (BUILD / "scripts").rglob("*.asm"):
        for line in read(path).splitlines():
            match = re.match(
                r"^\s*text_bilingual\s+([A-Za-z_][A-Za-z_0-9.]*)\s*,\s*"
                r"([A-Za-z_][A-Za-z_0-9.]*)\s*(?:;.*)?$", line
            )
            if match:
                bilingual_refs.append((path.relative_to(BUILD).as_posix(), match.group(1), match.group(2)))
    require(len(bilingual_refs) == summary["routed_refs"] == 1942,
            f"expected 1942 bilingual refs, found {len(bilingual_refs)}")

    chs_paths = list((BUILD / "text").rglob("*.asm")) + list((BUILD / "data" / "text").rglob("*.asm"))
    chs_labels = asm_labels(chs_paths)
    missing_english = [row for row in bilingual_refs if row[2] not in english_labels]
    missing_chs = [row for row in bilingual_refs if row[1] not in chs_labels]
    require(not missing_english, f"missing English targets: {missing_english[:5]}")
    require(not missing_chs, f"missing CHS targets: {missing_chs[:5]}")
    require(summary["unclassified_script_refs"] == 0, "unclassified script text_far references remain")
    require(summary["unrouted_script_refs"] == 0, "eligible map text_far references remain unrouted")
    require(summary["unsafe_token_labels_in_map_scope"] == 0,
            "unknown special-token text remains in map-dialogue scope")
    require(len(summary["line_reflow_labels"]) == 3,
            "the three reviewed line-width reflows have changed")
    require(summary["checked_text_lines"] == 6818 and summary["max_text_line_width"] == 18,
            "static line-width audit count or maximum width has changed")

    print("PASS: ROM-1.41 version, opcode, runtime dispatch, and build-pipeline wiring")
    print("PASS: deterministic buildRB generation matches temporary regeneration")
    print("PASS: 1,942 bilingual refs resolve to 1,941 English labels and all CHS targets")
    print("PASS: 14 English ROMX sections occupy fixed banks $62-$6F")
    print("PASS: no unclassified, unrouted, or unknown-token map dialogue remains")
    print("PASS: 6,818 text lines checked; maximum visible width 18/18; three line-break-only reflows")
    print("NOTE: static checks only; no RGBDS build, ROM/MAP/SHA generation, or phone test")


if __name__ == "__main__":
    main()
