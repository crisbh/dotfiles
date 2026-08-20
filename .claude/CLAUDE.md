# Agent Instructions

## Rule: Secrets

- Never commit secrets, config files, or database files

## Rule: Structure Conventions

- Single-line paragraphs in all markdown files — no multi-line wrapped paragraphs
- No underscores or spaces in filenames; use hyphens
- Prefer TeX over unicode characters for mathematical expressions in comment blocks and markdown files

## Rule: Context Maintenance

- At the end of every significant task or session, summarise the current state, architectural decisions made, and pending TODO items into the CLAUDE.md file of the corresponding repo. Always ensure such file reflects the ground truth of the project so future sessions can resume without friction.

## Rule: Commits

- Always use conventional commits (e.g. `feat:`, `fix:`, `docs:`, `chore:`)
- Never add anything agent related (copilot, claude, etc.) to commit messages or co-authorship

## Rule: GitHub repos management

- Always enable branch protection on `main` when creating a new GitHub repo so a PR is always required
- Require zero reviews (PRs required but no approvals needed)
- Enable automatic branch deletion after a PR is merged
- After merging a PR, pull the latest changes into the current branch and delete any leftover worktrees

## Rule: Agent specific

- When renaming a tmux window, always prefix the name with an emoji reflecting current state: `🚀` starting, `⏳` in progress, `🔍` researching, `🔨` building, `🧪` testing, `✅` done, `🔴` error, `💬` waiting for input, `🛑` blocked
