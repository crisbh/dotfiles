# Agent Instructions

## Hard constraints

- Never commit secrets, credentials, config files, or database files.
- Never force push, rewrite history, or amend commits you did not make.
- Never commit directly to `main`/`master` — work on a branch, open a PR.
- If a task appears to require any of the above, stop and explain why instead.

## Git and GitHub

- Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`).
- Never mention agents or add agent co-authorship to commit messages.
- New repos: enable branch protection on `main` (PR required, zero approvals)
  and automatic branch deletion after merge.
- After merging a PR: pull latest into the current branch, remove leftover
  worktrees.

## Files and formatting

- Markdown: one line per paragraph, no wrapping.
- Filenames: hyphens, no spaces or underscores.
- Maths in comments and markdown: TeX, not unicode.

## Investigation and audit tasks

When asked to investigate, audit, profile, or trace (rather than change):

- Do not modify source files. Read, run read-only commands, report.
- Write findings to `notes/investigation-YYYY-MM-DD-<topic>.md`.
- Structure: what was asked, what I checked, what I found, what I could not
  determine, what I'd do next.
- Cite `file:line` for every claim about the code. An unreferenced claim is a
  guess and must be labelled as one.
- Say plainly what you could not verify. The closing summary must not be more
  confident than the body.

## Document review

When reviewing a draft, do not rewrite it unless asked. Return located
observations grouped as: factual errors, unsupported claims, missing
citations, internal inconsistencies, then style (brief, last). For numbers,
check against sources in the repo and say which you could not check.

## Project context

- Keep each repo's CLAUDE.md to durable facts: how to build and test, layout,
  conventions, what not to touch. Update it when those change.
- Session state, progress, and pending work go in dated notes files, not in
  CLAUDE.md.

## Tmux

- When renaming a tmux window, prefix with a state emoji: 🚀 starting,
  ⏳ in progress, 🔍 researching, 🔨 building, 🧪 testing, ✅ done, 🔴 error,
  💬 waiting for input, 🛑 blocked.
