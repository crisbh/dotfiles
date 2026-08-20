return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      suggestion = { enabled = false, auto_trigger = false },
      panel = { enabled = false },
      -- filetypes = { markdown = true, gitcommit = true, yaml = true, ["*"] = true },
      filetypes = {
        -- ["*"] = true,
        markdown = true,
        gitcommit = true,
        yaml = true,
        -- disable in prompts/REPLs and special buffers
        TelescopePrompt = false,
        help = false,
        ["dap-repl"] = false,
        ["neo-tree"] = false,
        ["gitrebase"] = true,
      },
    },
    config = function(_, opts)
      local copilot = require("copilot")
      copilot.setup(opts)

      -- Toggle Copilot on and off
      vim.keymap.set("n", "<leader>cO", function()
        vim.cmd("Copilot enable")
        vim.notify("  Copilot Enabled", vim.log.levels.INFO, { title = "Copilot" })
      end, { desc = "Copilot On" })
      vim.keymap.set("n", "<leader>co", function()
        vim.cmd("Copilot disable")
        vim.notify("  Copilot Disabled", vim.log.levels.WARN, { title = "Copilot" })
      end, { desc = "Copilot off" })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}
