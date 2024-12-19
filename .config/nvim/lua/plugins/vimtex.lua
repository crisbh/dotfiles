return {
  {
    "lervag/vimtex",
    lazy = true,
    ft = "tex",
    event = "BufEnter *.tex",
    init = function()
      vim.g.vimtex_fold_enabled = true
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "zathura"
      -- vim.g.vimtex_viewer_options = '--fork'
      vim.g.vimtex_viewer_options = '--synctex-forward $LINE:$COLUMN:$PDF $TEX'
      vim.g.vimtex_quickfix_mode=0
      vim.g.vimtex_view_continuous = 1
    end,
  },
}
