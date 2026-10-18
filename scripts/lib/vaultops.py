"""Vault health checks and maintenance: stats, links, orphans, sensitive
content, empty notes, and the diary index.

Each check returns data; printing is left to the `vault` command, so the
logic can be tested on a fixture vault.
"""

from __future__ import annotations

import re
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path

from vaultlib import Vault, read_lines, strip_frontmatter, wikilinks, write_lines

# ── stats ─────────────────────────────────────────────────────────────────────


@dataclass
class Stats:
    notes: int
    words: int
    recent: int  # modified in the last 7 days
    pending: int
    done: int
    by_dir: dict[str, int] = field(default_factory=dict)


def stats(vault: Vault, now: float | None = None) -> Stats:
    notes = vault.all_notes()
    week_ago = (now or time.time()) - 7 * 86400
    count = lambda path, prefix: sum(line.startswith(prefix) for line in read_lines(path))  # noqa: E731
    return Stats(
        notes=len(notes),
        words=sum(len(n.read_text(encoding="utf-8", errors="replace").split()) for n in notes),
        recent=sum(n.stat().st_mtime >= week_ago for n in notes),
        pending=count(vault.todo_file, "- [ ]"),
        done=count(vault.done_file, "- [x]"),
        by_dir={
            d.name: len(list(d.rglob("*.md"))) if d.is_dir() else 0
            for d in (vault.zet_dir, vault.diary_dir, vault.projects_dir)
        },
    )


# ── links ─────────────────────────────────────────────────────────────────────


def _names(vault: Vault) -> tuple[set[str], set[str]]:
    """Note names (basename without .md) and attachment file names on disk."""
    notes, files = set(), set()
    for p in vault.root.rglob("*"):
        if ".obsidian" in p.relative_to(vault.root).parts or ".git" in p.parts or not p.is_file():
            continue
        (notes.add(p.stem) if p.suffix == ".md" else files.add(p.name))
    return notes, files


def _resolves(target: str, notes: set[str], files: set[str]) -> bool:
    """Does a [[target]] point at an existing note or attachment?

    Obsidian resolves by name, so `folder/note` only needs `note` to exist.
    """
    name = target.rsplit("/", 1)[-1]
    if name.endswith(".md"):
        name = name[:-3]
    return name in notes or name in files


def broken_links(vault: Vault) -> dict[str, list[str]]:
    """{note (relative path): [unresolved targets]} for notes git would see."""
    notes, files = _names(vault)
    broken = {}
    for note in vault.tracked_notes():
        targets = sorted({t for t in wikilinks(note.read_text(encoding="utf-8")) if not _resolves(t, notes, files)})
        if targets:
            broken[vault.rel(note)] = targets
    return broken


def orphans(vault: Vault) -> list[str]:
    """Notes in 0-zettelkasten/ and 1-projects/ that no other note links to.

    The diary is linear by design, so it is not checked (but its links count).
    """
    incoming = set()
    for note in vault.all_notes():
        for target in wikilinks(note.read_text(encoding="utf-8")):
            name = target.rsplit("/", 1)[-1]
            incoming.add(name[:-3] if name.endswith(".md") else name)
    checked = (vault.zet_dir, vault.projects_dir)
    return [
        vault.rel(n)
        for n in vault.tracked_notes()
        if any(d in n.parents for d in checked) and n.stem not in incoming
    ]


# ── sensitive content ─────────────────────────────────────────────────────────

SENSITIVE_PATTERNS = {
    "api key prefix": re.compile(
        r"(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|xoxb-[0-9]+-[A-Za-z0-9]+|AKIA[0-9A-Z]{16})"
    ),
    "plaintext credential": re.compile(r"(?i)(password|passwd|secret|api_key)\s*[:=]\s*\S{4,}"),
    "private: true": re.compile(r"^private:\s*true", re.MULTILINE),
}

GITIGNORE_TEMPLATE = """\
# vault .gitignore — managed by `vault sensitive`

# Static exclusions
.obsidian/
attachments/
Excalidraw/
Clippings/
*.log
*.pdf
3-archive/

# Auto-flagged by `vault sensitive`:
"""


@dataclass
class SensitiveReport:
    flagged: dict[str, list[str]]  # note -> reasons
    added: list[str]  # newly added to .gitignore
    untracked: list[str]  # removed from git's index (kept on disk)
    created_gitignore: bool = False


def scan_sensitive(vault: Vault) -> dict[str, list[str]]:
    flagged: dict[str, list[str]] = {}
    for note in vault.tracked_notes():
        text = note.read_text(encoding="utf-8", errors="replace")
        reasons = [reason for reason, rx in SENSITIVE_PATTERNS.items() if rx.search(text)]
        if reasons:
            flagged[vault.rel(note)] = reasons
    return flagged


def protect_sensitive(vault: Vault, apply: bool = True) -> SensitiveReport:
    """Add flagged notes to .gitignore and untrack them if git tracks them.

    Note content is never modified. With apply=False nothing is changed: the
    report says what would be added and untracked.
    """
    gitignore = vault.root / ".gitignore"
    created = not gitignore.exists()
    if created and apply:
        gitignore.write_text(GITIGNORE_TEMPLATE, encoding="utf-8")

    flagged = scan_sensitive(vault)
    ignored = {line for line in read_lines(gitignore) if line and not line.startswith("#")}
    added = [rel for rel in sorted(flagged) if rel not in ignored]
    if added and apply:
        write_lines(gitignore, read_lines(gitignore) + added)

    untracked = []
    if (vault.root / ".git").exists():
        for rel in sorted(flagged):
            tracked = subprocess.run(
                ["git", "-C", str(vault.root), "ls-files", "--error-unmatch", "--", rel],
                capture_output=True,
            ).returncode == 0
            if tracked:
                if apply:
                    subprocess.run(["git", "-C", str(vault.root), "rm", "--cached", "--quiet", "--", rel], check=True)
                untracked.append(rel)
    return SensitiveReport(flagged, added, untracked, created)


# ── empty notes ───────────────────────────────────────────────────────────────


def is_empty(text: str) -> bool:
    """Nothing beyond frontmatter, blank lines and headings."""
    return all(
        not line.strip() or re.match(r"^#{1,6} ", line)
        for line in strip_frontmatter(text).splitlines()
    )


def empty_notes(vault: Vault) -> list[Path]:
    return [n for n in vault.tracked_notes() if is_empty(n.read_text(encoding="utf-8"))]


# ── diary index ───────────────────────────────────────────────────────────────

INDEX_HEADER = ["---", "id: diary", "aliases: []", "tags: []", "---", "", "# Diary"]
_MONTHS = ["January", "February", "March", "April", "May", "June", "July",
           "August", "September", "October", "November", "December"]


def diary_index_lines(names: list[str]) -> list[str]:
    """Index of YYYY-MM-DD notes, newest first, under year and month headings."""
    lines = list(INDEX_HEADER)
    year = month = None
    for name in sorted((n for n in names if re.fullmatch(r"\d{4}-\d{2}-\d{2}", n)), reverse=True):
        if name[:4] != year:
            year, month = name[:4], None
            lines += ["", f"## {year}"]
        if name[5:7] != month:
            month = name[5:7]
            lines += ["", f"### {_MONTHS[int(month) - 1]}"]
        lines.append(f"- [{name}]({name})")
    return lines


def write_diary_index(vault: Vault) -> Path:
    index = vault.diary_dir / "diary.md"
    write_lines(index, diary_index_lines([p.stem for p in vault.diary_dir.glob("*.md")]))
    return index
