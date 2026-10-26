#!/usr/bin/env python3
"""Prepare the CHS_Mod build tree without modifying tracked sources.

All game code, translations, and assets live in src/. Generated code and
RGBDS outputs live in buildRB/. This script is called automatically by make.
"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "src"
BUILD = ROOT / "buildRB"
STATE = ".chs-build-state.json"
VERSION = "CHS_Mod-python-import-v1"

# These are precisely the importer commands used in the upstream
# _prepare.command when option=1 (official RGBDS, not rgbds-cn).
COMMANDS = [
    ["tools/_importText.py", f"xlsx/{name}.xlsx", "5", "RB", "1"]
    for name in (
        "outdoor", "dex", "buildingsA", "buildingsB", "indoor", "routes", "core"
    )
] + [
    ["tools/_importDexEntry.py", "xlsx/dexEntry.xlsx", "13", "1", "1", "RB"],
    ["tools/_importTextData.py", "xlsx/data.xlsx", "1", "RB", "1"],
]

IGNORED_DIRS = {"__pycache__", "tmp"}
IGNORED_SUFFIXES = {".pyc", ".o", ".gbc", ".gb", ".map", ".sym", ".patch"}


def ignore_source(directory: str, names: list[str]) -> set[str]:
    """Do not copy temporary Python/cache/compiler outputs from src/."""
    folder = Path(directory)
    omitted: set[str] = set()
    for name in names:
        path = folder / name
        if path.is_dir() and name in IGNORED_DIRS:
            omitted.add(name)
        elif path.is_file():
            if path.suffix in IGNORED_SUFFIXES:
                omitted.add(name)
            elif folder == SOURCE / "tools" and name in {
                "scan_includes", "make_patch", "pkmncompress", "gfx"
            }:
                omitted.add(name)
    return omitted


def input_files() -> list[Path]:
    paths: list[Path] = []
    for directory, subdirs, names in os.walk(SOURCE):
        subdirs[:] = sorted(d for d in subdirs if d not in IGNORED_DIRS)
        excluded = ignore_source(directory, names)
        for name in sorted(names):
            path = Path(directory) / name
            if name not in excluded and path.is_file():
                paths.append(path)
    return [ROOT / "Makefile", Path(__file__).resolve(), *paths]


def fingerprint() -> str:
    sha = hashlib.sha256(VERSION.encode("utf-8"))
    for path in input_files():
        rel = path.relative_to(ROOT).as_posix().encode("utf-8")
        sha.update(len(rel).to_bytes(4, "big"))
        sha.update(rel)
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(128 * 1024), b""):
                sha.update(chunk)
    return sha.hexdigest()


def main() -> None:
    if not (SOURCE / "Makefile").is_file():
        sys.exit("Missing src/Makefile; this patch targets the CHS_Mod branch.")

    digest = fingerprint()
    state = BUILD / STATE
    if state.is_file() and (BUILD / "Makefile").is_file():
        try:
            previous = json.loads(state.read_text(encoding="utf-8"))
            if previous.get("fingerprint") == digest:
                print("[CHS] Sources unchanged; reusing buildRB/.", flush=True)
                return
        except (ValueError, OSError):
            pass

    try:
        import openpyxl  # noqa: F401 - importer runtime dependency
    except ImportError:
        sys.exit("openpyxl is missing. Install it with: python3 -m pip install openpyxl")

    print("[CHS] Generating translated sources in buildRB/ ...", flush=True)
    with tempfile.TemporaryDirectory(prefix=".chs-build-stage-", dir=ROOT) as temp:
        temp_path = Path(temp)
        stage = temp_path / "work"
        shutil.copytree(SOURCE, stage, ignore=ignore_source)

        for arguments in COMMANDS:
            subprocess.run([sys.executable, *arguments], cwd=stage, check=True)

        (stage / STATE).write_text(
            json.dumps({"fingerprint": digest, "version": VERSION}, indent=2) + "\n",
            encoding="utf-8",
        )

        # The old working tree remains intact if an importer fails. Replace
        # it only after all translated files have been produced successfully.
        old = temp_path / "previous"
        if BUILD.exists():
            BUILD.rename(old)
        try:
            stage.rename(BUILD)
        except OSError:
            if old.exists():
                old.rename(BUILD)
            raise
    print("[CHS] Translation import complete.", flush=True)


if __name__ == "__main__":
    main()
