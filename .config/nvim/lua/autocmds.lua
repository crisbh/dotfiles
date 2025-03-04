-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Ignore externally modified files
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    callback = function()
        vim.cmd("checktime")
    end,
})

-- auto stop auto-compiler if its running
-- vim.api.nvim_create_autocmd("VimLeave", {
-- 	desc = "Stop running auto compiler",
-- 	group = vim.api.nvim_create_augroup("autocomp", { clear = true }),
-- 	pattern = "*",
-- 	callback = function()
-- 		vim.fn.jobstart({ "autocomp", vim.fn.expand("%:p"), "stop" })
-- 	end,
-- })

-----------------------------------------------------------------
-- Functions to run script to collect TODO items from daily notes
-----------------------------------------------------------------

local todo_collect_timer = nil

local function collect_todo_items()
    vim.notify("🔔 Collecting TODOs...")
    vim.fn.jobstart({ "/opt/homebrew/bin/bash", os.getenv("HOME") .. "/.dotfiles/scripts/todo-collect"})
end

local function start_todo_collect_timer()
    if todo_collect_timer then
        vim.loop.timer_stop(todo_collect_timer)
    end

    todo_collect_timer = vim.loop.new_timer()
    todo_collect_timer:start(5000, 0, vim.schedule_wrap(function()
        collect_todo_items()
        todo_collect_timer = nil
    end))
end

-- Trigger timer **only after save**
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = os.getenv("VAULT") .. "/notes/diary/*.md",
    callback = function()
        start_todo_collect_timer()
    end
})

-- Reset timer when leaving insert mode (just to prevent weird double-fires)
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = os.getenv("VAULT") .. "/notes/diary/*.md",
    callback = function()
        if todo_collect_timer then
            vim.loop.timer_stop(todo_collect_timer)
            todo_collect_timer = nil
        end
    end
})

-----------------------------------------------------------------
-----------------------------------------------------------------

-- text like documents enable wrap and spell
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "markdown", "text", "plaintex" },
	group = vim.api.nvim_create_augroup("auto_spell", { clear = true }),
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
		-- vim.opt_local.relativenumber = false
	end,
})

-- Disable line numbering for pure text documents
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "plaintex" },
	group = vim.api.nvim_create_augroup("remove_lines", { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

--
-- Settings for terminal insider neovim (from TJ)
local set = vim.opt_local

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", {}),
	callback = function()
		set.number = false
		set.relativenumber = false
		set.scrolloff = 0
		vim.bo.filetype = "terminal"
	end,
})

------------------------------------
--- Skeleton files ---
------------------------------------

-- Bash scripts
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.sh",
	group = vim.api.nvim_create_augroup("create_skeletons_bash", { clear = true }),
	command = "0r ~/.skeletons/skeleton-bash.sh",
})

-- make file
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*Makefile*",
	group = vim.api.nvim_create_augroup("create_skeletons_makefile", { clear = true }),
	command = "0r ~/.skeletons/skeleton-workflow-makefile",
})

-- python
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.py",
	group = vim.api.nvim_create_augroup("create_skeletons_python", { clear = true }),
	command = "0r ~/.skeletons/skeleton-python.py",
})

-- c main
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*main.c",
	group = vim.api.nvim_create_augroup("create_skeletons_c_main", { clear = true }),
	command = "0r ~/.skeletons/skeleton-c-main.c",
})

-- Exam class
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "pregunta-*.tex",
	group = vim.api.nvim_create_augroup("create_skeleton_exam", { clear = true }),
	command = "0r ~/.skeletons/skeleton-exam.tex",
})

-- Beamer presentations
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*beamer.tex",
	group = vim.api.nvim_create_augroup("create_skeletons_beamer", { clear = true }),
	command = "0r ~/.skeletons/skeleton-beamer.tex",
})
