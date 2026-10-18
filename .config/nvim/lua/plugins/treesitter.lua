-- nvim-treesitter `main` branch: it only installs parsers and queries.
-- Highlighting, indentation and text objects are wired up here explicitly.

-- Parsers installed up front; anything else is installed the first time a
-- buffer of that filetype is opened (if nvim-treesitter knows the language)
local ensure_installed = {
  "bash",
  "c",
  "cpp",
  "fortran",
  "html",
  "json",
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

-- Filetypes where vim's own syntax is preferred (vimtex handles LaTeX)
local no_highlight = { tex = true, latex = true, plaintex = true }

return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()
      ts.install(ensure_installed)

      local available = nil
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
        callback = function(ev)
          if no_highlight[ev.match] then
            return
          end
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
            return
          end

          -- Auto-install parsers that nvim-treesitter knows about
          if not vim.treesitter.language.add(lang) then
            available = available or ts.get_available()
            if vim.tbl_contains(available, lang) then
              ts.install(lang):await(vim.schedule_wrap(function()
                if vim.api.nvim_buf_is_valid(ev.buf) then
                  pcall(vim.treesitter.start, ev.buf, lang)
                end
              end))
            end
            return
          end

          if pcall(vim.treesitter.start, ev.buf, lang) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- Select: a<X> / i<X>
      local objects = {
        A = { "@attribute.outer", "@attribute.inner" },
        B = { "@block.outer", "@block.inner" },
        D = { "@conditional.outer", "@conditional.inner" },
        F = { "@function.outer", "@function.inner" },
        L = { "@loop.outer", "@loop.inner" },
        P = { "@parameter.outer", "@parameter.inner" },
        R = { "@regex.outer", "@regex.inner" },
        X = { "@class.outer", "@class.inner" },
        S = { "@statement.outer", "@statement.outer" },
        N = { "@number.inner", "@number.inner" },
        C = { "@comment.outer", "@comment.outer" },
      }
      for key, q in pairs(objects) do
        vim.keymap.set({ "x", "o" }, "a" .. key, function()
          select.select_textobject(q[1], "textobjects")
        end, { desc = "Select " .. q[1] })
        vim.keymap.set({ "x", "o" }, "i" .. key, function()
          select.select_textobject(q[2], "textobjects")
        end, { desc = "Select " .. q[2] })
      end

      -- Move: ]x next start, ]X next end, [x previous start, [X previous end.
      -- Comments use ]C/[C only; ]c/[c stay with gitsigns hunks.
      local moves = {
        b = "@block.outer",
        f = "@function.outer",
        p = "@parameter.outer",
        x = "@class.outer",
      }
      local function map_move(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          fn(query, "textobjects")
        end, { desc = desc })
      end
      for key, query in pairs(moves) do
        local name = query:match("@(%w+)")
        map_move("]" .. key, move.goto_next_start, query, "Next " .. name .. " start")
        map_move("]" .. key:upper(), move.goto_next_end, query, "Next " .. name .. " end")
        map_move("[" .. key, move.goto_previous_start, query, "Previous " .. name .. " start")
        map_move("[" .. key:upper(), move.goto_previous_end, query, "Previous " .. name .. " end")
      end
      map_move("]C", move.goto_next_start, "@comment.outer", "Next comment")
      map_move("[C", move.goto_previous_start, "@comment.outer", "Previous comment")

      -- Swap with the next / previous sibling
      local swaps = { B = "@block.outer", F = "@function.outer", P = "@parameter.inner" }
      for key, query in pairs(swaps) do
        local name = query:match("@(%w+)")
        vim.keymap.set("n", ">" .. key, function()
          swap.swap_next(query)
        end, { desc = "Swap next " .. name })
        vim.keymap.set("n", "<" .. key, function()
          swap.swap_previous(query)
        end, { desc = "Swap previous " .. name })
      end
    end,
  },

  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.matchup_matchparen_deferred = 1
    end,
  },

  { -- Sticky scroll: keep the enclosing function/class header visible
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = { max_lines = 3, multiline_threshold = 1 },
    keys = {
      {
        "[k",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to sticky context",
      },
    },
  },
}
