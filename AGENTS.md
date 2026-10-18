# dotfiles

Personal dotfiles for macOS (Homebrew) and Fedora (dnf), deployed into `$HOME` with GNU Stow. Durable facts only: how things are built, checked and laid out, and what not to touch.

## Layout and deployment

- The repo root is the stow package: every file not matched by `.stow-local-ignore` is symlinked into `$HOME` by `install.sh` (`bash install.sh --no-pkgs` to only re-stow). Repo-only files (docs, manifests, CI, `.gitignore`) must be listed in `.stow-local-ignore`, or they land in `$HOME`.
- Packages: `Brewfile` (macOS) and `packages-fedora.txt` (Fedora), both installed by `install.sh`.
- `.zshrc` sets `DOTFILES_OS` (`macos`/`linux`) and `$VAULT` (the notes vault; `~/notes` on Fedora) and puts `scripts/` on `PATH`. Aliases live in `.config/.aliasrc`.
- `crontab.backup` is written daily by a cron job on the Mac (`crontab -l > ...`): do not edit it by hand. It uses macOS paths; the Fedora machine has no crontab.
- `.claude/` is tool state; only `settings.json` and `CLAUDE.md` there are tracked.

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
- Tests are in `scripts/tests/` (stdlib `unittest`, files named `test*.py` without underscores). `tests/fixture.py` builds a small vault with fixed dates; `tests/golden/` holds the expected pipeline output. Never run tests or experiments against the real `$VAULT`.
- `dotfiles-doctor` checks a machine against what the dotfiles expect (tools, links, cron, vault).
