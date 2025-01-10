local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
-- local conds_expand = require("luasnip.extras.conditions.expand")
local conds_expand = require("luasnip.extras.expand_conditions")

-- the `get_visual` function
-- ----------------------------------------------------------------------------
-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
local get_visual = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else  -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end


return
{
  -- GENERIC HEADER INCLUDE
  s({trig = "hh", snippetType="autosnippet"},
    fmt(
      [[#include <{}.h>]],
      { 
        d(1, get_visual)
      }
    ),
    {condition = conds_expand.line_begin}
  ),
  -- STDIO HEADER
  s({trig = "hio", snippetType="autosnippet"},
    { t('#include <stdio.h>') },
    {condition = conds_expand.line_begin}
  ),
  -- STDLIB HEADER
  s({trig = "hlib", snippetType="autosnippet"},
    { t('#include <stdlib.h>') },
    {condition = conds_expand.line_begin}
  ),
  -- STRING HEADER
  s({trig = "hstr", snippetType="autosnippet"},
    { t('#include <string.h>') },
    {condition = conds_expand.line_begin}
  ),
}
