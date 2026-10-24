# dotfiles

Personal dotfiles for macOS (Homebrew) and Fedora (dnf), deployed into `$HOME` with GNU Stow. Durable facts only: how things are built, checked and laid out, and what not to touch.

## Layout and deployment

- The repo root is the stow package: every file not matched by `.stow-local-ignore` is symlinked into `$HOME` by `install.sh` (`bash install.sh --no-pkgs` to only re-stow). Repo-only files (docs, manifests, CI, `.gitignore`) must be listed in `.stow-local-ignore`, or they land in `$HOME`.
- `.gitconfig` sets `core.hooksPath` to `~/.config/git/hooks` (`.config/git/hooks/` here) for every repository: `commit-msg` rejects agent attribution, then runs the repository's own `commit-msg`. Other hooks in `.git/hooks` do not run while it is set, and `pre-commit install` refuses to install.
- Packages: `Brewfile` (macOS, shared by every Mac) and `packages-fedora.txt` (Fedora), both installed by `install.sh` and both kept by hand. To update the Brewfile, run `brew bundle dump --force --no-describe --file=<scratch file>` and copy over the lines for what was installed on request; a full dump also lists dependencies.
- `.zshrc` sets `DOTFILES_OS` (`macos`/`linux`) and `$VAULT` (the notes vault; `~/notes` on Fedora) and puts `scripts/` on `PATH`. Aliases live in `.config/.aliasrc`.
- Crontabs are kept by hand and installed with `crontab <file>`: `crontab-macos` on every Mac, `crontab-fedora` on Fedora. Both hard-code that machine's home and Homebrew paths. `dotfiles-doctor` checks the jobs in the right one are scheduled.
- The vault is shared between machines through its GitHub repo by `vault-sync`, which every machine runs: only `0-tasks/`, `0-zettelkasten/` and `templates/` are shared (allow-list `.gitignore`, template in `lib/vaultops.py`); `diary/` and the rest stay local to each machine; after pulling it runs `todo collect` and `todo done`, so completed tasks reach every machine. On macOS `$VAULT` is in iCloud, so the Macs share one folder (including its `.git`): only the Mac with `~/.vault-owner` runs `vault-sync` and the task cron jobs (the crontab lines test for it, `vault-sync` refuses without it). Exactly one Mac must have that file.
- `.claude/` holds only the tracked Claude Code config (`settings.json`, `CLAUDE.md`). `~/.claude` must be a real directory with those two files linked in, never a folded symlink to the repo, or credentials, history and sessions land in the working tree: `install.sh` creates it (and migrates a folded link) before stowing, and `dotfiles-doctor` checks it. The same goes for `~/.config` (tools keep state and tokens there), `~/.ssh` (private keys) and `~/.tmux` (plugins): `install.sh` creates them, and clones tpm and the catppuccin theme first, since the repo only adds `custom/claude.sh` to the theme. Entries in `.stow-local-ignore` for root-only files are anchored (`^/CLAUDE\.md$`) so they do not also skip `.claude/CLAUDE.md`.
- Claude Code is installed by the `claude-code` cask on macOS and by the native installer (`~/.local/bin/claude`, self-updating) on Fedora; its tmux hooks need `jq`.

## Neovim (`.config/nvim`)

- Kickstart-based, lazy.nvim, one spec per file in `lua/plugins/`. Needs Neovim 0.11+.
- nvim-treesitter and nvim-treesitter-textobjects are on their `main` branches: parsers are installed by `lua/plugins/treesitter.lua`, highlighting is started from a `FileType` autocmd, and text objects are mapped explicitly there.
- LSP: mason-lspconfig v2 enables installed servers automatically; `lua/plugins/lspconfig.lua` only layers capabilities and per-server settings via `vim.lsp.config`. Tools Mason must install are listed there (`mason-tool-installer`).
- Formatting: conform.nvim with format on save (not for C/C++/CUDA); `<leader>tf` toggles it.
- `lua/git-marks.lua` adds git status letters to Telescope file lists.
- `~/Projects/.python-shims/` holds symlinks named after Python packages whose repo folder has a different name; pyright and `gf` search it.

## Scripts (`scripts/`)

- Everything in `scripts/` is on `PATH`, so names must not clash with existing commands or aliases (check `.config/.aliasrc`).
- Split by role: Python for code that parses or rewrites file contents (`todo`, `vault`, `arxiv2bib`, logic in `lib/*.py`); bash for glue around other tools (`wt`, `commit`, `push`, `day`, `zet`, `note`, `sq`, `tp`, `vault-sync`, `dotfiles-doctor`, ...).
- Bash scripts start with `#!/usr/bin/env bash`, a header comment that `--help` prints (`usage`), `set -euo pipefail`, and `source "${DOTFILES:-$HOME/.dotfiles}/scripts/lib/common.sh"` (`die`, `warn`, `confirm`, `tmpfile`/`tmpdir`, `require_vault`, colours; it also loads `lib/portable.sh` for macOS/Linux differences). `vault-sync` and `dotfiles-doctor` deliberately omit `-e` and check exit codes explicitly.
- Python: standard library only, Python 3.9+ (macOS's system python3), no `__pycache__` in the repo (`sys.dont_write_bytecode`). Executables add `scripts/lib` to `sys.path`. Pure functions take and return lists of lines; file writes go through `vaultlib.write_lines` (atomic, skips unchanged files so watchers are not retriggered).
- The task file formats (diary, `todo.md`, `active.md`, `done.md`) are documented at the top of `lib/taskslib.py`. Tag rules are in `task-tags.conf`.
- Old names are kept as thin wrappers because cron, Neovim keymaps and muscle memory use them: `todo-collect`, `todo-mark-done`, `todo-add-tags`, `todo-backup`, `todo-add-task`, `vault-ls`, `vault-stats`, `vault-broken-links`, `vault-orphans`, `vault-check-sensitive`, `vault-clean-empty`, `generate-diary-index`, `listen`, `pusha`. Do not remove them.

## Checks

- `scripts/check` runs shfmt (`-i 2 -ci`), shellcheck and the Python tests; `scripts/check --fix` reformats. CI runs it on PRs touching `scripts/` (`.github/workflows/scripts.yml`).
- Single test: `cd scripts/tests && python3 -m unittest testtasks.TagTest.test_email_is_not_a_tag` (module, class or method).
- Tests are in `scripts/tests/` (stdlib `unittest`, files named `test*.py` without underscores). `tests/fixture.py` builds a small vault with fixed dates; `tests/golden/` holds the expected pipeline output. Never run tests or experiments against the real `$VAULT`.
- `dotfiles-doctor` checks a machine against what the dotfiles expect (tools, links, cron, vault).
