-- return {
-- 	"goolord/alpha-nvim",
-- 	dependencies = {
-- 		"nvim-tree/nvim-web-devicons",
-- 		"nvim-lua/plenary.nvim",
-- 	},
-- 	config = function()
-- 		require("alpha").setup(require("alpha.themes.theta").config)
--
-- 	end,
-- }

return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	opts = function()
		local dashboard = require("alpha.themes.dashboard")
		require("alpha.term")
		local arttoggle = false

		-- local logo = {
		-- 	[[                                                    ]],
		-- 	[[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
		-- 	[[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
		-- 	[[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
		-- 	[[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
		-- 	[[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
		-- 	[[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
		-- 	[[                                                    ]],
		-- }

		local logo= {
[[                                __ _._.,._.__]],
[[                          .o8888888888888888P']],
[[                        .d88888888888888888K]],
[[          ,8            888888888888888888888boo._]],
[[         :88b           888888888888888888888888888b.]],
[[          `Y8b          88888888888888888888888888888b.]],
[[            `Yb.       d8888888888888888888888888888888b]],
[[              `Yb.___.88888888888888888888888888888888888b]],
[[                `Y888888888888888888888888888888CG88888P"']],
[[                  `88888888888888888888888888888MM88P"']],
[[ "Y888K    "Y8P""Y888888888888888888888888oo._""""]],
[[   88888b    8    8888`Y88888888888888888888888oo.]],
[[   8"Y8888b  8    8888  ,8888888888888888888888888o,]],
[[   8  "Y8888b8    8888""Y8`Y8888888888888888888888b.]],
[[   8    "Y8888    8888   Y  `Y8888888888888888888888]],
[[   8      "Y88    8888     .d `Y88888888888888888888b]],
[[ .d8b.      "8  .d8888b..d88P   `Y88888888888888888888]],
[[                                  `Y88888888888888888b.]],
[[                   "Y888P""Y8b. "Y888888888888888888888]],
[[                     888    888   Y888`Y888888888888888]],
[[                     888   d88P    Y88b `Y8888888888888]],
[[                     888"Y88K"      Y88b dPY8888888888P]],
[[                     888  Y88b       Y88dP  `Y88888888b]],
[[                     888   Y88b       Y8P     `Y8888888]],
[[                   .d888b.  Y88b.      Y        `Y88888]],
[[                                                  `Y88K]],
[[                                                    `Y8]],
[[                                                      ']],
		}

		local art = {
			-- { name, width, height }
			{ "myNiceBackground", 62, 17 },
		}

		if arttoggle == true then
			dashboard.opts.opts.noautocmd = true
			dashboard.section.terminal.opts.redraw = true
			local path = vim.fn.stdpath("config") .. "/assets/"
			-- local random = math.random(1, #art)
			local currentart = art[1]
			dashboard.section.terminal.command = "cat " .. path .. currentart[1]

			dashboard.section.terminal.width = currentart[2]
			dashboard.section.terminal.height = currentart[3]

			dashboard.opts.layout = {
				dashboard.section.terminal,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				dashboard.section.footer,
			}
		else
			dashboard.section.header.val = logo
		end
		dashboard.section.buttons.val = {
			dashboard.button("f f", " " .. "Find files", ":Telescope find_files <CR>"),
			dashboard.button("f o", "󰚰 " .. "Find recent files", ":Telescope oldfiles <CR>"),
			dashboard.button("LDR f v", " " .. "Find vault files"),
			dashboard.button("LDR f h", "󰮦 " .. "Find help"),
			dashboard.button("l", "󰵆 " .. "Lazy", ":Lazy <CR>"),
			dashboard.button("m", " " .. "Mason", ":Mason <CR>"),
		}
		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButtons"
			button.opts.hl_shortcut = "AlphaShortcut"
		end
		dashboard.section.header.opts.hl = "Function"
		dashboard.section.buttons.opts.hl = "Identifier"
		dashboard.section.footer.opts.hl = "Function"
		dashboard.opts.layout[1].val = 4
		return dashboard
	end,
	config = function(_, dashboard)
		if vim.o.filetype == "lazy" then
			vim.cmd.close()
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					require("lazy").show()
				end,
			})
		end
		require("alpha").setup(dashboard.opts)
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyVimStarted",
			callback = function()
				local v = vim.version()
				local dev = ""
				if v.prerelease == "dev" then
					dev = "-dev+" .. v.build
				else
					dev = ""
				end
				local version = v.major .. "." .. v.minor .. "." .. v.patch .. dev
				local stats = require("lazy").stats()
				local plugins_count = stats.loaded .. "/" .. stats.count
				local ms = math.floor(stats.startuptime + 0.5)
				local time = vim.fn.strftime("%H:%M:%S")
				local date = vim.fn.strftime("%d.%m.%Y")
				local line1 = " " .. plugins_count .. " plugins loaded in " .. ms .. "ms"
				local line2 = "󰃭 " .. date .. "  " .. time
				local line3 = " " .. version

				local line1_width = vim.fn.strdisplaywidth(line1)
				local line2Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line2)) / 2) .. line2
				local line3Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line3)) / 2) .. line3

				dashboard.section.footer.val = {
					line1,
					line2Padded,
					line3Padded,
				}
				pcall(vim.cmd.AlphaRedraw)
			end,
		})
	end,
}
