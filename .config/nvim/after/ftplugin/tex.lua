--  Overrules
--  For more informartion, check :h ftplugin-overrule
--

-- Adapts make keybinding to tex files
vim.api.nvim_set_keymap(
	"n",
	"<leader>cc",
	":VimtexCompile <CR>",
	{ desc = 'Compile TeX', noremap = true, silent = true }
)
