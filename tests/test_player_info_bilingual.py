import re
import unittest
from pathlib import Path

from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def workbook_replacements() -> dict[str, set[str]]:
    workbook = load_workbook(SRC / "xlsx" / "data.xlsx", data_only=True, read_only=True)
    sheet = workbook["Main"]
    current_path = sheet.cell(row=1, column=1).value
    result: dict[str, set[str]] = {}
    for row in range(2, sheet.max_row + 1):
        path = sheet.cell(row=row, column=1).value
        if path:
            current_path = path
        replacee = sheet.cell(row=row, column=2).value
        if isinstance(replacee, str) and replacee:
            result.setdefault(str(current_path), set()).add(replacee)
    workbook.close()
    return result


class PlayerInfoBilingualTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.main = read("src/engine/menus/main_menu.asm")
        cls.trainer = read("src/engine/menus/start_sub_menus.asm")
        cls.hof = read("src/engine/movie/hall_of_fame.asm")
        cls.replacements = workbook_replacements()

    def test_continue_and_save_info_choose_language_without_changing_live_stats(self):
        self.assertEqual(self.main.count("call GetSaveScreenInfoText"), 2)
        self.assertRegex(
            self.main,
            r"(?ms)^GetSaveScreenInfoText:\n"
            r"\tld de, SaveScreenInfoText\n"
            r"\tld a, \[wOptions\]\n"
            r"\tbit 5, a\n"
            r"\tret z\n"
            r"\tld de, SaveScreenInfoTextEnglish\n"
            r"\tret$",
        )
        self.assertRegex(
            self.main,
            r'(?ms)^SaveScreenInfoTextEnglish:\n'
            r'\tdb\s+"PLAY","ER"\n'
            r'\tnext "BAD","GES    "\n'
            r'\tnext "POKé","DEX    "\n'
            r'\tnext "TI","ME@"',
        )
        self.assertIn('db   "PLAYER"', self.main)
        self.assertIn('next "BADGES    "', self.main)
        self.assertIn('next "#DEX    "', self.main)
        self.assertIn("call PrintNumBadges", self.main)
        self.assertIn("call PrintNumOwnedMons", self.main)
        self.assertIn("call PrintPlayTime", self.main)

    def test_trainer_card_labels_choose_language_and_keep_dynamic_values(self):
        self.assertRegex(
            self.trainer,
            r"(?s)TrainerInfo_BadgesText\n"
            r"\tld a, \[wOptions\]\n\tbit 5, a\n"
            r"\tjr z, \.badgesTextReady\n"
            r"\tld de, TrainerInfo_BadgesTextEnglish\n"
            r"\.badgesTextReady\n\tcall PlaceString",
        )
        self.assertRegex(
            self.trainer,
            r"(?s)TrainerInfo_NameMoneyTimeText\n"
            r"\tld a, \[wOptions\]\n\tbit 5, a\n"
            r"\tjr z, \.nameMoneyTimeTextReady\n"
            r"\tld de, TrainerInfo_NameMoneyTimeTextEnglish\n"
            r"\.nameMoneyTimeTextReady\n\tcall PlaceString",
        )
        self.assertRegex(
            self.trainer,
            r'(?ms)^TrainerInfo_NameMoneyTimeTextEnglish:\n'
            r'\tdb\s+"NA","ME/"\n'
            r'\tnext "MO","NEY/"\n'
            r'\tnext "TI","ME/@"',
        )
        self.assertIn('db $76,"BAD","GES",$76,"@"', self.trainer)
        self.assertIn("predef DrawBadges", self.trainer)
        for value in ("wPlayerName", "wPlayerMoney", "wPlayTimeHours", "wPlayTimeMinutes"):
            self.assertIn(value, self.trainer)

    def test_hall_of_fame_time_and_money_labels_choose_language(self):
        self.assertRegex(
            self.hof,
            r"(?s)ld de, HoFPlayTimeText\n"
            r"\tld a, \[wOptions\]\n\tbit 5, a\n"
            r"\tjr z, \.playTimeLabelReady\n"
            r"\tld de, HoFPlayTimeTextEnglish\n"
            r"\.playTimeLabelReady\n\tcall PlaceString",
        )
        self.assertRegex(
            self.hof,
            r"(?s)ld de, HoFMoneyText\n"
            r"\tld a, \[wOptions\]\n\tbit 5, a\n"
            r"\tjr z, \.moneyLabelReady\n"
            r"\tld de, HoFMoneyTextEnglish\n"
            r"\.moneyLabelReady\n\tcall PlaceString",
        )
        self.assertIn('db "PLAY", " TIME@"', self.hof)
        self.assertIn('db "MON", "EY@"', self.hof)
        self.assertIn("ld de, wPlayTimeHours", self.hof)
        self.assertIn("ld de, wPlayTimeMinutes", self.hof)
        self.assertIn("ld de, wPlayerMoney", self.hof)
        self.assertIn("text_bilingual _DexSeenOwnedText, _DexSeenOwnedText_EN", self.hof)
        self.assertIn("text_bilingual _DexRatingText, _DexRatingText_EN", self.hof)

    def test_chinese_replacements_remain_owned_by_the_existing_workbook(self):
        expected = {
            "engine/menus/main_menu.asm": {
                '"PLAYER"', '"BADGES    "', '"#DEX    "', '"TIME@"',
            },
            "engine/menus/start_sub_menus.asm": {
                '"NAME/"', '"MONEY/"', '"TIME/@"', '$76,"BADGES",$76,"@"',
            },
            "engine/movie/hall_of_fame.asm": {
                '"PLAY TIME@"', '"MONEY@"',
            },
        }
        for path, replacees in expected.items():
            self.assertTrue(replacees.issubset(self.replacements.get(path, set())), path)

    def test_english_alternates_do_not_contain_workbook_chinese_replacement_keys(self):
        save = self.main.split("SaveScreenInfoTextEnglish:", 1)[1]
        trainer = self.trainer.split("TrainerInfo_NameMoneyTimeTextEnglish:", 1)[1]
        trainer_badges = trainer.split("TrainerInfo_BadgesTextEnglish:", 1)[1]
        hof = self.hof.split("HoFPlayTimeTextEnglish:", 1)[1]
        hof_money = hof.split("HoFMoneyTextEnglish:", 1)[1]
        for forbidden in ('"PLAYER"', '"BADGES    "', '"#DEX    "', '"TIME@"'):
            self.assertNotIn(forbidden, save)
        for forbidden in ('"NAME/"', '"MONEY/"', '"TIME/@"'):
            self.assertNotIn(forbidden, trainer)
        self.assertNotIn('$76,"BADGES",$76,"@"', trainer_badges)
        self.assertNotIn('"PLAY TIME@"', hof)
        self.assertNotIn('"MONEY@"', hof_money)


if __name__ == "__main__":
    unittest.main()
