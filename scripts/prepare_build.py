#!/usr/bin/env python3
"""Keep the translated CHS build tree in sync without discarding RGBDS objects.

src/ is authoritative; buildRB/ contains translated sources plus build outputs.
Ordinary source changes are copied individually. Changes to translation inputs
are imported in a temporary tree, then *only differing files* are synchronized.
"""

from __future__ import annotations

import hashlib
import json
import os
import stat
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "src"
BUILD = ROOT / "buildRB"
STATE = ".chs-build-state.json"
VERSION = "CHS_Mod-incremental-v2"

# Keep this in step with the official-RGBDS option of _prepare.command.
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
    """Exclude generated files from both source and staging manifests."""
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


def files_under(folder: Path) -> dict[str, Path]:
    found: dict[str, Path] = {}
    for directory, subdirs, names in os.walk(folder):
        subdirs[:] = sorted(d for d in subdirs if d not in IGNORED_DIRS)
        omitted = ignore_source(directory, names) if folder == SOURCE else set()
        for name in sorted(names):
            path = Path(directory) / name
            if name not in omitted and path.is_file():
                rel = path.relative_to(folder).as_posix()
                if rel != STATE and path.suffix not in IGNORED_SUFFIXES:
                    found[rel] = path
    return found


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(128 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def source_manifest() -> dict[str, str]:
    return {rel: f"{sha256(path)}:{stat.S_IMODE(path.stat().st_mode):o}"
            for rel, path in files_under(SOURCE).items()}


def affects_translations(rel: str) -> bool:
    """Inputs to the Excel text/dex importers (including their Python helpers)."""
    return (
        rel.startswith("xlsx/")
        or rel.startswith("tools/") and rel.endswith(".py")
        or rel == "charmap.txt"
        or rel.startswith("__exporterList/")
    )


def load_state() -> dict:
    try:
        return json.loads((BUILD / STATE).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def same_bytes(left: Path, right: Path) -> bool:
    return left.is_file() and right.is_file() and sha256(left) == sha256(right)


def update_file(source: Path, dest: Path) -> bool:
    """Never touch an unchanged file: its timestamp is make's dependency cache."""
    if same_bytes(source, dest):
        # A chmod-only patch must not invalidate an assembled object.
        mode = stat.S_IMODE(source.stat().st_mode)
        if stat.S_IMODE(dest.stat().st_mode) != mode:
            dest.chmod(mode)
            return True
        return False
    dest.parent.mkdir(parents=True, exist_ok=True)
    # Keep file replacement atomic, including when an existing object uses it.
    with tempfile.NamedTemporaryFile(dir=dest.parent, prefix=".chs-sync-", delete=False) as temp:
        temp_path = Path(temp.name)
    try:
        shutil.copyfile(source, temp_path)
        shutil.copymode(source, temp_path)
        # Don't preserve a timestamp from a git checkout/ZIP older than .o:
        # changed inputs must be newer than previous compiled objects.
        os.utime(temp_path, None)
        os.replace(temp_path, dest)
    finally:
        temp_path.unlink(missing_ok=True)
    return True


def write_state(manifest: dict[str, str], translated: set[str]) -> None:
    data = {
        "version": VERSION,
        "preparer": sha256(Path(__file__)),
        "sources": manifest,
        "translated": sorted(translated),
    }
    # State is committed last. If interrupted, retrying replays the sync.
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=BUILD,
                                     prefix=".chs-state-", delete=False) as temp:
        temp_path = Path(temp.name)
        json.dump(data, temp, ensure_ascii=False, separators=(",", ":"))
        temp.write("\n")
    os.replace(temp_path, BUILD / STATE)


def translated_paths(stage: Path, manifest: dict[str, str]) -> set[str]:
    """Record importer-owned outputs, including files rewritten identically."""
    changed: set[str] = set()
    for rel, path in files_under(stage).items():
        source = SOURCE / rel
        if rel not in manifest or (
            path.stat().st_mtime_ns != source.stat().st_mtime_ns
            or sha256(path) != manifest[rel].split(":", 1)[0]
        ):
            changed.add(rel)
    return changed


def sync_stage(stage: Path, previous: dict, manifest: dict[str, str]) -> tuple[int, int, set[str]]:
    staged = files_under(stage)
    previous_paths = set(previous.get("sources", {})) | set(previous.get("translated", []))
    # First run or migration from a v1 fingerprint: no tracked path list; keep
    # existing compiled files and import only managed source files.
    removed = previous_paths - set(staged)
    for rel in sorted(removed):
        (BUILD / rel).unlink(missing_ok=True)
    count = sum(update_file(path, BUILD / rel) for rel, path in staged.items())
    return count, len(removed), translated_paths(stage, manifest)


def prepare_translations(previous: dict, manifest: dict[str, str]) -> None:
    try:
        import openpyxl  # noqa: F401
    except ImportError:
        sys.exit("openpyxl is missing. Install it with: python3 -m pip install openpyxl")

    print("[CHS] Importing translation sources (preserving compiled objects) ...", flush=True)
    with tempfile.TemporaryDirectory(prefix=".chs-build-stage-", dir=ROOT) as tmp:
        stage = Path(tmp) / "work"
        shutil.copytree(SOURCE, stage, ignore=ignore_source)
        for command in COMMANDS:
            subprocess.run([sys.executable, *command], cwd=stage, check=True,
                           stdout=subprocess.DEVNULL)
        # No mutation of the real tree happens until every importer succeeds.
        BUILD.mkdir(exist_ok=True)
        updated, removed, translated = sync_stage(stage, previous, manifest)
        write_state(manifest, translated)
    print(f"[CHS] Import finished: {updated} files updated, {removed} removed; .o kept.", flush=True)


def sync_sources(previous: dict, manifest: dict[str, str]) -> None:
    before = previous["sources"]
    changed = {rel for rel in manifest if manifest[rel] != before.get(rel)}
    deleted = set(before) - set(manifest)
    for rel in sorted(deleted):
        (BUILD / rel).unlink(missing_ok=True)
    updated = sum(update_file(SOURCE / rel, BUILD / rel) for rel in sorted(changed))
    write_state(manifest, set(previous["translated"]))
    print(f"[CHS] Incremental sync: {updated} files updated, {len(deleted)} removed; .o kept.",
          flush=True)


def main() -> None:
    if not (SOURCE / "Makefile").is_file():
        sys.exit("Missing src/Makefile; this patch targets the CHS_Mod branch.")

    manifest = source_manifest()
    previous = load_state()
    ready = ((BUILD / "Makefile").is_file()
             and previous.get("version") == VERSION
             and previous.get("preparer") == sha256(Path(__file__))
             and isinstance(previous.get("sources"), dict)
             and isinstance(previous.get("translated"), list))
    if ready and manifest == previous["sources"]:
        print("[CHS] Sources unchanged; reusing existing objects.", flush=True)
        return

    if ready:
        changed = {rel for rel in set(manifest) | set(previous["sources"])
                   if manifest.get(rel) != previous["sources"].get(rel)}
        if not any(affects_translations(rel) or rel in previous["translated"]
                   for rel in changed):
            sync_sources(previous, manifest)
            return

    # Initial preparation, importer input changes, or a patch to an importer-
    # owned ASM file. The generated tree is merged, never replaced wholesale.
    prepare_translations(previous, manifest)


if __name__ == "__main__":
    main()
