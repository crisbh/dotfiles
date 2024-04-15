-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- auto stop auto-compiler if its running
vim.api.nvim_create_autocmd('VimLeave', {
  desc = 'Stop running auto compiler',
  group = vim.api.nvim_create_augroup('autocomp', { clear = true }),
  pattern = '*',
  callback = function()
    vim.fn.jobstart { 'autocomp', vim.fn.expand '%:p', 'stop' }
  end,
})

-- text like documents enable wrap and spell
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'gitcommit', 'markdown', 'text', 'plaintex' },
  group = vim.api.nvim_create_augroup('auto_spell', { clear = true }),
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.relativenumber = false
  end,
})

-- Disable line numbering for pure text documents
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'text', 'plaintex' },
  group = vim.api.nvim_create_augroup('remove_lines', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

------------------------------------
--- Skeleton files ---
------------------------------------

-- Bash scripts
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*.sh',
  group = vim.api.nvim_create_augroup('create_skeletons_sh', { clear = true }),
  command = '0r ~/.skeletons/skeleton.sh',
})

-- Beamer presentations
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*beamer.tex',
  group = vim.api.nvim_create_augroup('create_skeletons_beamer', { clear = true }),
  command = '0r ~/.skeletons/skeleton-beamer.tex',
})
