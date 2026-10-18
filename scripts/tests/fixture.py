"""A small vault that mimics the real formats, for the tests.

Dates are fixed (TODAY) so results do not depend on when the tests run. The
golden/ files are what the pipeline must produce from this vault: they were
recorded from the bash scripts after the step 1 fixes, and the one intended
change since (hand-added tags are kept) was applied by hand.
"""

from __future__ import annotations

import subprocess
import sys
import tempfile
from datetime import date
from pathlib import Path

TESTS = Path(__file__).resolve().parent
sys.path.insert(0, str(TESTS.parent / "lib"))

TODAY = date(2026, 10, 17)
YESTERDAY = date(2026, 10, 16)
GOLDEN = TESTS / "golden"


def _note(day: str, tasks: str, log: str) -> str:
    return f"""---
id: "{day}"
aliases:
  - "{day}"
tags:
  - daily-notes
---

# {day}

## Today
> One sentence: what would make today a success?


{tasks}

## Notes and log
{log}
"""


FILES = {
    "diary/2026-10-16.md": _note(
        "2026-10-16",
        "- [ ] Reply re Peano MPI [DataTypes] (v2.1)\n- [ ] \n- [x] Already done",
        "TODO: email Wendi | zoom link",
    ),
    "diary/2026-10-17.md": _note(
        "2026-10-17",
        "- [ ] Fix eq. [3] in paper* draft\n- [ ] Prepare lecture CUDA\n- [ ] \n- [ ] ",
        "TODO: (COLLECTED) old item",
    ),
    "0-tasks/todo.md": "---\nid: todo\n---\n\n# TODO list\n\n## 10-10-2026\n- [ ] Older task @admin\n\n"
    "## 12-10-2026\n- [ ] Another older task\n",
    "0-tasks/active.md": "---\nid: active\n---\n\n# Active\n- [!] Urgent thing @research\n"
    "- [x] Fix eq. [3] in paper* draft\n- [x] email Wendi | zoom link\n- [ ] Still open @coding\n",
    "0-tasks/done.md": "---\nid: done\n---\n\n# Done\n\n## 01-10-2026\n- [x] Something finished earlier\n",
    "0-zettelkasten/alpha.md": "---\nid: alpha\n---\n\n# alpha\n\n"
    "See [[beta]] and [[missing-note]] and [[folder/beta|alias]].\n",
    "0-zettelkasten/beta.md": "---\nid: beta\n---\n\n# beta\n\nBack to [[alpha#Section]].\n",
    "1-projects/lonely.md": "---\nid: lonely\n---\n\n# lonely\n\nNobody links here. ![[diagram.png]]\n",
    "1-projects/empty.md": "---\nid: empty\n---\n\n# empty\n\n",
    "1-projects/creds.md": "---\nid: creds\n---\n\npassword: hunter22\n",
}


def make_vault(git: bool = False) -> tuple[tempfile.TemporaryDirectory, Path]:
    """Create the fixture vault; keep the returned TemporaryDirectory alive."""
    tmp = tempfile.TemporaryDirectory(prefix="vault-test-")
    root = Path(tmp.name)
    for rel, text in FILES.items():
        path = root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
    if git:
        run = lambda *a: subprocess.run(["git", "-C", str(root), *a], check=True, capture_output=True)  # noqa: E731
        run("init", "-q")
        run("add", "-A")
        run("-c", "user.name=t", "-c", "user.email=t@t", "-c", "commit.gpgsign=false", "commit", "-qm", "init")
    return tmp, root
