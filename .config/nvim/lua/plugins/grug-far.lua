-- Project-wide search and replace (VSCode's search sidebar), backed by ripgrep
return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = { headerMaxWidth = 80 },
  keys = {
    {
      "<leader>sr",
      function()
        require("grug-far").open()
      end,
      desc = "[S]earch and [R]eplace in project",
    },
    {
      "<leader>sw",
      function()
        require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
      end,
      desc = "[S]earch and replace current [W]ord",
    },
    {
      "<leader>sf",
      function()
        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
      end,
      desc = "[S]earch and replace in current [F]ile",
    },
  },
}
