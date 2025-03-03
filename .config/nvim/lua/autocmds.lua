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

-- Functions to run script to collect TODO items from daily notes
local function run_todo_collect()
    -- Double-check mode before running (can be useful if there was a race condition)
    if vim.fn.mode() == "i" then
        return
    end
    vim.fn.jobstart({ "/opt/homebrew/bin/bash", os.getenv("HOME") .. "/.dotfiles/scripts/todo-collect"})
end

local collect_timer = nil
local function reset_collect_timer()
    if collect_timer then
        collect_timer:stop()
    end
    collect_timer = vim.loop.new_timer()
    collect_timer:start(5000, 0, vim.schedule_wrap(run_todo_collect))  -- X time in ms
end

-- On write, start (or reset) timer — but only if NOT in Insert mode
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.expand("$VAULT") .. "/notes/diary/*.md",
    callback = function()
        if vim.fn.mode() == "i" then
            return
        end
        reset_collect_timer()
    end,
})

-- On leaving Insert mode, reset timer (because user paused writing)
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = vim.fn.expand("$VAULT") .. "/notes/diary/*.md",
    callback = function()
        reset_collect_timer()
    end,
})


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
