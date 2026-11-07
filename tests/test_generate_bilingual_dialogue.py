import importlib.util
import json
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "generate_bilingual_dialogue.py"
SPEC = importlib.util.spec_from_file_location("generate_bilingual_dialogue", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class BilingualDialogueGeneratorTests(unittest.TestCase):
    def make_tree(self, root: Path) -> tuple[Path, Path]:
        source = root / "src"
        build = root / "buildRB"
        (source / "text").mkdir(parents=True)
        (source / "scripts").mkdir(parents=True)
        (source / "data" / "text").mkdir(parents=True)
        (source / "data" / "english_text").mkdir(parents=True)
        (build / "scripts").mkdir(parents=True)
        (source / "_G1RB.json").write_text(json.dumps([
            {"Sentence": {"tag": "_HelloText::\ncore.xlsx"}},
            {"Sentence": {"tag": "_DataText::\ncore.xlsx"}},
            {"Sentence": {"tag": "PlainText::\ncore.xlsx"}},
            {"Sentence": {"tag": "_UnsafeText::\ncore.xlsx"}},
            {"Sentence": {"tag": "_MissingText::\ncore.xlsx"}},
        ]), encoding="utf-8")
        (source / "text" / "Test.asm").write_text(
            '_HelloText::\n'
            '\ttext "Welcome, #MON!"\n'
            '\tline "<PLAYER>: #MON"\n'
            '\ttext_ram wPlayerName\n'
            '\tdone\n'
            'PlainText::\n'
            '\ttext "#MON is neat."\n'
            '\tdone\n'
            '_UnsafeText::\n'
            '\ttext "A <PKMN> token."\n'
            '\tdone\n',
            encoding="utf-8",
        )
        (source / "data" / "text" / "text_1.asm").write_text(
            '_DataText::\n'
            '\ttext "# BALL ready<COLON>"\n'
            '\tdone\n',
            encoding="utf-8",
        )
        rating_source = [
            '_DexCompletionText::',
            '\ttext "DEX completion"',
            '\tpara "Seen:@"',
            '\ttext_decimal hDexRatingNumMonsSeen, 1, 3',
            '\tline "Owned:@"',
            '\ttext_decimal hDexRatingNumMonsOwned, 1, 3',
            '\tdone',
        ]
        for label in MODULE.POKEDEX_RATING_LABELS[1:17]:
            rating_source.extend([f"{label}::", '\ttext "Rating text"', '\tdone'])
        (source / "text" / "pokedex_ratings.asm").write_text(
            "\n".join(rating_source) + "\n", encoding="utf-8"
        )
        (source / "data" / "text" / "text_2.asm").write_text(
            '_DexSeenOwnedText::\n'
            '\ttext "POKéDEX seen"\n'
            '\ttext_decimal wDexRatingNumMonsSeen, 1, 3\n'
            '\ttext_decimal wDexRatingNumMonsOwned, 1, 3\n'
            '\tdone\n'
            '_DexRatingText::\n'
            '\ttext "POKéDEX Rating"\n'
            '\tdone\n',
            encoding="utf-8",
        )
        (source / "data" / "english_text" / "manual_dialogue_overrides.json").write_text(
            json.dumps({"_ManualText": '\ttext "Manual English."\n\tdone\n'}),
            encoding="utf-8",
        )
        (source / "scripts" / "TestMap.asm").write_text(
            'TestMapText:\n'
            '\ttext_far _HelloText ; translated\n'
            '\ttext_far _DataText\n'
            '\ttext_far PlainText\n'
            '\ttext_far _ManualText\n'
            '\ttext_far _UnsafeText\n'
            '\ttext_far _MissingText\n'
            '\ttext_far _Route1Text2English\n'
            '\ttext_end\n'
            '; text_far _HelloText is only a comment\n',
            encoding="utf-8",
        )
        # A stale generated copy must be reset from authoritative src/.
        (build / "scripts" / "TestMap.asm").write_text(
            "stale generated file\n", encoding="utf-8"
        )
        return source, build

    def test_routes_tagged_and_manual_text_but_preserves_existing_english(self):
        with tempfile.TemporaryDirectory() as temp:
            source, build = self.make_tree(Path(temp))
            summary = MODULE.generate(source, build)
            script = (build / "scripts" / "TestMap.asm").read_text(encoding="utf-8")
            english = (
                build / "data" / "english_text" / "generated_dialogue.asm"
            ).read_text(encoding="utf-8")

            self.assertIn(
                "text_bilingual _HelloText, _HelloText_EN ; translated", script
            )
            self.assertIn("text_bilingual _DataText, _DataText_EN", script)
            self.assertIn("text_bilingual PlainText, PlainText_EN", script)
            self.assertIn("text_bilingual _ManualText, _ManualText_EN", script)
            self.assertIn("text_far _UnsafeText", script)
            self.assertIn("text_far _MissingText", script)
            self.assertIn("text_far _Route1Text2English", script)
            self.assertIn("; text_far _HelloText is only a comment", script)

            self.assertIn('_HelloText_EN::', english)
            self.assertIn('"Welcome, POKéMON!"', english)
            self.assertIn('"<PLAYER>: POKéMON"', english)
            self.assertIn("text_ram wPlayerName", english)
            self.assertIn('"POKé BALL ready<COLON>"', english)
            self.assertIn('_ManualText_EN::', english)
            self.assertNotIn("_UnsafeText_EN::", english)
            self.assertEqual(summary["routed_refs"], 4)
            self.assertEqual(summary["routed_labels"], 4)
            self.assertEqual(summary["pokedex_rating_labels"], 19)
            self.assertEqual(summary["pokedex_rating_bank"], 0x70)
            self.assertEqual(summary["ignored_existing_english_refs"], 1)
            self.assertEqual(summary["unrouted_script_refs"], 2)
            self.assertEqual(summary["missing_script_labels"], ["_MissingText"])
            self.assertEqual(summary["unsafe_tokens_in_map_scope"], ["<PKMN>"])

    def test_generation_is_idempotent_and_does_not_modify_source(self):
        with tempfile.TemporaryDirectory() as temp:
            source, build = self.make_tree(Path(temp))
            source_before = (source / "scripts" / "TestMap.asm").read_bytes()
            MODULE.generate(source, build)
            first_script = (build / "scripts" / "TestMap.asm").read_bytes()
            first_data = (
                build / "data" / "english_text" / "generated_dialogue.asm"
            ).read_bytes()
            first_rating_data = (
                build / "data" / "english_text" / "generated_pokedex_ratings.asm"
            ).read_bytes()
            MODULE.generate(source, build)
            self.assertEqual(first_script, (build / "scripts" / "TestMap.asm").read_bytes())
            self.assertEqual(
                first_data,
                (build / "data" / "english_text" / "generated_dialogue.asm").read_bytes(),
            )
            self.assertEqual(
                first_rating_data,
                (build / "data" / "english_text" / "generated_pokedex_ratings.asm").read_bytes(),
            )
            self.assertEqual(source_before, (source / "scripts" / "TestMap.asm").read_bytes())

    def test_unclassified_script_reference_fails_closed(self):
        with tempfile.TemporaryDirectory() as temp:
            source, build = self.make_tree(Path(temp))
            script = source / "scripts" / "TestMap.asm"
            script.write_text(
                script.read_text(encoding="utf-8") + "\ttext_far _UnclassifiedText\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "Unclassified src/scripts text_far labels"):
                MODULE.generate(source, build)

    def test_unsupported_special_token_is_not_routed(self):
        with tempfile.TemporaryDirectory() as temp:
            source, build = self.make_tree(Path(temp))
            text_file = source / "text" / "Test.asm"
            text_file.write_text(
                '_HelloText::\n\ttext "A <PKMN> token"\n\tdone\n',
                encoding="utf-8",
            )
            summary = MODULE.generate(source, build)
            script = (build / "scripts" / "TestMap.asm").read_text(encoding="utf-8")
            self.assertIn("text_far _HelloText", script)
            self.assertNotIn("text_bilingual _HelloText", script)
            self.assertIn("<PKMN>", summary["unsafe_tokens_in_map_scope"])

    def test_generated_sections_split_across_reserved_high_romx_banks(self):
        labels = ["_First", "_Second"]
        index = {
            label: MODULE.EnglishLabel(
                "test.asm", '\n'.join('\ttext \"123456789012345678\"' for _ in range(450)) + '\n\tdone\n', 0
            )
            for label in labels
        }
        output, _replacements, estimated, banks = MODULE.generated_english_data(labels, index)
        self.assertGreater(estimated, MODULE.SECTION_BUDGET)
        self.assertEqual(banks, [0x62, 0x63])
        self.assertIn('SECTION "English Dialogue 01", ROMX, BANK[$62]', output)
        self.assertIn('SECTION "English Dialogue 02", ROMX, BANK[$63]', output)

    def test_text_bilingual_opcode_consumes_both_pointers(self):
        root = SCRIPT.resolve().parents[1]
        macros = (root / "src" / "macros" / "scripts" / "text.asm").read_text(encoding="utf-8")
        home = (root / "src" / "home" / "text.asm").read_text(encoding="utf-8")
        self.assertIn("const TX_BILINGUAL ; $18", macros)
        self.assertIn("MACRO text_bilingual", macros)
        self.assertIn("dab \\1 ; CHS far pointer", macros)
        self.assertIn("dab \\2 ; English far pointer", macros)
        self.assertLess(home.index("cp TX_BILINGUAL"), home.index("cp TX_SOUND_POKEDEX_RATING"))

        handler = home[home.index("TextCommand_BILINGUAL::"):home.index("TextCommand_FAR_ReadPointer::")]
        self.assertIn("bit 5, a", handler)
        # English: skip the first (CHS) pointer before reading the second.
        self.assertRegex(
            handler,
            r"(?s)\.english.*?inc hl\s+inc hl\s+inc hl\s+jr TextCommand_FAR_ReadPointer",
        )
        # Chinese: read the first pointer, then skip the unused English pointer.
        self.assertRegex(
            handler,
            r"(?s)ld a, \[hli\]\s+ld e, a\s+ld a, \[hli\]\s+ld d, a\s+ld a, \[hli\]\s+inc hl\s+inc hl\s+inc hl\s+jr TextCommand_FAR_Load",
        )
        far_handler = home[home.index("TextCommand_FAR_ReadPointer::"):home.index("TextCommandJumpTable::")]
        self.assertIn("call TextCommandProcessor", far_handler)
        self.assertIn("ld [MBC1RomBank], a", far_handler)

    def test_line_width_audit_uses_real_name_limits_and_reflow_fixes(self):
        self.assertEqual(
            MODULE.visible_line_width("<PLAYER>: POKéMON"), 16
        )
        self.assertEqual(
            MODULE.visible_line_width("<TARGET>"), 10
        )
        for label, body in MODULE.TEXT_REFLOW_OVERRIDES.items():
            normalized, _ = MODULE.normalize_english_body(body)
            self.assertEqual(
                MODULE.line_width_violations(normalized), [], label
            )
        self.assertEqual(len(MODULE.TEXT_REFLOW_OVERRIDES), 3)

    def test_reflow_overrides_are_source_pinned_and_keep_all_words(self):
        source = SCRIPT.resolve().parents[1] / "src"
        english, _duplicates = MODULE.load_english_index(source)
        for label, override in MODULE.TEXT_REFLOW_OVERRIDES.items():
            original = english[label].body
            self.assertEqual(MODULE.effective_english_body(label, original), override)
            self.assertEqual(
                MODULE.text_literal_sequence(original),
                MODULE.text_literal_sequence(override),
            )
            with self.assertRaisesRegex(ValueError, "source .* changed"):
                MODULE.effective_english_body(label, original + "; changed\n")

    def test_special_expansion_only_changes_literals_not_comments(self):
        body = '\ttext "#MON <PLAYER>" ; # remains a comment\n'
        normalized, counts = MODULE.normalize_english_body(body)
        self.assertIn('"POKéMON <PLAYER>"', normalized)
        self.assertIn("; # remains a comment", normalized)
        self.assertEqual(counts["#"], 1)


if __name__ == "__main__":
    unittest.main()
