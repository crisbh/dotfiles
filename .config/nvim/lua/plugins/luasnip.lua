return {
  'L3MON4D3/LuaSnip',
  opts = {
    enable_autosnippets = true,
  },
  config = function()
    require('luasnip.loaders.from_lua').lazy_load { paths = { '../snippets' } } -- load snippets paths
  end,
}
