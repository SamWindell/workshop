-- Module to handle DAP floating terminal
local M = {
    win = nil,
    dap_buf = nil
}

local function is_win_valid()
    return M.win ~= nil and vim.api.nvim_win_is_valid(M.win)
end

local function is_buf_valid()
    return M.dap_buf ~= nil and vim.api.nvim_buf_is_valid(M.dap_buf)
end

local function create_centered_float()
    -- Get the editor's dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calculate window size (80% of screen)
    local win_width = math.floor(width * 0.8)
    local win_height = math.floor(height * 0.8)

    -- Calculate starting position to center the window
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Set up the window configuration
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        zindex = 40,
    }

    -- Create the floating window using the existing buffer or a new one
    if not is_buf_valid() then
        -- If no DAP terminal buffer exists yet, show a message
        local temp_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, { "No DAP terminal available" })
        M.win = vim.api.nvim_open_win(temp_buf, true, opts)
    else
        M.win = vim.api.nvim_open_win(M.dap_buf, true, opts)
    end

    -- Set window-local options
    vim.wo[M.win].winblend = 0
    vim.wo[M.win].number = false
    vim.wo[M.win].relativenumber = false
    vim.wo[M.win].cursorline = false

    return M.win
end

-- Function to close the floating window
local function close_float()
    if is_win_valid() then
        vim.api.nvim_win_close(M.win, true)
        M.win = nil
    end
end

-- Main toggle function
function M.toggle_dap_float()
    if is_win_valid() then
        close_float()
        return
    end
    create_centered_float()
end

-- Function that DAP will call to create terminal window
local function dap_terminal_win_cmd()
    -- Create or clear buffer for DAP without showing a window
    if not is_buf_valid() then
        M.dap_buf = vim.api.nvim_create_buf(false, true)
    else
        -- Clear existing buffer content
        vim.api.nvim_buf_set_lines(M.dap_buf, 0, -1, false, {})
    end

    -- Return the buffer number and nil for the window
    -- This tells DAP to use this buffer but not create/show a window
    return M.dap_buf, nil
end

-- Configure DAP to use our terminal handler
require('dap').defaults.fallback.terminal_win_cmd = dap_terminal_win_cmd

return M
