return {
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
		enabled = true,
		priority = 1000, -- Make sure to load this before all the other start plugins.
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
}
