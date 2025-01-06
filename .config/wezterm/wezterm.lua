local wezterm = require("wezterm")
return {
	color_scheme = "Dracula",
	-- color_scheme = "Tokyo Night",
	--color_scheme = "Catppuccin Mocha",
	font_size = 18.0,
	font = wezterm.font("JetBrains Mono"),
	enable_tab_bar = false,
	default_cursor_style = 'BlinkingBar',
	macos_window_background_blur = 5,
	-- window_background_opacity = 1.0,
	window_background_opacity = 0.90,
	window_decorations = "RESIZE",
	keys = {
		{
		-- Ctrl-f will toggle the terminal full screen
			key = "f",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
	},
	window_padding = {
		left = 5,
		right = 2,
		top = 0,
		bottom = 0,
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
