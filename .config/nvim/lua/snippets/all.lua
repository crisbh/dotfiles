
-- Place this in ${HOME}/.config/nvim/LuaSnip/all.lua

local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local t = ls.text_node

return {
  -- A snippet that expands the trigger "hi" into the string "Hello, world!".
 s(
    { trig = "hi" },
    { t("Hello, world!") }
  ),

  -- To return multiple snippets, use one `return` statement per snippet file
  -- and return a table of Lua snippets.
  s(
    { trig = "foo" },
    { t("Another snippet.") }
  ),
  s(
    { trig = "today" },
    { t(os.date("%d-%m-%Y")) }
  ),
}

