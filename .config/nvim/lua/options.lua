-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, you can see `:help option-list`

vim.opt.title = true -- set terminal title to the filename and path
vim.opt.termguicolors = true -- enable 24-bit RGB color in the TUI

-- Make relative line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

vim.opt.fillchars = { eob = " " } -- disable `~` on nonexistent lines

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0 -- hide command line unless needed

-- Enable break indent
vim.opt.breakindent = true
vim.opt.preserveindent = true -- preserve indent structure as much as possible
vim.opt.textwidth = 80
vim.opt.tabstop = 2 -- number of space in a tab
vim.opt.shiftwidth = 2 -- number of space inserted for indentation
vim.opt.wrap = false -- disable wrapping of lines longer than the width of window
vim.opt.whichwrap = "b,s,<,>,[,]" -- Motions that will wrap to prev/next line

-- Save undo history
vim.opt.undofile = true
vim.opt.history = 100 -- number of commands to remember in a history table

-- disable making a backup before overwriting a file
vim.opt.writebackup = false
vim.opt.backup = false
vim.opt.swapfile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 50

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 6
