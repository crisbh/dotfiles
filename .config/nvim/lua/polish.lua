--[[ Finally, polish ]]

-- Construct the full path using $HOME
local home = os.getenv 'HOME'
local directory = home .. '/Projects'

-- TODO: Add Python Path: needs to split the env PYTHONPATH from : to ,
-- local pythonpath = os.getenv 'PYTHONPATH'
-- vim.o.path = vim.o.path .. ',' .. pythonpath

-- Add directory to Neovim's path
vim.o.path = vim.o.path .. ',' .. directory

-- Yes, we're just executing a bunch of Vimscript using vim.cmd
vim.cmd [[
" Use Tab to expand and jump through snippets
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

" Use Shift-Tab to jump backwards through snippets
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]
