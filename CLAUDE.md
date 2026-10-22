# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Repo layout, conventions and checks are in AGENTS.md:

@AGENTS.md

## Working in this environment

- Shell commands run in the user's interactive zsh, where `grep`, `ls`, `cp` and `rm` are aliased (colour or verbose output). Use `command grep` (etc.) in pipelines, or run the snippet with `bash -c`; zsh also lacks bash builtins such as `mapfile`. A zoxide warning is printed on every command: ignore it.
- Before adding a script, check the name is free: `.config/.aliasrc` aliases can shadow commands (`tms` is `tmux ls`; `todo` used to be an alias). `zsh -ic 'whence -v NAME'` shows what a name resolves to.
- Testing Neovim headlessly: use `nvim -n --headless` (no swap-file prompt when the user has the file open). lazy.nvim's `VeryLazy` event never fires without a UI, so fire it with `vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })` before checking LSP, Mason or VeryLazy plugins. Call mappings via `vim.fn.maparg(lhs, mode, false, true).callback()` instead of `feedkeys`, which can block on prompts.
- Exercise vault scripts on a throwaway vault (`scripts/tests/fixture.py`) and external tools through stubs placed first on `PATH` (tmux, fzf, squeue, scontrol); timewarrior honours `TIMEWARRIORDB` for a temporary database.
