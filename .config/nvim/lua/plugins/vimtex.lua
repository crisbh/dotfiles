return {
  {
    "lervag/vimtex",
    event = "BufEnter *.tex",
    init = function()
      vim.g.vimtex_fold_enabled = true
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_mode=0
    end,
  },
}
