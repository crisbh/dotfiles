-- Git status markers for Telescope file lists.
--
-- `M.path_display` is used as Telescope's `defaults.path_display`, so every
-- file-based picker shows git's status letter in a column before the path.
-- Caches are per picker: `M.reset` runs on `User TelescopeFindPre`.

local M = {}

local hl_for = {
  M = "GitSignsChange",
  R = "GitSignsChange",
  U = "GitSignsChange",
  A = "GitSignsAdd",
  ["?"] = "GitSignsAdd",
  D = "GitSignsDelete",
}

local realpaths = {} -- path -> resolved path (false when it does not exist)
local roots = {} -- dir -> repo root (false when outside a repo)
local statuses = {} -- repo root -> { [abs path] = status letter }

function M.reset()
  realpaths, roots, statuses = {}, {}, {}
end

local function load_status(root)
  local res = vim.system({ "git", "-C", root, "status", "--porcelain=v1", "-z", "--untracked-files=all" }):wait()
  local map = {}
  if res.code ~= 0 then
    return map
  end

  local fields = vim.split(res.stdout, "\0", { plain = true })
  local i = 1
  while i <= #fields do
    local line = fields[i]
    if #line > 3 then
      local x, y = line:sub(1, 1), line:sub(2, 2)
      -- Prefer the worktree state; fall back to the index for staged-only changes
      local letter = y ~= " " and y or x
      map[root .. "/" .. line:sub(4)] = letter
      -- Renames and copies carry the original path in the next field
      if x == "R" or x == "C" then
        i = i + 1
      end
    end
    i = i + 1
  end
  return map
end

function M.status(path)
  local real = realpaths[path]
  if real == nil then
    -- Resolve symlinks such as ~/.config/nvim -> ~/.dotfiles/.config/nvim
    real = vim.uv.fs_realpath(path) or false
    realpaths[path] = real
  end
  if not real then
    return nil
  end

  local dir = vim.fs.dirname(real)
  local root = roots[dir]
  if root == nil then
    root = vim.fs.root(dir, ".git") or false
    roots[dir] = root
  end
  if not root then
    return nil
  end

  statuses[root] = statuses[root] or load_status(root)
  return statuses[root][real]
end

-- Width of the status column in front of each path: the letter plus a space
local col = 2

function M.path_display(opts, path)
  local utils = require("telescope.utils")
  -- Keep the usual truncated display, leaving room for the status column; the
  -- proxy also stops this function recursing
  local proxy = setmetatable({ path_display = { "truncate" }, __prefix = (opts.__prefix or 0) + col }, { __index = opts })
  local display, style = utils.transform_path(proxy, path)

  local abs = path
  if not vim.startswith(path, "/") then
    abs = vim.fs.joinpath(opts.cwd and vim.fs.normalize(opts.cwd) or vim.uv.cwd(), path)
  end

  -- Shift the path's own highlights past the status column
  local shifted = {}
  for _, s in ipairs(style or {}) do
    table.insert(shifted, { { s[1][1] + col, s[1][2] + col }, s[2] })
  end

  -- Clean files get a blank column so file names stay aligned
  local letter = M.status(abs)
  if not letter then
    return string.rep(" ", col) .. display, shifted
  end

  table.insert(shifted, { { 0, 1 }, hl_for[letter] or "GitSignsChange" })
  return letter .. " " .. display, shifted
end

return M
