return {
  {
    "lervag/vimtex",
    lazy = true,
    ft = "tex",
    event = "BufEnter *.tex",
    init = function()
      -- General settings
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_imaps_enabled = 0
      -- vim.g.vimtex_fold_enabled = true
      -- View settings
      -- vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
      -- vim.g.vimtex_viewer_options = '--fork'
      -- vim.g.vimtex_viewer_options = '--synctex-forward $LINE:$COLUMN:$PDF $TEX'
      vim.g.vimtex_view_continuous = 1
      -- Quickfix settings
      vim.g.vimtex_quickfix_mode=0
      vim.g.vimtex_quickfix_open_on_warning = 0 --  don't open quickfix if there are only warnings
      vim.g.vimtex_quickfix_ignore_filters = {"Underfull","Overfull", "LaTeX Warning: .\\+ float specifier changed to", "Package hyperref Warning: Token not allowed in a PDF string"}
    end,
  },
}
