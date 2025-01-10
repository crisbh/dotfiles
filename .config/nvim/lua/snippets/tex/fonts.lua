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

local in_text = function() return not in_mathzone() end
--
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



-- Return snippet tables
return {
 -- TYPEWRITER i.e. \texttt
    s({trig = "([^%a])tt", regTrig = true, wordTrig = false, snippetType="autosnippet", priority=2000},
      fmta(
        "<>\\texttt{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      ),
      {condition = in_text}
    ),
    -- ITALIC i.e. \textit
    s({trig = "([^%a])tii", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\textit{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
    -- BOLD i.e. \textbf
    s({trig = "tbb", snippetType="autosnippet"},
      fmta(
        "\\textbf{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- MATH ROMAN i.e. \mathrm
    s({trig = "([^%a])rmm", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\mathrm{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
    -- MATH CALIGRAPHY i.e. \mathcal
    s({trig = "([^%a])mcc", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\mathcal{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
    -- MATH BOLDFACE i.e. \mathbf
    s({trig = "([^%a])mbf", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\mathbf{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
    -- MATH BLACKBOARD i.e. \mathbb
    s({trig = "([^%a])mbb", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\mathbb{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
  -- BOLD MATH
  postfix({trig="bm", match_pattern = [[[\\%w%.%_%-%"%']+$]] ,snippetType="autosnippet",dscr="postfix vec when in math mode"},
      {l("\\bm{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ),
    -- REGULAR TEXT i.e. \text (in math environments)
    s({trig = "([^%a])tee", regTrig = true, wordTrig = false, snippetType="autosnippet"},
      fmta(
        "<>\\text{<>}",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      ),
      { condition = in_mathzone }
    ),
}

