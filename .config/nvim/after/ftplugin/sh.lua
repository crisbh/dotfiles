--  Overrules
--  For more informartion, check :h ftplugin-overrule
--

-- Adapts make keybinding to bash (shell) scripts
vim.api.nvim_set_keymap(
	"n",
	"<leader>cc",
	":w <bar> exec '!bash '.shellescape('%')<CR>",
	{ desc = 'Run Bash script', noremap = true, silent = true }
)
