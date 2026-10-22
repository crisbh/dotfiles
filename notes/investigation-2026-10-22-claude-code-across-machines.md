# Claude Code across machines (2026-10-22)

## What was asked

Which problems remain with using Claude Code on both machines (Fedora and the Mac), once PR #4 (CLAUDE.md environment notes) was merged.

## What I checked

On the Fedora machine only, read-only: `ls -ld ~/.claude`, `git ls-files .claude`, `.gitignore`, `.stow-local-ignore`, `.claude/settings.json`, `install.sh`, `scripts/dotfiles-doctor`, `Brewfile`, `packages-fedora.txt`, `.tmux.conf`, the Claude Code install (`which claude`, `.last-update-result.json`), and `~/.claude/{projects,plugins,skills}`.

## What I found

1. `~/.claude` was a stow folded-directory symlink to `.dotfiles/.claude`. Credentials, history, sessions, memory and plugins all lived in the git working tree, kept out of commits only by `.gitignore:3`. A `git clean -fdx` or a re-clone would have deleted them.
2. `.stow-local-ignore` listed `CLAUDE.md` and `AGENTS.md` unanchored, which also matches `.claude/CLAUDE.md`. Once `~/.claude` becomes a real directory, the global CLAUDE.md would silently stop being linked. Found while testing the fix on a throwaway HOME.
3. `.claude/settings.local.json` therefore doubled as `~/.claude/settings.local.json`. My understanding (not verified) is that Claude Code only reads `settings.local.json` per project, so the `autoMode` block moved there in PR #4 only applies in `~/.dotfiles` and `~`. Its generated text is also wrong ("no remotes", trusted repo `~/Projects`).
4. The tmux hooks in `.claude/settings.json` need `jq` and end in `|| true`, so a missing `jq` fails silently. `jq` was in neither `Brewfile` nor `packages-fedora.txt`.
5. Claude Code is installed via `cask "claude-code"` (`Brewfile:75`) on the Mac, and via the native installer (`~/.local/bin/claude`, 2.1.308, self-updating) on Fedora. The repo recorded neither, and `scripts/dotfiles-doctor` checked neither `claude` nor `jq`.
6. Memory, plans and history are stored per machine, in `projects/` folders named after absolute paths (`-home-cbarrera-...` here, presumably `-Users-...` on the Mac). They are ignored by git and never move between machines.
7. `settings.json` declares the marketplace but has no `enabledPlugins`, so each machine chooses its own plugins.
8. `.gitignore` whitelisted only `settings.json`, although `.claude/CLAUDE.md` is tracked.
9. Small issues: `.tmux/plugins/catppuccin-tmux/custom/claude.sh` is stowed into tpm's clone of the plugin, so reinstalling the plugin may remove the link. The `✅` state is never cleared, so finished sessions stay in the status bar.

## Fixed in `fix/claude-cross-machine`

- `install.sh`: `prepare_claude_dir` creates a real `~/.claude` before stowing. If `~/.claude` is a symlink into the repo, it refuses to run while `claude` is running, asks first, then moves every untracked entry out of `.dotfiles/.claude`. Tested on a clone with a throwaway HOME: the state moved, only the tracked files stayed, and stow then linked `settings.json` and `CLAUDE.md`.
- `.stow-local-ignore`: the root-only entries are now anchored (`^/CLAUDE\.md$`, `^/AGENTS\.md$`). Added `^/notes`, because on Fedora `~/notes` is the vault.
- `jq` added to `Brewfile` and `packages-fedora.txt`. `!.claude/CLAUDE.md` added to `.gitignore`.
- `dotfiles-doctor` gained a Claude Code section (`claude`, `jq`, no folded `~/.claude`, both files linked).
- AGENTS.md and the README now document the `~/.claude` layout and how Claude Code is installed on each machine.

## What I could not determine

- The state of the Mac: whether its `~/.claude` is folded too, and whether `jq` is installed there.
- Whether Claude Code reads a user-level `~/.claude/settings.local.json` (item 3).

## What I'd do next

- On Fedora, quit every Claude Code session, then run `bash install.sh --no-pkgs` to migrate, then `dotfiles-doctor`.
- On the Mac: `git pull`, `bash install.sh --no-pkgs`, `dotfiles-doctor`.
- Decide on the `autoMode` block: correct it and put it in `settings.json`, or delete it.
- Optional: add `enabledPlugins`, and a `SessionEnd` hook that clears `@claude_state`.
