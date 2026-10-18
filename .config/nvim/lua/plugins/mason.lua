return {
  { "williamboman/mason.nvim", opts = { PATH = "append" } },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "clangd",
        "cssls",
        "html",
        "intelephense",
        "marksman",
        "neocmake",
        "pyright",
        "lua_ls",
        "bashls",
        "texlab",
        --				"tsserver",
        "yamlls",
      },
    },
  },
  -- nvim-dap and mason-nvim-dap live in plugins/dap.lua
}
