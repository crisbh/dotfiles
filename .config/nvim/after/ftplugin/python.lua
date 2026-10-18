--  Overrules
--  For more informartion, check :h ftplugin-overrule
--

-- Adapts make keybinding to python files
vim.api.nvim_set_keymap(
  "n",
  "<leader>cc",
  ":w <bar> exec '!python3 '.shellescape('%')<CR>",
  { desc = "Run Python", noremap = true, silent = true }
)

-- Let `gf` find dotted imports (`pkg.sub.module` -> pkg/sub/module.py): search
-- the project root, its `src/` layout dir, and the active Python's sys.path so
-- installed packages resolve too
local root = vim.fs.root(0, { "pyproject.toml", "setup.py", "setup.cfg", ".git" })
if root then
  vim.opt_local.path:prepend(root)
  if vim.uv.fs_stat(root .. "/src") then
    vim.opt_local.path:prepend(root .. "/src")
  end
end

-- sys.path is cached per virtualenv; `python3` is whichever interpreter is on PATH
local venv = vim.env.VIRTUAL_ENV or ""
local cache = vim.g.python_sys_path
if not cache or cache.venv ~= venv then
  local python = venv ~= "" and venv .. "/bin/python" or "python3"
  local ok, res = pcall(function()
    return vim.system({ python, "-c", "import sys; print('\\n'.join(p for p in sys.path if p))" }):wait()
  end)
  local paths = ok and res.code == 0 and vim.split(vim.trim(res.stdout), "\n") or {}
  cache = { venv = venv, paths = paths }
  vim.g.python_sys_path = cache
end
vim.opt_local.path:append(cache.paths)

-- Packages whose repo folder has a different name (see pyright's extraPaths)
local shims = vim.fn.expand("~/Projects/.python-shims")
if vim.uv.fs_stat(shims) then
  vim.opt_local.path:append(shims)
end

-- When `gf` can't resolve the name through 'path' (unusual layouts, or the
-- cursor on an imported symbol rather than the module), ask the LSP instead
vim.keymap.set("n", "gf", function()
  local ok, err = pcall(vim.cmd, "normal! gf")
  if ok then
    return
  end
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" }) > 0 then
    vim.lsp.buf.definition()
  else
    vim.notify(tostring(err):match("E%d+:.*") or tostring(err), vim.log.levels.ERROR)
  end
end, { buffer = true, desc = "Go to file, or LSP definition" })
