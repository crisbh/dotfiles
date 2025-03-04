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


return
  {
    s({trig = "doc"},
      fmt(
        [[
        # NAME
        # 		{} - {}
        # 
        # SYNOPSIS
        # 		{} {}

        {}
        ]],
        {
          i(1, "name"),
          i(2, "description"),
          rep(1),
          i(3, "usage"),
          i(0),
        }
      ),
      {condition = conds_expand.line_begin}
    ),
    s({
        trig = "forl",
        snippetType="autosnippet"
      },
      fmt(
        [[
        for {} in {}; do
          {}
        done
        ]],
        {
          i(1),
          i(2),
          i(0)
        }
      ),
      {condition = conds_expand.line_begin}
    ),
    s({trig = "ext"},
      fmta(
        [[
        ${<>%.<>}
        ]],
        {
          i(1, "var"),
          i(2, "ext"),
        }
      )
    ),
  }
