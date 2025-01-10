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

-- Environment detection:
--

-- Include this `in_mathzone` function at the start of a snippets file...
local in_mathzone = function()
  -- The `in_mathzone` function requires the VimTeX plugin
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
-- Then pass the table `{condition = in_mathzone}` to any snippet you want to
-- expand only in math contexts.


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


local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })


return {
	--[
	-- LuaSnip Snippets
	--]
	-- format snippet
	s("snipf",
	fmta([[ 
    <>({ trig='<>', name='<>', dscr='<>'},
    fmta(<>,
    { <> }
    )<>)<>,]],
	{ c(1, { t("s"), t("autosnippet") }), i(2, "trig"), i(3, "trig"), i(4, "dscr"),
    i(5, "fmt"), i(6, "inputs"), i(7, "opts"), i(0) })
	),
	-- simple text snippet
	s("snipt",
	fmta([[ 
    <>(<>, {t('<>')}<>
    <>)<>,]],
    { c(1, { t("s"), t("autosnippet") }),
    c(2, { i(nil, "trig"), sn(nil, { t("{trig='"), i(1), t("'}") }) }),
    i(3, "text"), i(4, "opts"), i(5), i(0) })
	),
	-- complex node stuff
	autosnippet({ trig = "sch", name = "choice node", dscr = "add choice node" },
    fmta([[
    c(<>, {<>}) 
    ]],
    { i(1), i(0) })
	),
	autosnippet({ trig = "snode", name = "snippet node", dscr = "snippet node" },
    fmta([[
    sn(<>, {<>}) 
    ]],
    { i(1, "nil"), i(0) })
	),
	-- add snippet conditions
	autosnippet("scond",
    fmta([[{ condition = <>, show_condition = <> }]],
    { i(1, "math"), rep(1) })
	),
	-- special stuff - snippet regex, hide, switch priority
    autosnippet({ trig='sreg', name='snip regex', dscr='snip regex (trigEngine, hide from LSP)'},
    fmta([[
    trigEngine="<>", hidden=true
    ]],
    { c(1, {t("pattern"), t("ecma")}) }
    )),
	autosnippet({ trig = "sprio", name = "snip priority", dscr = "Autosnippet to set snippet priority" },
    fmta([[ 
    priority = <>
    ]],
	{ i(1, "1000") })
	),
	autosnippet("shide", { t("hidden = true") }),
}
