import importlib.util
import re
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "generate_bilingual_dialogue.py"
SPEC = importlib.util.spec_from_file_location("generate_bilingual_dialogue_pokedex", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

VERIFY_SCRIPT = ROOT / "scripts" / "verify_rom142_pokedex_rating_static.py"
VERIFY_SPEC = importlib.util.spec_from_file_location("verify_rom142_pokedex_rating_static", VERIFY_SCRIPT)
VERIFY_MODULE = importlib.util.module_from_spec(VERIFY_SPEC)
assert VERIFY_SPEC and VERIFY_SPEC.loader
sys.modules[VERIFY_SPEC.name] = VERIFY_MODULE
VERIFY_SPEC.loader.exec_module(VERIFY_MODULE)


class PokedexRatingBilingualTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.english_index, cls.duplicates = MODULE.load_english_index(ROOT / "src")

    def test_generates_all_19_original_english_labels_in_bank_70(self):
        output, summary = MODULE.generated_pokedex_rating_data(
            self.english_index, self.duplicates
        )
        self.assertEqual(summary["labels"], 19)
        self.assertEqual(summary["bank"], 0x70)
        self.assertLess(summary["estimated_bytes"], MODULE.SECTION_BUDGET)
        self.assertEqual(summary["max_line_width"], 18)
        self.assertEqual(summary["max_dynamic_line_width"], 18)
        self.assertIn('SECTION "English Pokedex Ratings", ROMX, BANK[$70]', output)
        for label in MODULE.POKEDEX_RATING_LABELS:
            self.assertIn(f"{label}_EN::", output)
        self.assertEqual(
            len(re.findall(r"(?m)^_[A-Za-z0-9_]+_EN::$", output)), 19
        )

    def test_map_dialogue_bank_reservation_cannot_overlap_pokedex_bank(self):
        self.assertEqual(MODULE.LAST_ENGLISH_BANK + 1, MODULE.POKEDEX_RATING_BANK)
        labels = [f"_Overflow{i}" for i in range(15)]
        body = ('\\ttext "123456789012345678"\\n' * 400) + '\\tdone\\n'
        index = {
            label: MODULE.EnglishLabel("test.asm", body, i)
            for i, label in enumerate(labels)
        }
        with self.assertRaisesRegex(ValueError, "only.*reserved"):
            MODULE.generated_english_data(labels, index)

    def test_expands_special_pokemon_dictionary_without_losing_live_counters(self):
        output, summary = MODULE.generated_pokedex_rating_data(
            self.english_index, self.duplicates
        )
        quoted = re.findall(r'"(?:\\.|[^"\\])*"', output)
        self.assertTrue(any("POKéDEX" in literal for literal in quoted))
        self.assertTrue(any("POKéMON" in literal for literal in quoted))
        self.assertFalse(any("#" in literal for literal in quoted))
        self.assertEqual(summary["special_replacements"], 10)
        for command in (
            "text_decimal hDexRatingNumMonsSeen, 1, 3",
            "text_decimal hDexRatingNumMonsOwned, 1, 3",
            "text_decimal wDexRatingNumMonsSeen, 1, 3",
            "text_decimal wDexRatingNumMonsOwned, 1, 3",
        ):
            self.assertIn(command, output)

    def test_missing_or_duplicate_rating_source_fails_closed(self):
        index = dict(self.english_index)
        del index["_DexRatingText_Own150To151"]
        with self.assertRaisesRegex(ValueError, "missing"):
            MODULE.generated_pokedex_rating_data(index, self.duplicates)

        duplicates = set(self.duplicates)
        duplicates.add("_DexRatingText_Own150To151")
        with self.assertRaisesRegex(ValueError, "duplicate"):
            MODULE.generated_pokedex_rating_data(self.english_index, duplicates)

        index = dict(self.english_index)
        original = index["_DexRatingText_Own0To9"]
        index["_DexRatingText_Own0To9"] = MODULE.EnglishLabel(
            "wrong_source.asm", original.body, original.offset
        )
        with self.assertRaisesRegex(ValueError, "must come from text/pokedex_ratings.asm"):
            MODULE.generated_pokedex_rating_data(index, self.duplicates)

    def test_overwide_or_unreviewed_rating_text_fails_closed(self):
        index = dict(self.english_index)
        label = "_DexRatingText_Own0To9"
        original = index[label]
        index[label] = MODULE.EnglishLabel(
            original.path,
            '\n\ttext "1234567890123456789"\n\tdone\n',
            original.offset,
        )
        with self.assertRaisesRegex(ValueError, "19 columns"):
            MODULE.generated_pokedex_rating_data(index, self.duplicates)

        index[label] = MODULE.EnglishLabel(
            original.path,
            '\n\ttext_asm\n\tdone\n',
            original.offset,
        )
        with self.assertRaisesRegex(ValueError, "unsupported tokens/commands"):
            MODULE.generated_pokedex_rating_data(index, self.duplicates)

    def test_dynamic_decimal_digits_are_included_in_line_width_audit(self):
        index = dict(self.english_index)
        label = "_DexSeenOwnedText"
        original = index[label]
        widened = original.body.replace(
            'line "         Owned:@"',
            'line "          Owned:@"',
            1,
        )
        self.assertNotEqual(widened, original.body)
        index[label] = MODULE.EnglishLabel(
            original.path, widened, original.offset
        )
        with self.assertRaisesRegex(ValueError, "19 columns"):
            MODULE.generated_pokedex_rating_data(index, self.duplicates)

    def test_static_threshold_guard_rejects_a_changed_threshold(self):
        rating = (ROOT / "src/engine/events/pokedex_rating.asm").read_text(encoding="utf-8")
        VERIFY_MODULE.verify_threshold_table(rating)
        mutated = rating.replace(
            "dbw 10, DexRatingText_Own0To9",
            "dbw 11, DexRatingText_Own0To9",
            1,
        )
        with self.assertRaisesRegex(AssertionError, "threshold table"):
            VERIFY_MODULE.verify_threshold_table(mutated)

    def test_runtime_wrappers_cover_all_thresholds_and_hall_of_fame(self):
        rating = (ROOT / "src/engine/events/pokedex_rating.asm").read_text(encoding="utf-8")
        hof = (ROOT / "src/engine/movie/hall_of_fame.asm").read_text(encoding="utf-8")
        for label in MODULE.POKEDEX_RATING_LABELS[:17]:
            wrapper = label[1:]
            self.assertRegex(
                rating,
                rf"(?m)^{wrapper}:\n\ttext_bilingual {label}, {label}_EN\n\ttext_end$",
            )
        for label in ("_DexSeenOwnedText", "_DexRatingText"):
            wrapper = label[1:]
            self.assertRegex(
                hof,
                rf"(?m)^{wrapper}:\n\ttext_bilingual {label}, {label}_EN\n\ttext_end$",
            )
        self.assertIn('cp CHARVAL("@")', rating)
        self.assertIn("ld de, wDexRatingNumMonsSeen", rating)
        self.assertRegex(
            rating,
            r"(?s)ld de, wDexRatingNumMonsSeen.*?inc de.*?inc de ; de now points to wDexRatingText.*?\.copyRatingTextLoop",
        )
        self.assertIn("wDexRatingText:: db", (ROOT / "src/ram/wram.asm").read_text(encoding="utf-8"))
        self.assertIn("text_bilingual _DexSeenOwnedText, _DexSeenOwnedText_EN", hof)


if __name__ == "__main__":
    unittest.main()
