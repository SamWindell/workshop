local M = {}

function M.toggle_dap_repl()
    -- Get the editor's dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    -- Calculate window size (80% of screen)
    local win_width = math.floor(width * 0.8)
    local win_height = math.floor(height * 0.8)

    -- Row/col for centering
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Window options for the floating window
    local winopts = {
        width = win_width,
        height = win_height
    }

    -- Create floating window command
    -- This needs to be a valid Ex command
    local wincmd = string.format(
        "silent keepalt lua vim.api.nvim_open_win(0, true, {relative='editor', row=%d, col=%d, width=%d, height=%d, style='minimal', border='rounded', zindex=40})",
        row, col, win_width, win_height
    )

    require('dap.repl').toggle(winopts, wincmd)

    -- Find and focus the REPL window
    vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == 'dap-repl' then
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end, 10)
end

-- Set up keymapping
vim.keymap.set('n', '<leader>dr', M.toggle_dap_repl, { noremap = true, silent = true, desc = "Toggle DAP REPL" })

return M
