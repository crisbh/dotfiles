# shellcheck shell=bash
# common.sh — shared helpers for the dotfiles scripts.
#
# Sourced, never executed:
#
#   # shellcheck source=lib/common.sh
#   source "${DOTFILES:-$HOME/.dotfiles}/scripts/lib/common.sh"
#
# Also pulls in portable.sh (date/sed/notification differences across OSes).

# shellcheck source=lib/portable.sh
source "${DOTFILES:-$HOME/.dotfiles}/scripts/lib/portable.sh"

# Colours only when writing to a terminal and NO_COLOR is unset
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m' BOLD=$'\033[1m' RESET=$'\033[m'
else
  RED='' GREEN='' YELLOW='' BOLD='' RESET=''
fi
export RED GREEN YELLOW BOLD RESET

# die "<message>" — print an error to stderr and exit 1
die() {
  printf '%s❌ %s%s\n' "$RED" "$*" "$RESET" >&2
  exit 1
}

# warn "<message>" — print a warning to stderr
warn() {
  printf '%s⚠️  %s%s\n' "$YELLOW" "$*" "$RESET" >&2
}

# confirm "<question>" — ask y/N; returns 0 only on y/Y. Non-interactive
# callers (no terminal on stdin) always get "no".
confirm() {
  local answer
  [[ -t 0 ]] || return 1
  read -rp "$1 [y/N] " answer
  [[ "$answer" == [yY]* ]]
}

# usage — print the script's header comment (the lines after the shebang up to
# the first non-comment line), without the leading "# "
usage() {
  awk 'NR == 1 { next } /^#$/ && !started { next }
       /^#/ { started = 1; sub(/^# ?/, ""); print; next } { exit }' "$0"
}

# tmpfile <var> / tmpdir <var> — create a temp file/dir, store its path in the
# named variable, and remove it when the script exits:  tmpdir scratch
# (They set a variable rather than print the path: `$(tmpfile)` would run in a
# subshell and the cleanup registration would be lost.)
_DOTFILES_TMP=()
_dotfiles_cleanup() {
  ((${#_DOTFILES_TMP[@]})) && rm -rf -- "${_DOTFILES_TMP[@]}"
  return 0
}
trap _dotfiles_cleanup EXIT
tmpfile() {
  printf -v "$1" '%s' "$(mktemp)"
  _DOTFILES_TMP+=("${!1}")
}
tmpdir() {
  printf -v "$1" '%s' "$(mktemp -d)"
  _DOTFILES_TMP+=("${!1}")
}

# require_vault — abort unless $VAULT points at a directory, and define the
# standard vault paths
require_vault() {
  [[ -n "${VAULT:-}" ]] || die "\$VAULT is not set."
  [[ -d "$VAULT" ]] || die "\$VAULT is not a directory: $VAULT"
  TASKS_DIR="$VAULT/0-tasks"
  DIARY_DIR="$VAULT/diary"
  ZET_DIR="$VAULT/0-zettelkasten"
  PROJECTS_DIR="$VAULT/1-projects"
  TODO_FILE="$TASKS_DIR/todo.md"
  ACTIVE_FILE="$TASKS_DIR/active.md"
  DONE_FILE="$TASKS_DIR/done.md"
  export TASKS_DIR DIARY_DIR ZET_DIR PROJECTS_DIR TODO_FILE ACTIVE_FILE DONE_FILE
}
