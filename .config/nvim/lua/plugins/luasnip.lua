return {
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		-- build = "make install_jsregexp",
		opts = {
			-- some opts
		},
		lazy = true,
	},
	{
		require("luasnip").config.set_config({ -- Setting LuaSnip config

			-- Enable autotriggered snippets
			enable_autosnippets = true,

			-- Use Tab (or some other key if you prefer) to trigger visual selection
			store_selection_keys = "<Tab>",

			-- Update repeated nodes while typing
			update_events = "TextChanged,TextChangedI",

			history = true,
		}),
		require("luasnip").setup({
			ft_func = require("luasnip.extras.filetype_functions").from_pos_or_filetype,
			load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
				markdown = { "latex", "tex" },
			}),
		}),
		require("luasnip").config.setup({ enable_autosnippets = true }),
		vim.cmd([[
            " Expand or jump in insert mode
            " imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
            " smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
		imap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
		smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'


            " Jump backward through snippet tabstops with Shift-Tab
            imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
            smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'

            " Cycle forward through choice nodes with Control-f
            imap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
            smap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
        ]]),
	},
	{
		-- Lazy-load snippets, i.e. only load when required, e.g. for a given filetype
  	require("luasnip.loaders.from_lua").lazy_load({ paths = { "./lua/snippets/" } })
	},
}
