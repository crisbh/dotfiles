# Claude Code session state. The state is written by the tmux hooks in
# ~/.claude/settings.json, as a session-scoped @claude_state user option.
# Only sessions with a state are listed, so this stays empty when idle.
show_claude() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_claude_icon" "󱚝")"
  local color="$(get_tmux_option "@catppuccin_claude_color" "$thm_pink")"
  local text="$(get_tmux_option "@catppuccin_claude_text" "#{S:#{?@claude_state,#{@claude_state}#{session_name} ,}}")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
