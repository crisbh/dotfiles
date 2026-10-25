# Repositories with work not yet pushed, from the `repos` cache (refreshed in
# the background when it is older than two minutes).
show_repos() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_repos_icon" "")"
  local color="$(get_tmux_option "@catppuccin_repos_color" "$thm_yellow")"
  local text="$(get_tmux_option "@catppuccin_repos_text" "#($HOME/.dotfiles/scripts/repos --tmux)")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
