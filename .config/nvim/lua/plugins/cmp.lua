return {
	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				config = function()
					require("luasnip.loaders.from_lua").lazy_load({ paths = { "./lua/snippets/" } })
					local luasnip = require("luasnip")
					luasnip.config.set_config({
						enable_autosnippets = true,
						store_selection_keys = "<Tab>",
						update_events = "TextChanged,TextChangedI",
						history = true,
					})
					require("luasnip").setup({
						ft_func = require("luasnip.extras.filetype_functions").from_pos_or_filetype,
						load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
							markdown = { "latex", "tex" },
						}),
					})
					require("luasnip").config.setup({ enable_autosnippets = true })

					vim.cmd([[
            " Expand/jump shortcuts (yours)
            imap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
            smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'

            imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
            smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'

            imap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
            smap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
          ]])
				end,
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						lazy = true,
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",

			-- Other sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",

			-- Copilot bridge
			"zbirenbaum/copilot-cmp",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local compare = cmp.config.compare

			-- nvim-cmp setup
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				mapping = cmp.mapping.preset.insert({
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),

				-- Prefer meaningful ordering; include Copilot prioritizer
				sorting = {
					priority_weight = 2,
					comparators = {
						compare.exact,
						compare.score,
						require("copilot_cmp.comparators").prioritize,
						compare.recently_used,
						compare.locality,
						compare.offset,
						compare.order,
					},
				},

				-- Sources: keep LSP & snippets; cap Copilot to reduce noise
				sources = {
					{ name = "nvim_lsp" },
					{ name = "copilot", max_item_count = 3 },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				},

				-- We use cmp menu, not inline ghost text
				experimental = { ghost_text = false },
			})

			-- Large-file guard: drop Copilot for very big buffers (>500KB)
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function(ev)
					local stat = vim.loop.fs_stat(ev.file)
					if stat and stat.size and stat.size > 500 * 1024 then
						cmp.setup.buffer({
							sources = {
								{ name = "nvim_lsp" },
								{ name = "path" },
								{ name = "buffer" },
							},
						})
						vim.schedule(function()
							vim.notify(
								"󰁡 Copilot disabled for this large file",
								vim.log.levels.INFO,
								{ hl = "Comment" }
							)
						end)
					end
				end,
			})
		end,
	},
}
