return {
  'vimwiki/vimwiki',
  enable = false,
  lazy = true, -- Use false to Always load vimwiki during startup
  -- event = "BufEnter *.md",
  keys = { '<leader>ww' },
  init = function()
    vim.g.vimwiki_list = {
      {
        path = '$VAULT',
        diary_rel_path = 'notes/diary',
        syntax = 'markdown',
        ext = '.md',
      },
    }
    vim.g.vimwiki_ext2syntax = {
      ['.md'] = 'markdown',
      ['.markdown'] = 'markdown',
      ['.mdown'] = 'markdown',
    }
    --      vim.g.vimwiki_folding = ""
    vim.g.vimwiki_global_ext = 0
    vim.g.vimtex_fold_enabled = true
    vim.g.tex_flavor = 'latex'
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_quickfix_mode = 0
    vim.g.tex_conceal = 'abdgms'
  end,
}
