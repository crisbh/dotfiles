return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      {
        'andymass/vim-matchup',
        init = function()
          vim.g.matchup_matchparen_deferred = 1
        end,
      },
    },
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'fortran', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        disable = {'tex', 'latex'},
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      matchup = { enable = true },
      rainbow = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            aA = '@attribute.outer',
            iA = '@attribute.inner',
            aB = '@block.outer',
            iB = '@block.inner',
            aD = '@conditional.outer',
            iD = '@conditional.inner',
            aF = '@function.outer',
            iF = '@function.inner',
            aL = '@loop.outer',
            iL = '@loop.inner',
            aP = '@parameter.outer',
            iP = '@parameter.inner',
            aR = '@regex.outer',
            iR = '@regex.inner',
            aX = '@class.outer',
            iX = '@class.inner',
            aS = '@statement.outer',
            iS = '@statement.outer',
            aN = '@number.inner',
            iN = '@number.inner',
            aC = '@comment.outer',
            iC = '@comment.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']b'] = { query = '@block.outer', desc = 'Next block start' },
            [']f'] = { query = '@function.outer', desc = 'Next function start' },
            [']p'] = { query = '@parameter.outer', desc = 'Next parameter start' },
            [']x'] = { query = '@class.outer', desc = 'Next class start' },
            [']c'] = { query = '@comment.outer', desc = 'Next comment start' },
          },
          goto_next_end = {
            [']B'] = { query = '@block.outer', desc = 'Next block end' },
            [']F'] = { query = '@function.outer', desc = 'Next function end' },
            [']P'] = { query = '@parameter.outer', desc = 'Next parameter end' },
            [']X'] = { query = '@class.outer', desc = 'Next class end' },
            [']C'] = { query = '@comment.outer', desc = 'Next comment end' },
          },
          goto_previous_start = {
            ['[b'] = { query = '@block.outer', desc = 'Previous block start' },
            ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
            ['[p'] = { query = '@parameter.outer', desc = 'Previous parameter start' },
            ['[x'] = { query = '@class.outer', desc = 'Previous class start' },
            ['[c'] = { query = '@comment.outer', desc = 'Previous comment start' },
          },
          goto_previous_end = {
            ['[B'] = { query = '@block.outer', desc = 'Previous block end' },
            ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
            ['[P'] = { query = '@parameter.outer', desc = 'Previous parameter end' },
            ['[X'] = { query = '@class.outer', desc = 'Previous class end' },
            ['[C'] = { query = '@comment.outer', desc = 'Previous comment end' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['>B'] = { query = '@block.outer', desc = 'Swap next block' },
            ['>F'] = { query = '@function.outer', desc = 'Swap next function' },
            ['>P'] = { query = '@parameter.inner', desc = 'Swap next parameter' },
          },
          swap_previous = {
            ['<B'] = { query = '@block.outer', desc = 'Swap previous block' },
            ['<F'] = { query = '@function.outer', desc = 'Swap previous function' },
            ['<P'] = { query = '@parameter.inner', desc = 'Swap previous parameter' },
          },
        },
        lsp_interop = {
          enable = true,
          border = 'single',
          peek_definition_code = {
            ['<leader>lp'] = { query = '@function.outer', desc = '[P]eek function definition' },
            ['<leader>lP'] = { query = '@class.outer', desc = '[P]eek class definition' },
          },
        },
      },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
}
