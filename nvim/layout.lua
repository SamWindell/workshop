-- Sidebar + primary/secondary window layout.
--
-- The viewport is conceptually:
--   [ sidebar | primary | secondary? ]   (wide viewport, vertical split)
--   [ sidebar | primary               ]
--               [ secondary?          ]  (narrow viewport, horizontal split)
--
-- "primary" is the leftmost/topmost non-sidebar non-float editable window.
-- "secondary" is the other one when present. Sorting is positional, so the
-- assignment survives most user actions without needing window-local tags.

local M = {}

local SIDEBAR_MIN = 10
local SIDEBAR_MAX = 32
local SIGNCOLUMN_WIDTH = 7
local MIN_BUFFER_WIDTH = 110 + SIGNCOLUMN_WIDTH
local DUAL_PANEL_MIN = MIN_BUFFER_WIDTH * 2 + 1

M.constants = {
    sidebar_min = SIDEBAR_MIN,
    sidebar_max = SIDEBAR_MAX,
    buffer_min = MIN_BUFFER_WIDTH,
    dual_panel_min = DUAL_PANEL_MIN,
}

local function nvim_tree_api()
    local ok, api = pcall(require, 'nvim-tree.api')
    if ok then return api end
    return nil
end

local function is_float(win)
    return vim.api.nvim_win_get_config(win).relative ~= ''
end

local function is_sidebar_win(win)
    local api = nvim_tree_api()
    if not api or not api.tree.is_visible() then return false end
    local buf = vim.api.nvim_win_get_buf(win)
    return api.tree.is_tree_buf(buf)
end

local function is_excluded_buftype(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.bo[buf].buftype
    return bt == 'quickfix' or bt == 'prompt'
end

-- Initial sidebar width for nvim-tree setup.
function M.default_sidebar_cols()
    local total = vim.o.columns
    local cols
    if DUAL_PANEL_MIN < (total - SIDEBAR_MIN) then
        cols = total - DUAL_PANEL_MIN - 1
    else
        cols = total - MIN_BUFFER_WIDTH - 1
    end
    return math.max(SIDEBAR_MIN, math.min(SIDEBAR_MAX, cols))
end

local function sidebar_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not is_float(win) and is_sidebar_win(win) then
            return win
        end
    end
    return nil
end

function M.sidebar_cols()
    local w = sidebar_win()
    if w then return vim.api.nvim_win_get_width(w) end
    return 0
end

-- With `equalalways` on, opening any split equalizes widths across ALL
-- windows, which makes the sidebar grow. Capture its width, run the op, then
-- restore.
local function preserve_sidebar(fn)
    local w = sidebar_win()
    local width = w and vim.api.nvim_win_get_width(w) or nil
    fn()
    if w and width and vim.api.nvim_win_is_valid(w) then
        if vim.api.nvim_win_get_width(w) ~= width then
            vim.api.nvim_win_set_width(w, width)
        end
    end
end

-- Non-float, non-sidebar, non-quickfix windows, sorted leftmost-then-topmost.
local function big_windows()
    local out = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if not is_float(win) and not is_sidebar_win(win) and not is_excluded_buftype(win) then
            table.insert(out, win)
        end
    end
    table.sort(out, function(a, b)
        local pa = vim.api.nvim_win_get_position(a)
        local pb = vim.api.nvim_win_get_position(b)
        if pa[2] ~= pb[2] then return pa[2] < pb[2] end
        return pa[1] < pb[1]
    end)
    return out
end

-- role: "primary" | "secondary" | "other"
-- opts.create: if true, create the window when missing.
function M.get_window(role, opts)
    opts = opts or {}
    local wins = big_windows()

    if role == 'primary' then
        if wins[1] then return wins[1] end
        if not opts.create then return nil end
        preserve_sidebar(function() vim.cmd('vertical rightb new') end)
        return vim.api.nvim_get_current_win()
    end

    if role == 'secondary' then
        if wins[2] then return wins[2] end
        if not opts.create then return nil end
        -- Need a primary first.
        if not wins[1] then
            preserve_sidebar(function() vim.cmd('vertical rightb new') end)
            wins = big_windows()
        end
        vim.api.nvim_set_current_win(wins[1])
        local remaining = vim.o.columns - M.sidebar_cols()
        local cmd = (remaining >= DUAL_PANEL_MIN) and 'rightb vsplit' or 'rightb split'
        preserve_sidebar(function() vim.cmd(cmd) end)
        return vim.api.nvim_get_current_win()
    end

    if role == 'other' then
        if #wins < 2 then return nil end
        local cur = vim.api.nvim_get_current_win()
        if cur == wins[1] then return wins[2] end
        return wins[1]
    end
end

function M.toggle_secondary()
    local sec = M.get_window('secondary')
    if sec then
        vim.api.nvim_win_close(sec, false)
    else
        M.get_window('secondary', { create = true })
    end
end

-- Focus the sidebar; if already in it, close it (smart toggle).
function M.focus_sidebar()
    local api = nvim_tree_api()
    if not api then return end
    local cur = vim.api.nvim_get_current_win()
    if api.tree.is_visible() then
        local buf = vim.api.nvim_win_get_buf(cur)
        if api.tree.is_tree_buf(buf) then
            api.tree.close()
            return
        end
    end
    api.tree.focus()
end

-- Focus the window for `role`, creating it if missing.
function M.focus(role)
    local win = M.get_window(role, { create = true })
    if win then vim.api.nvim_set_current_win(win) end
end

-- Jump between primary and secondary. Falls back to primary if cursor is
-- elsewhere (e.g. in sidebar).
function M.toggle_focus()
    local prim = M.get_window('primary')
    local sec = M.get_window('secondary')
    local cur = vim.api.nvim_get_current_win()
    if cur == prim and sec then
        vim.api.nvim_set_current_win(sec)
    elseif cur == sec and prim then
        vim.api.nvim_set_current_win(prim)
    elseif prim then
        vim.api.nvim_set_current_win(prim)
    end
end

-- Toggleable zoom. When both big windows are open, close the one the cursor
-- *isn't* in and remember its buffer plus the side it was on. When only one
-- is open and we have a stash, recreate the window on the same side and put
-- the stashed buffer back.
local zoom_stash = nil -- { buf, side = "left"|"right"|"top"|"bottom" }

local function detect_side(cur_win, other_win)
    local cp = vim.api.nvim_win_get_position(cur_win)
    local op = vim.api.nvim_win_get_position(other_win)
    if cp[2] == op[2] then
        return op[1] < cp[1] and 'top' or 'bottom'
    end
    return op[2] < cp[2] and 'left' or 'right'
end

local SPLIT_CMD = {
    left   = 'leftabove vsplit',
    right  = 'rightbelow vsplit',
    top    = 'leftabove split',
    bottom = 'rightbelow split',
}

function M.zoom()
    local prim = M.get_window('primary')
    local sec = M.get_window('secondary')
    local cur = vim.api.nvim_get_current_win()

    if prim and sec then
        local other
        if cur == prim then
            other = sec
        elseif cur == sec then
            other = prim
        else
            return
        end
        zoom_stash = {
            buf = vim.api.nvim_win_get_buf(other),
            side = detect_side(cur, other),
        }
        preserve_sidebar(function() vim.api.nvim_win_close(other, false) end)
        return
    end

    if zoom_stash and vim.api.nvim_buf_is_valid(zoom_stash.buf) then
        local cmd = SPLIT_CMD[zoom_stash.side] or 'rightbelow vsplit'
        local stashed_buf = zoom_stash.buf
        local original = vim.api.nvim_get_current_win()
        preserve_sidebar(function() vim.cmd(cmd) end)
        local new_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(new_win, stashed_buf)
        if vim.api.nvim_win_is_valid(original) then
            vim.api.nvim_set_current_win(original)
        end
    end
    zoom_stash = nil
end

-- Close secondary if open. Does not move focus.
function M.close_secondary()
    local sec = M.get_window('secondary')
    if sec then vim.api.nvim_win_close(sec, false) end
end

-- Swap the buffers in primary/secondary. Cursor follows the buffer that was
-- under it.
function M.swap_buffers()
    local prim = M.get_window('primary')
    local sec = M.get_window('secondary')
    if not prim or not sec then return end
    local cur = vim.api.nvim_get_current_win()
    local b1 = vim.api.nvim_win_get_buf(prim)
    local b2 = vim.api.nvim_win_get_buf(sec)
    vim.api.nvim_win_set_buf(prim, b2)
    vim.api.nvim_win_set_buf(sec, b1)
    if cur == prim then
        vim.api.nvim_set_current_win(sec)
    elseif cur == sec then
        vim.api.nvim_set_current_win(prim)
    end
end

-- Place `buf` in the window for `role`, creating the window if needed.
function M.open_buffer(buf, role, opts)
    opts = opts or {}
    local win = M.get_window(role, { create = true })
    if not win then return nil end
    vim.api.nvim_win_set_buf(win, buf)
    if opts.focus then
        vim.api.nvim_set_current_win(win)
    end
    return win
end

-- Flip split orientation when the viewport crosses the dual-panel threshold.
-- Preserves focus.
function M.resize_to_policy()
    local sec = M.get_window('secondary')
    if not sec then return end
    local prim = M.get_window('primary')
    if not prim then return end

    local remaining = vim.o.columns - M.sidebar_cols()
    local prim_col = vim.api.nvim_win_get_position(prim)[2]
    local sec_col = vim.api.nvim_win_get_position(sec)[2]
    local side_by_side = (prim_col ~= sec_col)

    local prev = vim.api.nvim_get_current_win()

    if remaining >= DUAL_PANEL_MIN then
        if not side_by_side then
            preserve_sidebar(function()
                vim.api.nvim_set_current_win(sec)
                vim.cmd('wincmd L')
            end)
        end
    else
        if side_by_side then
            local buf = vim.api.nvim_win_get_buf(sec)
            preserve_sidebar(function()
                vim.api.nvim_win_close(sec, false)
                vim.api.nvim_set_current_win(prim)
                vim.cmd('rightb split')
                vim.api.nvim_win_set_buf(0, buf)
            end)
        end
    end

    if vim.api.nvim_win_is_valid(prev) then
        vim.api.nvim_set_current_win(prev)
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup('user-layout', { clear = true })
    vim.api.nvim_create_autocmd('VimResized', {
        group = group,
        callback = M.resize_to_policy,
    })
    local api = nvim_tree_api()
    if api then
        api.events.subscribe(api.events.Event.TreeOpen, M.resize_to_policy)
        api.events.subscribe(api.events.Event.TreeClose, M.resize_to_policy)
    end
end

return M
