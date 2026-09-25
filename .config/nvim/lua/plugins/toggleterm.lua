return {
  "akinsho/toggleterm.nvim",
  cmd = "ToggleTerm",
  keys = {
    {
      "<leader>gC",
      function()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" or vim.bo.buftype ~= "" then
          vim.notify("Current buffer is not a file", vim.log.levels.WARN)
          return
        end
        -- Save first so the commit matches what is on screen
        vim.cmd("silent update")

        -- Run the dotfiles `commit` script on this file only, in a float that
        -- stays open so the result is visible
        require("toggleterm.terminal").Terminal
          :new({
            cmd = "commit " .. vim.fn.shellescape(file),
            direction = "float",
            dir = "git_dir",
            close_on_exit = false,
            on_open = function(term)
              vim.keymap.set("n", "q", function()
                term:shutdown()
              end, { buffer = term.bufnr, silent = true })
            end,
          })
          :open()
      end,
      desc = "Git [C]ommit current file with scripts/commit",
    },
  },
  opts = {
    terminal_mappings = true,
  },
}
