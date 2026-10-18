"""Tests for lib/taskslib.py (the `todo` pipeline)."""

from __future__ import annotations

import contextlib
import io
import unittest
from datetime import datetime
from pathlib import Path

from fixture import GOLDEN, TESTS, TODAY, YESTERDAY, make_vault

import taskslib
from vaultlib import Vault

RULES = taskslib.load_tag_rules(TESTS.parent / "task-tags.conf")


def quiet(fn, *args, **kwargs):
    with contextlib.redirect_stdout(io.StringIO()):
        return fn(*args, **kwargs)


class PipelineTest(unittest.TestCase):
    """collect + done on the fixture vault must reproduce the golden files."""

    def setUp(self):
        self.tmp, root = make_vault()
        self.vault = Vault(root)

    def tearDown(self):
        self.tmp.cleanup()

    def run_pipeline(self):
        quiet(taskslib.collect_vault, self.vault, today=TODAY)
        quiet(taskslib.done_vault, self.vault, today=TODAY)

    def test_matches_golden(self):
        self.run_pipeline()
        for rel in ["0-tasks/todo.md", "0-tasks/done.md", "0-tasks/active.md",
                    f"diary/{TODAY}.md", f"diary/{YESTERDAY}.md"]:
            with self.subTest(file=rel):
                expected = (GOLDEN / rel.replace("/", "-")).read_text(encoding="utf-8")
                self.assertEqual((self.vault.root / rel).read_text(encoding="utf-8"), expected)

    def test_second_run_changes_nothing(self):
        self.run_pipeline()
        notes = sorted(p for p in self.vault.root.rglob("*.md") if ".backups" not in p.parts)
        before = {p: (p.read_text(encoding="utf-8"), p.stat().st_mtime_ns) for p in notes}
        self.run_pipeline()
        after = {p: (p.read_text(encoding="utf-8"), p.stat().st_mtime_ns) for p in notes}
        self.assertEqual(before, after)  # same content, and files not even rewritten

    def test_collect_single_note(self):
        note = self.vault.diary_dir / f"{YESTERDAY}.md"
        added = quiet(taskslib.collect_vault, self.vault, [note], today=TODAY)
        self.assertEqual(added, 2)
        self.assertNotIn("Prepare lecture CUDA", self.vault.todo_file.read_text(encoding="utf-8"))


class CollectTest(unittest.TestCase):
    def test_tasks_in_note(self):
        lines = ["- [ ] real", "- [ ] ", "- [ ]   ", "- [x] done", "- [>] collected",
                 "log TODO: inline thing", "TODO: (COLLECTED) old", "TODO: finished DONE"]
        self.assertEqual(taskslib.tasks_in_note(lines), ["- [ ] real", "- [ ] inline thing"])

    def test_mark_collected_keeps_placeholders(self):
        lines = ["- [ ] real", "- [ ] ", "TODO: x", "TODO: (COLLECTED) y"]
        self.assertEqual(
            taskslib.mark_collected(lines),
            ["- [>] real", "- [ ] ", "TODO: (COLLECTED) x", "TODO: (COLLECTED) y"],
        )

    def test_add_to_todo_new_section_keeps_blank_lines(self):
        todo = ["# TODO list", "", "## 01-10-2026", "- [ ] a", "", "## 02-10-2026", "- [ ] b"]
        out = taskslib.add_to_todo(todo, "## 03-10-2026", ["- [ ] c", "- [ ] a"])
        self.assertEqual(out, todo + ["", "## 03-10-2026", "- [ ] c"])

    def test_add_to_todo_existing_section_inserts_in_place(self):
        todo = ["# TODO list", "", "## 01-10-2026", "- [ ] a", "", "## 02-10-2026", "- [ ] b"]
        out = taskslib.add_to_todo(todo, "## 01-10-2026", ["- [ ] new"])
        self.assertEqual(out[2:6], ["## 01-10-2026", "- [ ] a", "- [ ] new", ""])

    def test_add_to_todo_without_heading_keeps_everything(self):
        out = taskslib.add_to_todo(["---", "id: todo", "---"], "## 01-10-2026", ["- [ ] a"])
        self.assertEqual(out, ["---", "id: todo", "---", "", "## 01-10-2026", "- [ ] a"])


class TagTest(unittest.TestCase):
    def test_rules_from_conf(self):
        cases = {
            "- [ ] fix the parser script": "@coding",
            "- [ ] prepare lecture on CUDA": "@teaching",
            "- [ ] run tophat simulation": "@research",
            "- [ ] task 12 follow-up": "@tracking",
            "- [ ] committee meeting notes": "@admin",
        }
        for line, tag in cases.items():
            with self.subTest(line=line):
                self.assertIn(tag, taskslib.tag_line(line, RULES).split())

    def test_keyword_must_be_a_word(self):
        self.assertEqual(taskslib.tag_line("- [ ] buy a codex", RULES), "- [ ] buy a codex")

    def test_hand_added_tags_are_kept(self):
        self.assertEqual(taskslib.tag_line("- [ ] Older task @admin", RULES), "- [ ] Older task @admin")

    def test_tags_sorted_and_deduplicated(self):
        line = "- [ ] fix code for the paper @research @coding"
        self.assertEqual(taskslib.tag_line(line, RULES), "- [ ] fix code for the paper @coding @research")

    def test_email_is_not_a_tag(self):
        self.assertEqual(taskslib.tag_line("- [ ] write to ana@uni.cl", {}), "- [ ] write to ana@uni.cl")

    def test_quotes_survive(self):  # the bash version piped through xargs
        self.assertEqual(taskslib.tag_line("- [ ] don't \"panic\"", {}), "- [ ] don't \"panic\"")

    def test_only_task_lines_are_tagged(self):
        lines = ["# TODO list", "## 01-10-2026", "fix the script", "- [ ] fix the script"]
        self.assertEqual(taskslib.tag_lines(lines, RULES)[2:], ["fix the script", "- [ ] fix the script @coding"])


class DoneTest(unittest.TestCase):
    def test_tick_in_note_is_literal(self):
        note = ["- [>] Fix eq. [3] in paper* draft", "- [ ] Fix eq 3 in paper draft",
                "TODO: (COLLECTED) email a | b", "- [ ] untouched"]
        out = taskslib.tick_in_note(note, ["Fix eq. [3] in paper* draft", "email a | b"])
        self.assertEqual(out, ["- [x] Fix eq. [3] in paper* draft ✅ DONE", "- [ ] Fix eq 3 in paper draft",
                               "TODO: (COLLECTED) email a | b ✅ DONE", "- [ ] untouched"])

    def test_tick_is_idempotent(self):
        once = taskslib.tick_in_note(["- [>] a"], ["a"])
        self.assertEqual(taskslib.tick_in_note(once, ["a"]), once)

    def test_add_to_done_under_title(self):
        done = ["---", "id: done", "---", "", "# Done", "", "## 01-10-2026", "- [x] old"]
        out = quiet(taskslib.add_to_done, done, "## 17-10-2026", ["- [x] a", "- [x] b", "- [x] old"])
        self.assertEqual(out[4:9], ["# Done", "", "## 17-10-2026", "- [x] b", "- [x] a"])
        self.assertEqual(out.count("- [x] old"), 1)

    def test_add_to_done_without_title(self):
        out = quiet(taskslib.add_to_done, ["## 01-10-2026", "- [x] old"], "## 17-10-2026", ["- [x] a"])
        self.assertEqual(out, ["## 17-10-2026", "- [x] a", "", "## 01-10-2026", "- [x] old"])

    def test_add_to_done_empty_file(self):
        out = quiet(taskslib.add_to_done, [], "## 17-10-2026", ["- [x] a"])
        self.assertEqual(out, ["", "## 17-10-2026", "- [x] a"])


class BackupTest(unittest.TestCase):
    def test_keeps_newest_ten(self):
        tmp, root = make_vault()
        self.addCleanup(tmp.cleanup)
        vault = Vault(root)
        for minute in range(12):
            taskslib.backup_vault(vault, now=datetime(2026, 10, 17, 9, minute))
        todo_backups = sorted(p.name for p in vault.backups_dir.glob("todo_*.md"))
        self.assertEqual(len(todo_backups), 10)
        self.assertEqual(todo_backups[0], "todo_2026-10-17_09-02.md")


if __name__ == "__main__":
    unittest.main()
