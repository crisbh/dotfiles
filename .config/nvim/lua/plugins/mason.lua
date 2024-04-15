return {
  { 'williamboman/mason.nvim', opts = { PATH = 'append' } },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'clangd',
        'cssls',
        'html',
        'intelephense',
        'marksman',
        'neocmake',
        'julials',
        'pyright',
        'lua_ls',
        'texlab',
        'tsserver',
        'yamlls',
      },
    },
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      ensure_installed = {
        'bash',
        'cppdbg',
        'python',
      },
    },
  },
}
