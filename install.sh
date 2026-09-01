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

# --- Install packages ---
install_packages() {
	if [[ "$OS" == macos ]]; then
		if ! command -v brew >/dev/null 2>&1; then
			echo "Homebrew not found. Install it from https://brew.sh, then re-run."
			return 1
		fi
		echo "Installing macOS packages from Brewfile..."
		brew bundle --file="$DIR/Brewfile"
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

# --- Deploy with stow ---
echo
echo "Starting dry run of GNU stow..."
DRY_RUN_OUTPUT=$(stow --simulate --target "$TARGET_DIR" "$SOURCE_DIR" | tee /dev/tty)
echo

if echo "$DRY_RUN_OUTPUT" | head -n2 | tail -n1 | grep -qE "^(WARNING|LINK)"; then
	echo "Configuration seems to be already up-to-date. Aborting Installation..."
else
	read -p "Proceed with stow deployment? (y/n): " CONFIRMATION

	if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
		echo "Deploying configuration files..."
		stow --target "$TARGET_DIR" "$SOURCE_DIR"
		echo "Installation complete!"
	else
		echo "Installation canceled."
	fi
fi
