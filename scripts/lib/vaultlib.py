"""Shared helpers for the vault scripts (`todo`, `vault`).

Standard library only, Python >= 3.9, so it runs as-is on macOS's bundled
python3, Fedora and HPC login nodes.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

# Colours only for terminals, and never when NO_COLOR is set
_COLOUR = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
RED, GREEN, YELLOW, BOLD, RESET = (
    ("\033[31m", "\033[32m", "\033[33m", "\033[1m", "\033[m") if _COLOUR else ("",) * 5
)


def die(message: str) -> None:
    """Print an error to stderr and exit 1."""
    print(f"{RED}❌ {message}{RESET}", file=sys.stderr)
    sys.exit(1)


def confirm(question: str) -> bool:
    """Ask y/N; without a terminal on stdin the answer is always no."""
    if not sys.stdin.isatty():
        return False
    return input(f"{question} [y/N] ").strip().lower().startswith("y")


@dataclass(frozen=True)
class Vault:
    """Standard locations inside the vault."""

    root: Path

    @classmethod
    def from_env(cls) -> Vault:
        value = os.environ.get("VAULT")
        if not value:
            die("$VAULT is not set.")
        root = Path(value)
        if not root.is_dir():
            die(f"$VAULT is not a directory: {root}")
        return cls(root)

    @property
    def tasks_dir(self) -> Path:
        return self.root / "0-tasks"

    @property
    def diary_dir(self) -> Path:
        return self.root / "diary"

    @property
    def zet_dir(self) -> Path:
        return self.root / "0-zettelkasten"

    @property
    def projects_dir(self) -> Path:
        return self.root / "1-projects"

    @property
    def todo_file(self) -> Path:
        return self.tasks_dir / "todo.md"

    @property
    def active_file(self) -> Path:
        return self.tasks_dir / "active.md"

    @property
    def done_file(self) -> Path:
        return self.tasks_dir / "done.md"

    @property
    def backups_dir(self) -> Path:
        return self.tasks_dir / ".backups"

    def all_notes(self) -> list[Path]:
        """Every note on disk (outside .obsidian/), ignored by git or not."""
        return sorted(
            p for p in self.root.rglob("*.md") if ".obsidian" not in p.relative_to(self.root).parts
        )

    def tracked_notes(self) -> list[Path]:
        """Notes git would see (tracked or new, not ignored); all notes without git."""
        if not (self.root / ".git").exists():
            return self.all_notes()
        out = subprocess.run(
            ["git", "-C", str(self.root), "ls-files", "-z", "--cached", "--others",
             "--exclude-standard", "--", "*.md"],
            check=True, capture_output=True, text=True,
        ).stdout
        return sorted(self.root / rel for rel in out.split("\0") if rel)

    def rel(self, path: Path) -> str:
        return str(path.relative_to(self.root))


def read_lines(path: Path) -> list[str]:
    """Lines without their newline; a missing file reads as empty."""
    if not path.exists():
        return []
    return path.read_text(encoding="utf-8").splitlines()


def write_lines(path: Path, lines: list[str]) -> bool:
    """Write lines atomically, only if the content changed. Returns True if written.

    Unchanged files are left untouched so file watchers (watch-todos,
    Syncthing, Obsidian) are not retriggered.
    """
    text = "".join(line + "\n" for line in lines)
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.name}.", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(text)
        if path.exists():
            os.chmod(tmp, path.stat().st_mode | 0o200)  # keep mode, ensure writable
        os.replace(tmp, path)
    except BaseException:
        os.unlink(tmp)
        raise
    return True


def strip_frontmatter(text: str) -> str:
    """Drop a leading `---` ... `---` YAML block."""
    lines = text.splitlines()
    if lines and lines[0] == "---":
        for i in range(1, len(lines)):
            if lines[i] == "---":
                return "\n".join(lines[i + 1 :])
    return text


# [[target]], [[target|alias]], [[target#heading]], ![[embed]]
_WIKILINK = re.compile(r"\[\[([^\]|#]+)[^\]]*\]\]")


def wikilinks(text: str) -> list[str]:
    """Link targets in a note body (frontmatter excluded), in order of appearance."""
    return [m.group(1).strip() for m in _WIKILINK.finditer(strip_frontmatter(text))]
