"""Tests for the offline parts of scripts/arxiv2bib."""

from __future__ import annotations

import importlib.machinery
import importlib.util
import unittest

from fixture import TESTS

_loader = importlib.machinery.SourceFileLoader("arxiv2bib", str(TESTS.parent / "arxiv2bib"))
_spec = importlib.util.spec_from_loader("arxiv2bib", _loader)
arxiv2bib = importlib.util.module_from_spec(_spec)
_loader.exec_module(arxiv2bib)


class ParseTest(unittest.TestCase):
    def test_refs(self):
        cases = {
            "2401.01234": ("arxiv", "2401.01234"),
            "arXiv:2401.01234v3": ("arxiv", "2401.01234"),
            "https://arxiv.org/abs/2401.01234v2": ("arxiv", "2401.01234"),
            "https://arxiv.org/pdf/2401.01234.pdf": ("arxiv", "2401.01234"),
            "astro-ph/0601001": ("arxiv", "astro-ph/0601001"),
            "10.1103/PhysRevD.104.123": ("doi", "10.1103/PhysRevD.104.123"),
            "https://doi.org/10.1093/mnras/stab123.": ("doi", "10.1093/mnras/stab123"),
        }
        for ref, expected in cases.items():
            with self.subTest(ref=ref):
                self.assertEqual(arxiv2bib.parse_ref(ref), expected)

    def test_rejects_garbage(self):
        with self.assertRaises(ValueError):
            arxiv2bib.parse_ref("notanid")


class EntryTest(unittest.TestCase):
    ONE_LINE = "@article{Key_2016, title={A, b {c}}, volume={1}, author={X and Y}, year={2016}, month=Feb }"

    def test_tidy_splits_top_level_fields_only(self):
        self.assertEqual(
            arxiv2bib.tidy(self.ONE_LINE),
            "@article{Key_2016,\n  title={A, b {c}},\n  volume={1},\n  author={X and Y},\n  year={2016},\n  month=Feb\n}",
        )

    def test_tidy_keeps_multiline_entries(self):
        entry = "@misc{k,\n  title={t},\n}"
        self.assertEqual(arxiv2bib.tidy(entry), entry)

    def test_key_and_duplicates(self):
        bib = "@article{Key_2016,\n  doi={10.1103/PhysRevD.104.123}\n}\n"
        self.assertEqual(arxiv2bib.entry_key(self.ONE_LINE), "Key_2016")
        self.assertTrue(arxiv2bib.already_in(bib, "doi", "10.1103/physrevd.104.123", "Other"))
        self.assertTrue(arxiv2bib.already_in(bib, "arxiv", "9999.99999", "Key_2016"))
        self.assertFalse(arxiv2bib.already_in(bib, "arxiv", "9999.99999", "Key"))


if __name__ == "__main__":
    unittest.main()
