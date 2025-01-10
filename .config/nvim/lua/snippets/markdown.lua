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

local line_begin =conds_expand.line_begin
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
return
  {
    -- Fenced block of code
    s({trig="cc", snippetType="autosnippet"},
      fmta(
        [[
        ```<>
        <>
        ```

      ]],
        {
          i(1),
          d(2, get_visual),
        }
      ),
      {condition = line_begin}
    ),
    -- TODO NOTE
    s({trig="TODOO", snippetType="autosnippet"},
      {
        t("**TODO:** "),
      }
    ),
    -- LINK
    s({trig="ln", wordTrig=true, snippetType="autosnippet"},
      fmta(
        [[[<>](<>) ]],
        {
          d(1, get_visual),
          i(2),
        }
      )
    ),
    -- BOLDFACE TEXT
    s({trig="bf", snippetType="autosnippet"},
      fmta(
        [[**<>** ]],
        {
          d(1, get_visual),
        }
      )
    ),
    -- ITALIC TEXT
    s({trig="it", snippetType="autosnippet"},
      fmta(
        [[*<>* ]],
        {
          d(1, get_visual),
        }
      )
    ),
    -- SUMMARY/DETAILS HTML for Jekyll
    s({trig="det"},
      fmt(
        [[
        <details>
        <summary>
        {}
        </summary>
        {}
        </details>
        ]],
        {
          i(1),
          i(0)
        }
      ),
      {condition = line_begin}
    ),
    -- MARKDOWNIFY filter for Jekyll
    s({trig="md"},
      fmta(
        [[
        {{
          "
          <>
          "
        | markdownify }}
        ]],
        {
          d(1, get_visual)
        }
      ),
      {condition = line_begin}
    ),
    -- BASH CODE BLOCK
    s({trig="bash"},
      fmta(
        [[
        ```bash
        <>
        ```

        ]],
        {
          d(1, get_visual)
        }
      ),
      {condition = line_begin}
    ),
    -- BASH CODE BLOCK V2
    s({trig="sh", snippetType="autosnippet"},
      fmt(
        [[
        ```bash
        {}
        ```

        ]],
        {
          d(1, get_visual)
        }
      ),
      {condition = line_begin}
    ),
    -- PHP CODE BLOCK
    s({trig="php", snippetType="autosnippet"},
      fmt(
        [[
        ```php
        <?php
        {}
        ```

        ]],
        {
          d(1, get_visual)
        }
      ),
      {condition = line_begin}
    ),
    -- PYTHON CODE BLOCK
    s({trig="py", snippetType="autosnippet"},
      fmt(
        [[
        ```python
        {}
        ```

        ]],
        {
          d(1, get_visual)
        }
      ),
      {condition = line_begin}
    ),
  }


-- TODO: add other blocks, e.g. C, latex, ...
