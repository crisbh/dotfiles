-- Debugging: VSCode-like UI and function keys on top of nvim-dap.
-- mason-nvim-dap installs the adapters and registers default launch configs.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: Step out" },
      { "<F23>", function() require("dap").step_out() end, desc = "Debug: Step out" }, -- <S-F11> in many terminals
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[D]ebug: toggle [B]reakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "[D]ebug: conditional [B]reakpoint",
      },
      { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "[D]ebug: run to [C]ursor" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "[D]ebug: [T]erminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "[D]ebug: toggle [U]I" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "[D]ebug: [E]valuate" },
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "bash", "cppdbg", "python" },
        handlers = {}, -- default setup for every installed adapter
      })

      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- Open the UI when a session starts, close it when it ends
      dap.listeners.after.event_initialized.dapui = dapui.open
      dap.listeners.before.event_terminated.dapui = dapui.close
      dap.listeners.before.event_exited.dapui = dapui.close

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
    end,
  },
}
