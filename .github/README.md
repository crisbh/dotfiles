<h1 align="center">dotfiles repo</h1>

<div align="center"><p>
    <a href="https://github.com/crisbh/dotfiles/pulse">
      <img src="https://img.shields.io/github/last-commit/crisbh/dotfiles?color=%4dc71f&label=Last%20Commit&logo=github&style=flat-square"/>
    </a>
    <a href="https://github.com/crisbh/dotfiles/actions/workflows/scripts.yml">
      <img src="https://img.shields.io/github/actions/workflow/status/crisbh/dotfiles/scripts.yml?branch=main&label=scripts&logo=github&style=flat-square"/>
    </a>
</p>
</div>

## Overview

The dotfiles I use on my own machines, macOS and Fedora, aimed at a smooth terminal-centred daily workflow: editing, research code on HPC clusters, notes and tasks.

| | |
|---|---|
| Shell | `zsh` (plugins via zinit, aliases in `.config/.aliasrc`) |
| Terminal | `wezterm` (also configs for `kitty`) |
| Editor | `neovim` |
| Session manager | `tmux` |
| PDF reader | `zathura` |
| File manager | `ranger` |
| Tiling window manager | `amethyst` (macOS) |
| Git | `.gitconfig` with `delta`, worktree aliases and the `wt` helper |

## Installation

Clone the repo into `~/.dotfiles` and run the install script:

```shell
git clone git@github.com:crisbh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh            # install packages (asks first), then deploy
bash install.sh --no-pkgs  # only deploy
```

Packages come from the `Brewfile` on macOS and `packages-fedora.txt` on Fedora. Deployment uses [GNU stow](https://www.gnu.org/software/stow/): the repo mirrors the layout of `$HOME`, and every file not listed in `.stow-local-ignore` is symlinked into place (the script shows a dry run before changing anything). To deploy by hand instead:

```shell
mkdir -p ~/.claude   # keep Claude Code state out of the repo (install.sh does this)
stow -t "$HOME" .
```

Claude Code comes from the Brewfile on macOS; on Fedora install it with the native installer (`curl -fsSL https://claude.ai/install.sh | bash`).

Then check the machine:

```shell
dotfiles-doctor
```

It reports missing tools, broken symlinks, unstowed files, missing cron jobs and the state of the notes vault.

### Another Mac

The Macs share the Brewfile and `crontab-macos`, and see the same vault through iCloud. On the new Mac:

1. Install the Xcode command line tools (`xcode-select --install`) and [Homebrew](https://brew.sh), and set up an SSH key for GitHub.
2. Clone into `~/.dotfiles` (cron and the scripts expect that path) and run `bash install.sh`, then press prefix + `I` in tmux and open `nvim` once to install the plugins.
3. Log in: `gh auth login`, `claude`, and git-credential-manager on first push.
4. `macos-defaults`, then `crontab ~/.dotfiles/crontab-macos`. Do not create `~/.vault-owner`: only one Mac runs `vault-sync` and the task jobs on the iCloud vault, and that file marks it.
5. Run `dotfiles-doctor`.

## Neovim

A Kickstart-based config (Neovim 0.11+) with lazy.nvim and one plugin spec per file in `.config/nvim/lua/plugins/`. Highlights:

- **Language servers** installed by Mason and enabled automatically, with format on save through conform.nvim (`<leader>tf` toggles it), inline diagnostics and inlay hints (`<leader>th`).
- **Treesitter** highlighting, plus text objects and motions for functions, classes, parameters and blocks (`vaF`, `]f`, `>P`, ...) and sticky scroll for the enclosing function.
- **Telescope** pickers marked with each file's git status, and a picker for modified files (`<leader>fm`).
- **IDE-style panels**: diagnostics and references (`<leader>xx`), project search and replace (`<leader>sr`), a debugger UI on the function keys, breadcrumbs, and sessions per directory (`<leader>ss`).
- **Git**: Neogit, gitsigns (inline blame, hunk staging) and `<leader>gC` to commit the current file.

## Scripts

Everything in `scripts/` is on `PATH`. Run any of them with `--help` for details.

| Command | What it does |
|---|---|
| `commit`, `push` | Show what will be committed, ask for a message, commit (and push). `commit <file>` commits only that file. |
| `stage` | Pick changed files with fzf and stage or unstage them, with a diff preview. |
| `wt` | Git worktrees, one tmux session each: pick, create, remove, and clean up after merged PRs. tmux: prefix `W`. |
| `tp` | Open a project in its own tmux session. tmux: prefix `P`. |
| `todo` | Task pipeline for the notes vault: collect tasks from daily notes, tag them, move finished ones to `done.md`, pomodoros. |
| `vault` | Vault maintenance: stats, broken links, orphaned notes, keeping secrets out of git, and `vault sync` to back it up to GitHub. |
| `day`, `zet`, `note` | Open today's diary note, open or create a zettelkasten note, append a quick timestamped note. |
| `repos` | Every repo's sync state across machines: `repos` to start the day (fetch, fast-forward, vault sync), `repos --leave` before switching machines (lazygit in each repo with unpushed work). Reminders: tmux status bar, new shells, and notifications at 16:00 and 18:00. |
| `sq` | Slurm jobs in a picker: follow output, cancel, check efficiency. |
| `arxiv2bib` | Fetch BibTeX for arXiv ids or DOIs into a `.bib` file. |
| `rerun` | Run a command again whenever a file in the repo (or matching `-g GLOB`) changes. |
| `formatter` | Format every recognised file in a project (ruff, stylua, shfmt, clang-format). |
| `dotfiles-doctor` | Check a machine against what the dotfiles expect. |
| `macos-defaults` | Apply the macOS settings the dotfiles expect (key repeat, screenshot folder). |

The notes scripts expect `$VAULT` to point at the notes vault, which `.zshrc` sets per OS.

## Development

```shell
scripts/check        # shfmt, shellcheck and the Python tests
scripts/check --fix  # also reformat the shell scripts
```

The same check runs on every pull request touching `scripts/`. Bash scripts share `scripts/lib/common.sh`; the Python tools use only the standard library (Python 3.9+), with tests in `scripts/tests/`. See [`AGENTS.md`](../AGENTS.md) for the full conventions.
