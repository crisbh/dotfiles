local wezterm = require("wezterm")
return {
	color_scheme = "Dracula",
	--color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font("JetBrains Mono"),
	macos_window_background_blur = 5,
	-- macos_window_background_blur = 30,

	-- window_background_opacity = 1.0,
	window_background_opacity = 0.78,
	-- window_background_opacity = 0.20,
	window_decorations = "RESIZE",
	keys = {
		{
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
