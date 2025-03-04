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



-- Return snippet tables
return
{
----------------
-- INDICES --
----------------
  -- SUPERSCRIPT
  s({trig = "([%w%)%]%}])'", wordTrig=false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SUBSCRIPT
  s({trig = "([%w%)%]%}]);", wordTrig=false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SUBSCRIPT AND SUPERSCRIPT
  s({trig = "([%w%)%]%}])__", wordTrig=false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>^{<>}_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
      }
    ),
    {condition = in_mathzone}
  ),
  -- TEXT SUBSCRIPT
  s({trig = 'sd', snippetType="autosnippet", wordTrig=false},
    fmta("_{\\mathrm{<>}}",
      { d(1, get_visual) }
    ),
    {condition = in_mathzone}
  ),
  -- SUPERSCRIPT SHORTCUT
  -- Places the first alphanumeric character after the trigger into a superscript.
  s({trig = '([%w%)%]%}])"([%w])', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        f( function(_, snip) return snip.captures[2] end ),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SUBSCRIPT SHORTCUT
  -- Places the first alphanumeric character after the trigger into a subscript.
  s({trig = '([%w%)%]%}]):([%w])', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        f( function(_, snip) return snip.captures[2] end ),
      }
    ),
    {condition = in_mathzone}
  ),
  -- EULER'S NUMBER SUPERSCRIPT SHORTCUT
  s({trig = '([^%a])ee', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>e^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual)
      }
    ),
    {condition = in_mathzone}
  ),
  -- ZERO SUBSCRIPT SHORTCUT
  s({trig = '([%a%)%]%}])00', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("0")
      }
    ),
    {condition = in_mathzone}
  ),
  -- MINUS ONE SUPERSCRIPT SHORTCUT
  s({trig = '([%a%)%]%}])11', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("-1")
      }
    ),
    {condition = in_mathzone}
  ),
  -- i SUBSCRIPT SHORTCUT (since jk triggers snippet jump forward)
  s({trig = '([%a%)%]%}])II', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("i")
      }
    ),
    {condition = in_mathzone}
  ),
  -- j SUBSCRIPT SHORTCUT (since jk triggers snippet jump forward)
  s({trig = '([%a%)%]%}])jj', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("j")
      }
    ),
    {condition = in_mathzone}
  ),
  -- ij SUBSCRIPT SHORTCUT (recall that jk triggers snippet jump forward)
  s({trig = '([%a%)%]%}])ij', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("ij")
      }
    ),
    {condition = in_mathzone}
  ),
  s({trig = '([%a%)%]%}])IJ', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("ij")
      }
    ),
    {condition = in_mathzone}
  ),
  -- ab SUBSCRIPT SHORTCUT 
  s({trig = '([%a%)%]%}])ab', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("ab")
      }
    ),
    {condition = in_mathzone}
  ),
  -- ab SUPERSCRIPT
  s({trig = '([%a%)%]%}])AB', wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("ab")
      }
    ),
    {condition = in_mathzone}
  ),
  -- PLUS SUPERSCRIPT SHORTCUT
  s({trig = '([%a%)%]%}])%+%+', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("+")
      }
    ),
    {condition = in_mathzone}
  ),
  -- COMPLEMENT SUPERSCRIPT
  s({trig = '([%a%)%]%}])CC', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("\\complement")
      }
    ),
    {condition = in_mathzone}
  ),
  -- CONJUGATE (STAR) SUPERSCRIPT SHORTCUT
  s({trig = '([%a%)%]%}])%*%*', regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        t("*")
      }
    ),
    {condition = in_mathzone}
  ),
----------------
-- INDICES --
----------------
  -- VECTOR, i.e. \vec
  s({trig = "([^%a])vv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\vec{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
----------------
-- ACCENTS & SIMILAR SYMBOL MODIFICATIONS --
----------------
  --postfixes for vectors, hats, etc. The match pattern is '\\' plus the default (so that hats get put on greek letters,e.g.)
  postfix({trig="vec", match_pattern = [[[\\%w%.%_%-%"%']+$]] ,snippetType="autosnippet",dscr="postfix vec when in math mode"},
      {l("\\vec{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ),
  postfix({trig="hat", match_pattern = [[[\\%w%.%_%-%"%']+$]], snippetType="autosnippet",dscr="postfix hat when in math mode"},
      {l("\\hat{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ) ,
  postfix({trig="dot", match_pattern = [[[\\%w%.%_%-%"%']+$]], snippetType="autosnippet",dscr="postfix hat when in math mode"},
      {l("\\dot{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ) ,
  postfix({trig="doot", match_pattern = [[[\\%w%.%_%-%"%']+$]], snippetType="autosnippet",dscr="postfix hat when in math mode"},
      {l("\\ddot{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ) ,
  postfix({trig="bar", match_pattern = [[[\\%w%.%_%-%"%']+$]] ,snippetType="autosnippet",dscr="postfix vec when in math mode"},
      {l("\\bar{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ),
  postfix({trig="til", match_pattern = [[[\\%w%.%_%-%"%']+$]] ,snippetType="autosnippet",dscr="postfix vec when in math mode"},
      {l("\\tilde{" .. l.POSTFIX_MATCH .. "}")}, 
      { condition=in_mathzone }
  ),
  -- DEFAULT UNIT VECTOR WITH SUBSCRIPT, i.e. \unitvector_{}
  s({trig = "([^%a])ue", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\unitvector_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- UNIT VECTOR WITH HAT, i.e. \uvec{}
  s({trig = "([^%a])uv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\uvec{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- MATRIX, i.e. \vec
  s({trig = "([^%a])mt", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\mat{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- FRACTION
  s({trig = "([^%a])ff", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\frac{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
        i(2),
      }
    ),
    {condition = in_mathzone}
  ),
  -- ANGLE
  s({trig = "([^%a])gg", regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>\\ang{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- ABSOLUTE VALUE
  s({trig = "([^%a])aa", regTrig = true, wordTrig = false, snippetType="autosnippet"},
    fmta(
      "<>\\abs{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SQUARE ROOT
  s({trig = "([^%\\])sq", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\sqrt{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- BINOMIAL SYMBOL
  s({trig = "([^%\\])bnn", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\binom{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
      }
    ),
    {condition = in_mathzone}
  ),
  -- LOGARITHM WITH BASE SUBSCRIPT
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a%\\])ll", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\log_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
----------------
-- DERIVATIVES --
----------------
  -- DERIVATIVE with denominator only
  s({trig = "([^%a])dV", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\dvOne{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- DERIVATIVE with numerator and denominator
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a])dvv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\dv{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2)
      }
    ),
    {condition = in_mathzone}
  ),
  -- Derivative d/dx
  s({trig = "([^%a])ddx", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "\\frac{d <>}{dx}",
      {
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
  -- Derivative d/dt
  s({trig = "([^%a])ddt", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "\\frac{d<>}{dt}",
      {
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
  -- DERIVATIVE with numerator, denominator, and higher-order argument
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a])ddv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\dvN{<>}{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
        i(3),
      }
    ),
    {condition = in_mathzone}
  ),
  -- PARTIAL DERIVATIVE with denominator only
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a])pV", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\pdvOne{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    ),
    {condition = in_mathzone}
  ),
  -- PARTIAL DERIVATIVE with numerator and denominator
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a])pvv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\pdv{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2)
      }
    ),
    {condition = in_mathzone}
  ),
  -- Derivative d/dx
  s({trig = "([^%a])pdx", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "\\frac{\\partial d<>}{\\partial x}",
      {
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
  -- Derivative d/dt
  s({trig = "([^%a])pdt", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "\\frac{\\partial d<>}{\\partial t}",
      {
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
  -- PARTIAL DERIVATIVE with numerator, denominator, and higher-order argument
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "([^%a])ppv", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\pdvN{<>}{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
        i(3),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SUM with lower limit
  s({trig = "([^%a])sM", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\sum_{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
      }
    ),
    {condition = in_mathzone}
  ),
  -- SUM with upper and lower limit
  s({trig = "([^%a])smm", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\sum_{<>}^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
      }
    ),
    {condition = in_mathzone}
  ),
  -- INTEGRAL with upper and lower limit
  s({trig = "([^%a])intt", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\int_{<>}^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2),
      }
    ),
    {condition = in_mathzone}
  ),
  s({trig=";I",snippetType="autosnippet",desc="integral with infinite or inserted limits",wordTrig=false},
      fmta([[
          <>
          ]],
          {
          c(1,{
              t("\\int_{-\\infty}^\\infty"),
              sn(nil,fmta([[ \int_{<>}^{<>} ]],{i(1),i(2)})),
              })
          }
      ),
    {condition = in_mathzone}
  ),
  -- BOXED command
  s({trig = "([^%a])bb", wordTrig = false, regTrig = true, snippetType="autosnippet"},
    fmta(
      "<>\\boxed{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual)
      }
    ),
    {condition = in_mathzone}
  ),
  --
  -- BEGIN STATIC SNIPPETS
  --

  -- DIFFERENTIAL, i.e. \diff
  -- NOTE: Has to be defined somewhere in the TeX project
  s({trig = "df", snippetType="autosnippet", snippetType="autosnippet"},
    {
      t("\\diff"),
    },
    {condition = in_mathzone}
  ),
  -- BASIC INTEGRAL SYMBOL, i.e. \int
  s({trig = "in1", snippetType="autosnippet"},
    {
      t("\\int"),
    },
    {condition = in_mathzone}
  ),
  -- DOUBLE INTEGRAL, i.e. \iint
  s({trig = "in2", snippetType="autosnippet"},
    {
      t("\\iint"),
    },
    {condition = in_mathzone}
  ),
  -- TRIPLE INTEGRAL, i.e. \iiint
  s({trig = "in3", snippetType="autosnippet"},
    {
      t("\\iiint"),
    },
    {condition = in_mathzone}
  ),
  -- CLOSED SINGLE INTEGRAL, i.e. \oint
  s({trig = "oi1", snippetType="autosnippet"},
    {
      t("\\oint"),
    },
    {condition = in_mathzone}
  ),
  -- CLOSED DOUBLE INTEGRAL, i.e. \oiint
  s({trig = "oi2", snippetType="autosnippet"},
    {
      t("\\oiint"),
    },
    {condition = in_mathzone}
  ),
  -- GRADIENT OPERATOR, i.e. \grad
  -- NOTE: Has to be defined somewhere in the TeX project
  s({trig = "gdd", snippetType="autosnippet"},
    {
      t("\\grad "),
    },
    {condition = in_mathzone}
  ),
  -- CURL OPERATOR, i.e. \curl
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "rot", snippetType="autosnippet"},
    {
      t("\\curl "),
    },
    {condition = in_mathzone}
  ),
  -- DIVERGENCE OPERATOR, i.e. \divergence
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "DI", snippetType="autosnippet"},
    {
      t("\\div "),
    },
    {condition = in_mathzone}
  ),
  -- LAPLACIAN OPERATOR, i.e. \laplacian
  s({trig = "la", snippetType="autosnippet"},
    {
      t("\\nabla^2 "),
    },
    {condition = in_mathzone}
  ),
----------------
-- RELATIONS AND OPERATIONS --
----------------
  -- PARALLEL SYMBOL, i.e. \parallel
  s({trig = "||", snippetType="autosnippet"},
    {
      t("\\parallel"),
    }
  ),
  -- CDOTS, i.e. \cdots
  s({trig = "cdd", snippetType="autosnippet"},
    {
      t("\\cdots"),
    }
  ),
  -- LDOTS, i.e. \ldots
  s({trig = "ldd", snippetType="autosnippet"},
    {
      t("\\ldots"),
    }
  ),
  -- EQUIV, i.e. \equiv
  s({trig = "eqq", snippetType="autosnippet"},
    {
      t("\\equiv "),
    }
  ),
  -- SETMINUS, i.e. \setminus
  s({trig = "stm", snippetType="autosnippet"},
    {
      t("\\setminus "),
    }
  ),
  -- SUBSET, i.e. \subset
  s({trig = "sbb", snippetType="autosnippet"},
    {
      t("\\subset "),
    }
  ),
  -- APPROX, i.e. \approx
  s({trig = "px", snippetType="autosnippet"},
    {
      t("\\approx "),
    },
    {condition = in_mathzone}
  ),
  -- PROPTO, i.e. \propto
  s({trig = "pt", snippetType="autosnippet"},
    {
      t("\\propto "),
    },
    {condition = in_mathzone}
  ),
  -- COLON, i.e. \colon
  -- TODO: Has to be defined somewhere in the TeX project
  s({trig = "::", snippetType="autosnippet"},
    {
      t("\\colon "),
    }
  ),
  -- IMPLIES, i.e. \implies
  s({trig = ">>", snippetType="autosnippet"},
    {
      t("\\implies "),
    }
  ),
  -- DOT PRODUCT, i.e. \cdot
  s({trig = "..", snippetType="autosnippet"},
    {
      t("\\cdot "),
    }
  ),
  -- CROSS PRODUCT, i.e. \times
  s({trig = "xx", snippetType="autosnippet"},
    {
      t("\\times "),
    }
  ),
}
