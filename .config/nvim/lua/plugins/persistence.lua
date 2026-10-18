-- Reopen where you left off: sessions are saved per working directory on exit
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    {
      "<leader>ss",
      function()
        require("persistence").load()
      end,
      desc = "Restore [S]ession for this directory",
    },
    {
      "<leader>sl",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore [L]ast session",
    },
    {
      "<leader>sd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't save this [S]ession on exit",
    },
  },
}
