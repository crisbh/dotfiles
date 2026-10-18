"""Tests for lib/vaultops.py and lib/vaultlib.py (the `vault` command)."""

from __future__ import annotations

import subprocess
import time
import unittest

from fixture import make_vault

import vaultops
from vaultlib import Vault, strip_frontmatter, wikilinks, write_lines


class VaultCase(unittest.TestCase):
    git = False

    def setUp(self):
        self.tmp, root = make_vault(git=self.git)
        self.vault = Vault(root)

    def tearDown(self):
        self.tmp.cleanup()


class LinksTest(VaultCase):
    def test_wikilinks(self):
        text = "---\nlinks: [[in-frontmatter]]\n---\n[[a]] [[b|alias]] [[c#head]] ![[img.png]] [[d/e]]"
        self.assertEqual(wikilinks(text), ["a", "b", "c", "img.png", "d/e"])

    def test_broken_links(self):
        self.assertEqual(
            vaultops.broken_links(self.vault),
            {"0-zettelkasten/alpha.md": ["missing-note"], "1-projects/lonely.md": ["diagram.png"]},
        )

    def test_existing_attachment_resolves(self):
        (self.vault.root / "attachments").mkdir()
        (self.vault.root / "attachments" / "diagram.png").write_bytes(b"png")
        self.assertNotIn("1-projects/lonely.md", vaultops.broken_links(self.vault))

    def test_orphans(self):
        self.assertEqual(vaultops.orphans(self.vault), ["1-projects/creds.md", "1-projects/empty.md", "1-projects/lonely.md"])


class SensitiveTest(VaultCase):
    git = True

    def git_tracked(self):
        out = subprocess.run(["git", "-C", str(self.vault.root), "ls-files"], capture_output=True, text=True)
        return out.stdout.split()

    def test_flags_untracks_and_ignores(self):
        report = vaultops.protect_sensitive(self.vault)
        self.assertEqual(report.flagged, {"1-projects/creds.md": ["plaintext credential"]})
        self.assertEqual(report.added, ["1-projects/creds.md"])
        self.assertEqual(report.untracked, ["1-projects/creds.md"])
        self.assertNotIn("1-projects/creds.md", self.git_tracked())
        self.assertTrue((self.vault.root / "1-projects/creds.md").exists())  # kept on disk
        self.assertIn("1-projects/creds.md", (self.vault.root / ".gitignore").read_text())

    def test_dry_run_changes_nothing(self):
        report = vaultops.protect_sensitive(self.vault, apply=False)
        self.assertEqual((report.added, report.untracked), (["1-projects/creds.md"], ["1-projects/creds.md"]))
        self.assertIn("1-projects/creds.md", self.git_tracked())
        self.assertFalse((self.vault.root / ".gitignore").exists())

    def test_second_run_is_clean(self):
        vaultops.protect_sensitive(self.vault)
        report = vaultops.protect_sensitive(self.vault)
        self.assertEqual((report.flagged, report.added, report.untracked), ({}, [], []))

    def test_patterns(self):
        hits = {
            "api key prefix": "token ghp_" + "a" * 36,
            "plaintext credential": "API_KEY = abcd1234",
            "private: true": "---\nprivate: true\n---",
        }
        for reason, text in hits.items():
            with self.subTest(reason=reason):
                self.assertTrue(vaultops.SENSITIVE_PATTERNS[reason].search(text))
        self.assertFalse(vaultops.SENSITIVE_PATTERNS["plaintext credential"].search("the password policy"))


class MiscTest(VaultCase):
    def test_empty_notes(self):
        self.assertEqual([self.vault.rel(n) for n in vaultops.empty_notes(self.vault)], ["1-projects/empty.md"])

    def test_is_empty(self):
        self.assertTrue(vaultops.is_empty("---\nid: x\n---\n\n# Title\n\n## Sub\n"))
        self.assertFalse(vaultops.is_empty("# Title\n\nsome text\n"))
        self.assertFalse(vaultops.is_empty("#hashtag only\n"))  # not a heading

    def test_stats(self):
        s = vaultops.stats(self.vault, now=time.time())
        self.assertEqual((s.notes, s.recent, s.pending, s.done), (10, 10, 2, 1))
        self.assertEqual(s.by_dir, {"0-zettelkasten": 2, "diary": 2, "1-projects": 3})

    def test_diary_index(self):
        lines = vaultops.diary_index_lines(["2026-10-16", "2025-12-31", "diary", "2026-09-01", "notes"])
        self.assertEqual(lines[6:], [
            "# Diary", "", "## 2026", "", "### October", "- [2026-10-16](2026-10-16)",
            "", "### September", "- [2026-09-01](2026-09-01)",
            "", "## 2025", "", "### December", "- [2025-12-31](2025-12-31)",
        ])

    def test_strip_frontmatter_needs_closing_line(self):
        self.assertEqual(strip_frontmatter("---\na: 1\n---\nbody"), "body")
        self.assertEqual(strip_frontmatter("---\nunclosed"), "---\nunclosed")

    def test_write_lines_skips_unchanged(self):
        path = self.vault.root / "x.md"
        self.assertTrue(write_lines(path, ["a"]))
        mtime = path.stat().st_mtime_ns
        self.assertFalse(write_lines(path, ["a"]))
        self.assertEqual(path.stat().st_mtime_ns, mtime)
        self.assertEqual(path.read_text(), "a\n")


if __name__ == "__main__":
    unittest.main()
