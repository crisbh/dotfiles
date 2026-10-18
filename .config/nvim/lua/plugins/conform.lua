-- Filetypes without a standard style: format on demand only (<leader>fb)
local no_format_on_save = { c = true, cpp = true, cuda = true }

return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fb",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat [B]uffer",
      },
      {
        "<leader>tf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save " .. (vim.g.disable_autoformat and "off" or "on"))
        end,
        desc = "[T]oggle [F]ormat on save",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or no_format_on_save[vim.bo[bufnr].filetype] then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Sort imports, then format; both read [tool.ruff] from pyproject.toml
        python = { "ruff_organize_imports", "ruff_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        cuda = { "clang-format" },
      },
    },
  },
}
