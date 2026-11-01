#!/usr/bin/env bash
#
# install-check.sh: install the dotfiles as a new user on a fresh Fedora system
# and check the result. Run as root inside a throwaway container, never on a
# real machine: it installs packages and creates the user `tester`.
#
#   install-check.sh [repo]   repo to clone (default /src); exits 1 if a check fails
#
# Used by dotfiles-test (podman in a Lima VM) and by CI
# (.github/workflows/install.yml). Only committed files are tested: the repo is
# cloned, not used in place.

set -u

SRC="${1:-/src}"
[[ $EUID -eq 0 && -f /etc/fedora-release ]] || {
  echo "install-check.sh: run as root in a Fedora container" >&2
  exit 2
}

dnf install -y -q sudo git util-linux-script procps-ng >/dev/null || exit 1
useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/tester
cat >/home/tester/run.sh <<'EOF'
set -u
export TERM=xterm-256color
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory GIT_CONFIG_VALUE_0='*'
failed=0
pass() { echo "RESULT ✅ $1"; }
fail() { echo "RESULT ❌ $1"; failed=1; }
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }
# interactive zsh wants a terminal
in_pty() { script -qec "$1" /dev/null 2>&1 | sed -E 's/\x1b\[[0-9;? ]*[A-Za-z]//g; s/\r//g'; }

cd ~ && git clone -q "$SRC" ~/.dotfiles && git -C ~/.dotfiles log --oneline -1
cd ~/.dotfiles

echo "==== install.sh"
out=$(bash install.sh --yes 2>&1; echo "exit=$?")
echo "$out"
check "install.sh exits 0" 'grep -q "^exit=0" <<<"$out"'
check "install.sh deploys" 'grep -q "Installation complete" <<<"$out"'
for d in .claude .config .ssh .tmux .tmux/plugins; do
  check "~/$d is a real directory" "[[ -d ~/$d && ! -L ~/$d ]]"
done

echo "==== install.sh again"
out=$(bash install.sh --no-pkgs --yes 2>&1; echo "exit=$?")
echo "$out"
check "second run finds everything stowed" 'grep -q "already stowed" <<<"$out"'

echo "==== interactive zsh"
out=$(in_pty 'timeout --foreground 300 zsh -ic "print VAULT=\$VAULT; whence -p repos dotfiles-doctor"; echo "exit=$?"')
echo "$out"
check "zsh starts" 'grep -q "^exit=0" <<<"$out"'
check "\$VAULT is set" 'grep -q "^VAULT=$HOME/notes" <<<"$out"'
check "scripts/ is on PATH" 'grep -q "/.dotfiles/scripts/dotfiles-doctor" <<<"$out"'
check "zsh prints no errors" '! grep -qE "cannot|command not found|parse error" <<<"$out"'

echo "==== tmux"
check "tmux config loads" 'tmux new-session -d -s t "sleep 5" && tmux source-file ~/.tmux.conf'
tmux kill-server 2>/dev/null

echo "==== neovim"
timeout 900 nvim -n --headless "+Lazy! sync" +qa >/dev/null 2>&1
out=$(nvim -n --headless +'lua io.write(#require("lazy").plugins())' +qa 2>&1)
echo "plugins: $out"
# plugins may print after the count (copilot.lua downloading its server)
check "Neovim loads its plugins" '[[ $out =~ ^([0-9]+) && ${BASH_REMATCH[1]} -gt 0 ]]'

echo "==== python tests"
check "python tests pass" '(cd ~/.dotfiles/scripts/tests && python3 -m unittest 2>&1 | tail -3)'

echo "==== dotfiles-doctor"
out=$(in_pty 'zsh -ic dotfiles-doctor; echo "exit=$?"')
echo "$out"
check "dotfiles-doctor finds no problems" 'grep -q "^exit=0" <<<"$out"'

check "repo is clean afterwards" '[[ -z $(git -C ~/.dotfiles status --porcelain) ]]'
exit "$failed"
EOF
chown tester /home/tester/run.sh
su - tester -c "SRC='$SRC' bash ~/run.sh"
