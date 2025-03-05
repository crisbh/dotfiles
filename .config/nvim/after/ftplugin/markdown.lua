------------------------------------------------------
-- Navigation of links vimwiki style
------------------------------------------------------
local diary_path = vim.fn.expand("$VAULT/notes/diary")

local function is_markdown_file()
    return vim.bo.filetype == "markdown"
end

-- Combined regex for wikilinks and markdown links
local link_pattern_vim = '\\[\\[[^]]\\+\\]\\]\\|\\[[^]]\\+](\\([^)]*\\))'

local function jump_to_next_link()
    if not is_markdown_file() then return end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_num, col = cursor[1], cursor[2]

    local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    if not line then return end

    -- 1️⃣ First, if cursor is already inside a link, move past it
    local after_current_link = col + 1
    local link_start, link_end

    -- Check if cursor is inside a wikilink
    link_start, link_end = line:find('%[%[[^]]-%]%]', 1)
    while link_start do
        if col >= link_start - 1 and col <= link_end then
            after_current_link = link_end + 1
            break
        end
        link_start, link_end = line:find('%[%[[^]]-%]%]', link_end + 1)
    end

    -- Check if cursor is inside a markdown link (only if no wikilink matched)
    if after_current_link == col + 1 then
        link_start, link_end = line:find('%[[^]]-%]%([^)]-%)', 1)
        while link_start do
            if col >= link_start - 1 and col <= link_end then
                after_current_link = link_end + 1
                break
            end
            link_start, link_end = line:find('%[[^]]-%]%([^)]-%)', link_end + 1)
        end
    end

    -- 2️⃣ Search for next link (start after the current link if found)
    local next_link_start, next_link_end = nil, nil

    next_link_start, next_link_end = line:find('%[%[[^]]-%]%]', after_current_link)

    if not next_link_start then
        next_link_start, next_link_end = line:find('%[[^]]-%]%([^)]-%)', after_current_link)
    end

    if next_link_start then
        vim.api.nvim_win_set_cursor(0, { line_num, next_link_start - 1 })
        return
    end

    -- 3️⃣f no link found in current line, search entire buffer from next line
    local next_pos = vim.fn.searchpos(link_pattern_vim, "nW")
    if next_pos[1] == 0 then
        vim.notify("No more links found!", vim.log.levels.WARN)
    else
        vim.api.nvim_win_set_cursor(0, { next_pos[1], next_pos[2] - 1 })
    end
end

local function jump_to_prev_link()
    if not is_markdown_file() then return end

    local prev_pos = vim.fn.searchpos(link_pattern_vim, "bnW")
    if prev_pos[1] == 0 then
        vim.notify("No previous link found!", vim.log.levels.WARN)
    else
        vim.api.nvim_win_set_cursor(0, { prev_pos[1], prev_pos[2] - 1 })
    end
end

local function open_link_under_cursor()
    if not is_markdown_file() then return end

    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col('.')

    for link_text, link_target in line:gmatch('%[([^]]-)%]%(([^)]-)%)') do
        local start_col, end_col = line:find('%[' .. vim.pesc(link_text) .. '%]%(' .. vim.pesc(link_target) .. '%)')
        if col >= start_col and col <= end_col then
            local full_path = diary_path .. "/" .. link_target .. ".md"
            vim.cmd('edit ' .. full_path)
            return
        end
    end

    for link_target in line:gmatch('%[%[([^]|]-)%]%]') do
        local start_col, end_col = line:find('%[%[' .. vim.pesc(link_target) .. '%]%]')
        if col >= start_col and col <= end_col then
            local full_path = diary_path .. "/" .. link_target .. ".md"
            vim.cmd('edit ' .. full_path)
            return
        end
    end

    vim.notify("No link under cursor!", vim.log.levels.WARN)
end

-- Set keymaps for markdown files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.keymap.set('n', '<Tab>', jump_to_next_link, { buffer = true })
        vim.keymap.set('n', '<S-Tab>', jump_to_prev_link, { buffer = true })
        vim.keymap.set('n', '<CR>', open_link_under_cursor, { buffer = true })
    end
})


------------------------------------------------------
------------------------------------------------------

