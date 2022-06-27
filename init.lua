local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
  impatient.enable_profile()
end

for _, source in ipairs {
  "core.utils",
  "core.options",
  "core.plugins",
  "core.autocmds",
  "core.mappings",
  "core.ui",
  "configs.which-key-register",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then
    vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault)
  end
end

-- @TODO merge with astronvim
-- vimwiki config
vim.g.vimwiki_list = {{path = '~/Dropbox/vimwiki', syntax = 'markdown', ext = '.md'}}
--vim.g.vimwiki_ext2syntax = {{'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}}

-- vimtex config
vim.g.vimtex_fold_enabled = true
vim.g.tex_flavor='latex'
vim.g.vimtex_view_method='zathura'
vim.g.vimtex_quickfix_mode=0
vim.g.tex_conceal='abdgms'

-------------------------------------------------------------------------------
astronvim.conditional_func(astronvim.user_plugin_opts("polish", nil, false))
