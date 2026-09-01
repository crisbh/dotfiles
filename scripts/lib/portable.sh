# portable.sh — cross-platform helpers for the dotfiles scripts.
#
# Sourced, never executed. Papers over BSD (macOS) vs GNU (Linux) differences in
# `date` and `sed`, and macOS vs Linux desktop notifications.
#
#   source "${DOTFILES:-$HOME/.dotfiles}/scripts/lib/portable.sh"
#
# Lives under scripts/lib/ so it is not on $PATH and not invoked by cron; the
# .sh extension is therefore safe (see the crontab extension constraint).

# Resolve the OS even when $DOTFILES_OS is not exported (e.g. cron jobs).
if [[ -z "${DOTFILES_OS:-}" ]]; then
  case "$(uname -s)" in
    Darwin) DOTFILES_OS=macos ;;
    *)      DOTFILES_OS=linux ;;
  esac
fi

# pdate "<relative>" "<format>" — print a date relative to now.
#   pdate "-1 day"   "+%Y-%m-%d"
#   pdate "tomorrow" "+%Y-%m-%d"
# Uses GNU `gdate`/`date -d` when available; falls back to BSD `date -v`.
pdate() {
  local rel="$1" fmt="$2"

  if command -v gdate >/dev/null 2>&1; then
    gdate -d "$rel" "$fmt"; return
  fi
  if date -d "$rel" "$fmt" >/dev/null 2>&1; then
    date -d "$rel" "$fmt"; return          # GNU date (Linux)
  fi

  # BSD date (macOS without coreutils): translate to a -v adjustment.
  local adj=""
  case "$rel" in
    today|now)  adj="" ;;
    yesterday)  adj="-v-1d" ;;
    tomorrow)   adj="-v+1d" ;;
    *)
      if [[ "$rel" =~ ^([+-]?)([0-9]+)[[:space:]]*(day|days|week|weeks|month|months|year|years)$ ]]; then
        local sign="${BASH_REMATCH[1]:-+}" num="${BASH_REMATCH[2]}" unit="${BASH_REMATCH[3]}"
        case "$unit" in
          day|days)     unit=d ;;
          week|weeks)   unit=w ;;
          month|months) unit=m ;;
          year|years)   unit=y ;;
        esac
        adj="-v${sign}${num}${unit}"
      else
        echo "pdate: unsupported relative expression '$rel'" >&2
        return 1
      fi
      ;;
  esac
  date $adj "$fmt"
}

# psed_i <sed-args...> <file> — in-place sed that works on both GNU and BSD.
#   psed_i 's/foo/bar/g' file
psed_i() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"        # GNU sed (Linux)
  else
    sed -i '' "$@"     # BSD sed (macOS)
  fi
}

# pnotify "<title>" "<message>" — desktop notification, best-effort.
pnotify() {
  local title="$1" msg="$2"
  if [[ "$DOTFILES_OS" == macos ]]; then
    osascript -e "display notification \"$msg\" with title \"$title\"" 2>/dev/null
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$msg"
  fi
}

# require_cmds <cmd>... — abort unless every named command is on $PATH.
# Several scripts pipe through `rg ... 2>/dev/null`; without this a missing
# ripgrep yields an empty pipeline and a confident, wrong "nothing found".
require_cmds() {
  local missing=()
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || missing+=("$c")
  done

  [[ ${#missing[@]} -eq 0 ]] && return 0

  # Binary name and package name differ often enough to be worth mapping.
  local pkgs=()
  for c in "${missing[@]}"; do
    case "$c:$DOTFILES_OS" in
      rg:*)             pkgs+=(ripgrep) ;;
      fd:macos)         pkgs+=(fd) ;;
      fd:linux)         pkgs+=(fd-find) ;;
      timew:macos)      pkgs+=(timewarrior) ;;
      timew:linux)      pkgs+=(timew) ;;
      notify-send:*)    pkgs+=(libnotify) ;;
      *)                pkgs+=("$c") ;;
    esac
  done

  echo "❌ Missing required command(s): ${missing[*]}" >&2
  if [[ "$DOTFILES_OS" == macos ]]; then
    echo "   Install with: brew install ${pkgs[*]}" >&2
  else
    echo "   Install with: sudo dnf install ${pkgs[*]}" >&2
  fi
  exit 1
}
