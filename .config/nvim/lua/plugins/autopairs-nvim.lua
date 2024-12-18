return {
	{
		"windwp/nvim-autopairs",
		event = { "VeryLazy", "InsertEnter" },
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true, -- Use treesitter to check for pair context
				disable_filetype = { "TelescopePrompt", "vim" }, -- Disable in specific file types
			})
			-- Integration with nvim-cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
