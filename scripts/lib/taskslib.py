"""Task pipeline for the vault: collect, tag, mark done, back up.

Formats (all markdown, one task per line):

  diary/YYYY-MM-DD.md   daily notes; `- [ ] task` and inline `TODO: task`
  0-tasks/todo.md       frontmatter, `# TODO list`, then `## DD-MM-YYYY`
                        sections of collected `- [ ] task @tags`
  0-tasks/active.md     tasks being worked on; `- [x]` marks them done
  0-tasks/done.md       frontmatter, a `# ` title, then `## DD-MM-YYYY`
                        sections, newest first

The functions taking and returning lists of lines are pure, so they can be
tested without a vault; the `*_vault` functions do the file handling.
"""

from __future__ import annotations

import re
import shutil
from datetime import date, datetime, timedelta
from pathlib import Path

from vaultlib import Vault, read_lines, write_lines

TODO_HEADING = "# TODO list"
# A tag starts the line or follows whitespace, so `user@host` is not a tag
TAG_RE = re.compile(r"(?<!\S)@[A-Za-z0-9_-]+")
OPEN_TASK_RE = re.compile(r"^- \[ \] (.*\S.*)$")  # non-empty unchecked task
CHECKBOX_RE = re.compile(r"^- \[[!> x]\] ")
BACKUP_KEEP = 10


def section_title(day: date) -> str:
    return f"## {day:%d-%m-%Y}"


def strip_tags(text: str) -> str:
    """Task text without @tags, whitespace collapsed."""
    return " ".join(TAG_RE.sub("", text).split())


# ── collect ───────────────────────────────────────────────────────────────────


def tasks_in_note(lines: list[str]) -> list[str]:
    """New tasks in a daily note, as `- [ ] ...` lines.

    Unchecked, non-empty `- [ ]` tasks, then inline `TODO: ...` items that are
    neither collected yet nor done.
    """
    tasks = [line for line in lines if OPEN_TASK_RE.match(line)]
    for line in lines:
        pos = line.find("TODO: ")
        if pos == -1:
            continue
        item = line[pos:]
        if item.startswith("TODO: (COLLECTED)") or item.endswith("DONE"):
            continue
        tasks.append("- [ ] " + item[len("TODO: ") :])
    return tasks


def mark_collected(lines: list[str]) -> list[str]:
    """`- [ ] task` -> `- [>] task`; `TODO: x` -> `TODO: (COLLECTED) x`.

    The daily template's empty `- [ ] ` placeholders are left alone.
    """
    out = []
    for line in lines:
        m = OPEN_TASK_RE.match(line)
        if m:
            line = "- [>] " + m.group(1)
        elif "TODO: " in line and "TODO: (COLLECTED)" not in line:
            line = line.replace("TODO: ", "TODO: (COLLECTED) ", 1)
        out.append(line)
    return out


def add_to_todo(todo: list[str], section: str, tasks: list[str]) -> list[str]:
    """Add tasks under `section` in todo.md, creating the section at the end.

    Everything up to and including `# TODO list` is kept as the header. Task
    lines are deduplicated (first occurrence wins); blank lines and headings
    are left alone so sections stay separated.
    """
    if TODO_HEADING in todo:
        cut = todo.index(TODO_HEADING) + 1
        header, body = todo[:cut], todo[cut:]
    else:
        header, body = todo, []

    if section in body:
        # Insert after the section's last non-blank line (before the next heading)
        start = body.index(section)
        end = start + 1
        while end < len(body) and not body[end].startswith("#"):
            end += 1
        while end > start + 1 and not body[end - 1].strip():
            end -= 1
        body = body[:end] + tasks + body[end:]
    else:
        body = body + ["", section] + tasks

    seen: set[str] = set()
    deduped = []
    for line in body:
        if line.startswith("- "):
            if line in seen:
                continue
            seen.add(line)
        deduped.append(line)
    return header + deduped


def collect_vault(vault: Vault, notes: list[Path] | None = None, today: date | None = None) -> int:
    """Collect tasks from daily notes into todo.md; returns how many were added.

    Without `notes`, today's and yesterday's notes are used.
    """
    today = today or date.today()
    if notes is None:
        notes = [vault.diary_dir / f"{d:%Y-%m-%d}.md" for d in (today, today - timedelta(days=1))]

    for path in (vault.todo_file, vault.done_file):
        if not path.exists():
            write_lines(path, [])
    backup_vault(vault)

    added = 0
    for note in notes:
        if not note.exists():
            continue
        lines = read_lines(note)
        tasks = tasks_in_note(lines)
        if not tasks:
            print(f"✅ No new tasks found in {note}, skipping.")
            continue
        note_day = datetime.strptime(note.stem, "%Y-%m-%d").date()
        write_lines(vault.todo_file, add_to_todo(read_lines(vault.todo_file), section_title(note_day), tasks))
        write_lines(note, mark_collected(lines))
        added += len(tasks)
        print(f"✅ Collected {len(tasks)} task(s) from {note}")

    tag_vault(vault)
    return added


# ── tag ───────────────────────────────────────────────────────────────────────

_POSIX_CLASSES = {"[:space:]": r"\s", "[:alpha:]": "a-zA-Z", "[:digit:]": "0-9", "[:alnum:]": "a-zA-Z0-9"}


def posix_to_python(pattern: str) -> str:
    """Translate the POSIX bracket classes used in task-tags.conf to Python re."""
    for posix, py in _POSIX_CLASSES.items():
        pattern = pattern.replace(f"[{posix}]", f"[{py}]").replace(posix, py)
    return pattern


def load_tag_rules(conf: Path) -> dict[str, re.Pattern[str]]:
    """`@tag: regex` lines; blank lines and `#` comments are skipped."""
    rules = {}
    for line in read_lines(conf):
        if not line.strip() or line.lstrip().startswith("#") or ":" not in line:
            continue
        tag, pattern = line.split(":", 1)
        rules[tag.strip()] = re.compile(posix_to_python(pattern.strip()), re.IGNORECASE)
    return rules


def tag_line(line: str, rules: dict[str, re.Pattern[str]]) -> str:
    """Add the tags whose rule matches the task text. Existing tags are kept,
    including hand-added ones whose rule does not match."""
    text = CHECKBOX_RE.sub("", line)
    tags = set(TAG_RE.findall(line))
    tags.update(tag for tag, rule in rules.items() if rule.search(text.lower()))
    base = " ".join(TAG_RE.sub("", line).split())
    return " ".join([base, *sorted(tags)]) if tags else base


def tag_lines(lines: list[str], rules: dict[str, re.Pattern[str]]) -> list[str]:
    return [tag_line(line, rules) if re.match(r"^-\s", line) else line for line in lines]


def tag_vault(vault: Vault, conf: Path | None = None) -> None:
    conf = conf or Path(__file__).resolve().parent.parent / "task-tags.conf"
    lines = read_lines(vault.todo_file)
    if write_lines(vault.todo_file, tag_lines(lines, load_tag_rules(conf))):
        print(f"✅ Tasks updated with tags in {vault.todo_file}")


# ── done ──────────────────────────────────────────────────────────────────────


def completed(active: list[str]) -> list[str]:
    """`- [x]` lines of active.md, whitespace-normalised."""
    return [" ".join(line.split()) for line in active if line.startswith("- [x]")]


def tick_in_note(lines: list[str], texts: list[str]) -> list[str]:
    """Mark tasks done in a daily note: `- [ ]`/`- [>]` or unfinished inline
    `TODO:` lines containing one of `texts` (literal substring match)."""
    out = []
    for line in lines:
        is_task = re.match(r"^- \[[ >]\] ", line)
        is_inline = "TODO: " in line and not line.endswith("DONE")
        if (is_task or is_inline) and any(t in line for t in texts):
            line = re.sub(r"^- \[[ >]\] ", "- [x] ", line) + " ✅ DONE"
        out.append(line)
    return out


def add_to_done(done: list[str], section: str, tasks: list[str]) -> list[str]:
    """Record tasks under `section` in done.md.

    A missing section goes right after the `# ` title (or after the
    frontmatter, or at the end). Tasks already present anywhere are skipped;
    each new one goes directly below the section line.
    """
    out = list(done)
    if section not in out:
        i = 0
        if out and out[0] == "---":
            i = out.index("---", 1) + 1 if "---" in out[1:] else len(out)
        title = next((j for j in range(i, len(out)) if out[j].startswith("# ")), None)
        if title is not None:
            out[title + 1 : title + 1] = ["", section]
        else:
            first = next((j for j in range(i, len(out)) if out[j].strip()), None)
            if first is not None:
                out[first:first] = [section, ""]
            else:
                out += ["", section]
    for task in tasks:
        if task in out:
            continue
        print(f"✅ Adding task to DONE.md: {task}")
        out.insert(out.index(section) + 1, task)
    return out


def done_vault(vault: Vault, today: date | None = None) -> int:
    """Move `- [x]` tasks from active.md to done.md and tick them in the diary."""
    today = today or date.today()
    backup_vault(vault)

    tasks = completed(read_lines(vault.active_file))
    if not tasks:
        print(f"ℹ️  No completed tasks in {vault.active_file}.")
        return 0

    texts = [t for t in (strip_tags(t[len("- [x] ") :]) for t in tasks) if t]
    for note in sorted(vault.diary_dir.glob("*.md")):
        write_lines(note, tick_in_note(read_lines(note), texts))

    write_lines(vault.done_file, add_to_done(read_lines(vault.done_file), section_title(today), tasks))
    write_lines(vault.active_file, [line for line in read_lines(vault.active_file) if not line.startswith("- [x]")])
    print("✅ DONE sync complete!")
    return len(tasks)


# ── backup ────────────────────────────────────────────────────────────────────


def backup_vault(vault: Vault, now: datetime | None = None) -> None:
    """Copy todo.md and active.md to .backups/, keeping the newest BACKUP_KEEP each."""
    stamp = (now or datetime.now()).strftime("%Y-%m-%d_%H-%M")
    vault.backups_dir.mkdir(parents=True, exist_ok=True)
    for target in (vault.todo_file, vault.active_file):
        if not target.exists():
            continue
        shutil.copy2(target, vault.backups_dir / f"{target.stem}_{stamp}.md")
        # The timestamp sorts chronologically
        backups = sorted(vault.backups_dir.glob(f"{target.stem}_*.md"), reverse=True)
        for old in backups[BACKUP_KEEP:]:
            old.unlink()
