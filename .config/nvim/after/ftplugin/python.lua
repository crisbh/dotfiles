--  Overrules
--  For more informartion, check :h ftplugin-overrule
--

-- Adapts make keybinding to python files
vim.api.nvim_set_keymap(
	"n",
	"<leader>cc",
	":w <bar> exec '!python3 '.shellescape('%')<CR>",
	{ noremap = true, silent = true }
)
