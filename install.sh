#!/usr/bin/env bash
#
# Bootstrap the dotfiles: install packages for the current OS, then deploy with
# GNU stow. Cross-platform across macOS (Homebrew) and Fedora (dnf).
#
# Usage:
#   bash install.sh            # install packages (prompted) + stow
#   bash install.sh --no-pkgs  # skip package install, just stow
#
# Fedora note: the Obsidian vault is not on iCloud there. Clone it once with
#   git clone <your-vault-repo> ~/notes
# and $VAULT will point at ~/notes (see the .zshrc $OSTYPE branch). vault-sync
# keeps both machines in sync via git push/pull.

set -u

TARGET_DIR="$HOME"
SOURCE_DIR="."
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Detect OS ---
case "$(uname -s)" in
	Darwin) OS=macos ;;
	Linux)  OS=linux ;;
	*)      OS=unknown ;;
esac

# --- Repair what brew bundle left unsatisfied ---
# brew bundle carries on past failures: a formula left unlinked, a cask whose
# app is already in /Applications (installed by hand), an npm or cargo package
# that did not build. Ask `brew bundle check` what is still wrong, fix the kinds
# it can fix, and list the rest so they are not found weeks later.
brew_repair() {
	local check line kind name
	check=$(brew bundle check --verbose --no-upgrade --file="$DIR/Brewfile" 2>&1) && return 0
	while IFS= read -r line; do
		# Lines look like "→ Formula coreutils needs to be linked."
		[[ "$line" =~ ^→\ (Formula|Cask|npm\ Package|Cargo\ Package)\ ([^ ]+)\ needs\ to\ be\ ([a-z]+) ]] || continue
		kind=${BASH_REMATCH[1]} name=${BASH_REMATCH[2]}
		case "$kind:${BASH_REMATCH[3]}" in
			Formula:linked) brew link "$name" ;;
			Formula:unlinked) brew unlink "$name" ;;
			Formula:installed) brew install "$name" ;;
			# --adopt takes over an app installed by hand, and installs as usual otherwise
			Cask:installed) brew install --cask --adopt "$name" ;;
			npm\ Package:installed) npm install -g "$name" ;;
			Cargo\ Package:installed) cargo install "$name" ;;
		esac || echo "Could not repair $kind $name."
	done <<<"$check"

	if check=$(brew bundle check --verbose --no-upgrade --file="$DIR/Brewfile" 2>&1); then
		echo "Brewfile is satisfied."
	else
		echo
		echo "Still unresolved after repair (fix by hand, then run dotfiles-doctor):"
		grep '^→' <<<"$check"
		return 1
	fi
}

# --- Install packages ---
install_packages() {
	if [[ "$OS" == macos ]]; then
		if ! command -v brew >/dev/null 2>&1; then
			echo "Homebrew not found. Install it from https://brew.sh, then re-run."
			return 1
		fi
		echo "Installing macOS packages from Brewfile..."
		# node@22 is keg-only: put it (and cargo) first so the npm and cargo
		# entries use the same toolchain as the shell (.zshrc pins node@22)
		PATH="$(brew --prefix)/opt/node@22/bin:$HOME/.cargo/bin:$PATH"
		# --verbose shows each package as it installs; casks with a .pkg (mactex)
		# stop to ask for your password
		brew bundle --verbose --file="$DIR/Brewfile" || echo "brew bundle reported failures; repairing what it can..."
		brew_repair
	elif [[ "$OS" == linux ]]; then
		if ! command -v dnf >/dev/null 2>&1; then
			echo "dnf not found — this bootstrap targets Fedora. Install packages manually."
			return 1
		fi
		echo "Installing Fedora packages from packages-fedora.txt..."
		# shellcheck disable=SC2046
		sudo dnf install -y $(grep -vE '^#|^$' "$DIR/packages-fedora.txt")
	else
		echo "Unknown OS — skipping package install."
	fi
}

if [[ "${1:-}" != "--no-pkgs" ]]; then
	read -p "Install packages for $OS? (y/n): " PKG_CONFIRM
	if [[ "$PKG_CONFIRM" =~ ^[Yy]$ ]]; then
		install_packages
	else
		echo "Skipping package install."
	fi
fi

# --- Keep Claude Code state out of the repo ---
# Claude Code writes credentials, history and sessions into ~/.claude. If that
# directory does not exist, stow folds it into one symlink to the repo and all
# of that lands in the working tree. A real ~/.claude makes stow link only the
# tracked files into it; an existing folded link is migrated once.
prepare_claude_dir() {
	local home_dir="$TARGET_DIR/.claude" repo_dir="$DIR/.claude" tracked f
	if [[ ! -L "$home_dir" ]]; then
		mkdir -p "$home_dir"
		return 0
	fi
	[[ "$(readlink -f "$home_dir")" == "$(readlink -f "$repo_dir")" ]] || return 0

	echo "$HOME/.claude is a symlink into the repo, so Claude Code state lives in the working tree."
	if pgrep -x claude >/dev/null 2>&1; then
		echo "Quit every Claude Code session, then re-run to move it out."
		return 1
	fi
	read -rp "Move it to a real ~/.claude? (y/n): " CLAUDE_CONFIRM
	[[ "$CLAUDE_CONFIRM" =~ ^[Yy]$ ]] || return 1

	rm "$home_dir" && mkdir "$home_dir" || return 1
	# Everything except the tracked files moves; stow links those back in
	tracked=$(git -C "$DIR" ls-files .claude)
	shopt -s dotglob nullglob
	for f in "$repo_dir"/*; do
		grep -qxF ".claude/$(basename "$f")" <<<"$tracked" && continue
		mv "$f" "$home_dir/" || return 1
	done
	shopt -u dotglob nullglob
	echo "Moved Claude Code state to ~/.claude."
}

# --- Keep ~/.config, ~/.ssh and ~/.tmux out of the repo ---
# Same folding problem: on a fresh machine ~/.config would become a link to the
# repo and collect every tool's state (gh keeps its token there), ~/.ssh the
# private keys and ~/.tmux the tmux plugins.
# The catppuccin theme is cloned before stowing, so stow links custom/claude.sh
# into the clone; otherwise tpm sees the folder and skips installing it.
prepare_home_dirs() {
	local plugins="$TARGET_DIR/.tmux/plugins"
	mkdir -p "$TARGET_DIR/.config" "$TARGET_DIR/.ssh" "$plugins" && chmod 700 "$TARGET_DIR/.ssh" || return 1
	[[ -d "$plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$plugins/tpm" || return 1
	[[ -d "$plugins/catppuccin-tmux" ]] || git clone https://github.com/omerxx/catppuccin-tmux "$plugins/catppuccin-tmux" || return 1
}

# --- Deploy with stow ---
prepare_claude_dir || echo "Leaving ~/.claude as it is."
prepare_home_dirs || echo "Could not prepare ~/.config, ~/.ssh and ~/.tmux/plugins: check them before stowing."
echo
echo "Starting dry run of GNU stow..."
# stow reports on stderr, lists what it would do only with --verbose, and exits
# 1 on a conflict
DRY_RUN_OUTPUT=$(stow --simulate --verbose --target "$TARGET_DIR" "$SOURCE_DIR" 2>&1)
DRY_RUN_STATUS=$?
echo "$DRY_RUN_OUTPUT"
echo

if [[ $DRY_RUN_STATUS -ne 0 ]]; then
	echo "stow would fail (see above): move the conflicting files out of the way, then re-run."
	exit 1
elif ! grep -qE '^(LINK|UNLINK|MKDIR|RMDIR):' <<<"$DRY_RUN_OUTPUT"; then
	echo "Everything is already stowed."
else
	read -p "Proceed with stow deployment? (y/n): " CONFIRMATION

	if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
		echo "Deploying configuration files..."
		stow --target "$TARGET_DIR" "$SOURCE_DIR"
		echo "Installation complete! In tmux, press prefix + I to install the plugins."
	else
		echo "Installation canceled."
	fi
fi
