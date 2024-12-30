-- NOTE: in home.nix, we set use mkOutOfStoreSymlink to manage the nvim config so that
-- we don't need to home-manager switch with every change of this file.

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4      -- number of visual spaces per TAB
vim.opt.softtabstop = 4  -- number of spaces in tab when editing
vim.opt.shiftwidth = 4   -- number of spaces to use for autoindent
vim.opt.expandtab = true -- expand tab to spaces so that tabs are spaces
vim.opt.shiftround = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.equalalways = true
vim.opt.guifont = { "JetBrainsMono Nerd Font Mono:h11" }
vim.opt.signcolumn = "yes"
vim.opt.title = true
vim.opt.timeoutlen = 500
vim.opt.spelllang = 'en_gb'
vim.opt.wrap = true
vim.opt.linebreak = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = ' '
vim.lsp.set_log_level("OFF")

if vim.loop.os_uname().sysname == "Darwin" then
    vim.keymap.set('i', "<a-3>", "#")
end

vim.filetype.add({
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

-- flash text when it's yanked
vim.cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}]]

local primary_window_key = '2'
local secondary_window_key = '3'
local command_output_buffer_name = "[command-output]"

vim.g.vim_svelte_plugin_use_typescript = true

vim.g.zig_fmt_parse_errors = 0
vim.g.zig_fmt_autosave = 0

require('kanagawa').setup({
    dimInactive = true, -- dim inactive window `:h hl-NormalNC`
    overrides = function(default_colors)
        return {
            ["@keyword.operator"]     = { fg = default_colors.peachRed, italic = false, bold = false },
            Boolean                   = { italic = false, bold = false },
            Keyword                   = { fg = default_colors.peachRed, italic = false, bold = false },
            Statement                 = { fg = default_colors.peachRed, italic = false, },
            ["@keyword.return"]       = { fg = default_colors.peachRed, italic = false },
            ["@exception"]            = { fg = default_colors.peachRed, italic = false, bold = false },
            ["@parameter"]            = { italic = false },
            ["@type.qualifier"]       = { fg = default_colors.peachRed, italic = false },
            ["@conditional"]          = { fg = default_colors.peachRed, italic = false },
            ["@repeat"]               = { fg = default_colors.peachRed, italic = false },
            ["@storageClass"]         = { fg = default_colors.peachRed, italic = false },
            markdownH1                = { fg = default_colors.peachRed, bold = true },
            markdownH2                = { fg = default_colors.surimiOrange, bold = true },
            markdownH3                = { fg = default_colors.carpYellow, bold = true },
            markdownH4                = { fg = default_colors.springGreen, bold = true },
            markdownH5                = { fg = default_colors.crystalBlue, bold = true },
            markdownH6                = { fg = default_colors.oniViolet, bold = true },
            markdownUrl               = { fg = default_colors.crystalBlue, underline = true },
            markdownItalic            = { fg = default_colors.fujiWhite, italic = true },
            markdownBold              = { fg = default_colors.fujiWhite, bold = true },
            markdownItalicDelimiter   = { fg = default_colors.fujiGray, italic = true },
            markdownCode              = { fg = default_colors.springGreen },
            markdownCodeBlock         = { fg = default_colors.springGreen },
            markdownCodeDelimiter     = { fg = default_colors.springGreen },
            markdownBlockquote        = { fg = default_colors.fujiGray },
            markdownListMarker        = { fg = default_colors.peachRed },
            markdownOrderedListMarker = { fg = default_colors.peachRed },
            markdownRule              = { fg = default_colors.oniViolet },
            markdownHeadingRule       = { fg = default_colors.fujiGray },
            markdownUrlDelimiter      = { fg = default_colors.fujiGray },
            markdownLinkDelimiter     = { fg = default_colors.fujiGray },
            markdownLinkTextDelimiter = { fg = default_colors.fujiGray },
            markdownHeadingDelimiter  = { fg = default_colors.fujiGray },
            markdownLinkText          = { fg = default_colors.peachRed },
            markdownUrlTitleDelimiter = { fg = default_colors.springGreen },
            markdownIdDeclaration     = { fg = default_colors.peachRed },
            markdownBoldDelimiter     = { fg = default_colors.fujiGray },
            markdownId                = { fg = default_colors.carpYellow },
        }
    end,
    theme = "wave",
})
vim.cmd [[colorscheme kanagawa]]

require 'nvim-web-devicons'.setup {}
vim.notify = require("notify")

require("bufferline").setup {
    options = {
        numbers = "ordinal",
        offsets = {
            {
                filetype = "NvimTree",
                text = "Filesystem",
                highlight = "Directory",
                separator = true -- use a "true" to enable the default, or set your own character
            }
        },
        separator_style = "slant"
    }
}

local nvim_tree = require("nvim-tree")
local nvim_tree_api = require("nvim-tree.api")

local signcolumn_width = 7 -- AKA gutter width
local min_buffer_width = 110 + signcolumn_width
local total_dual_panel_cols = min_buffer_width * 2 + 1
local min_sidebar_width = 10
local max_sidebar_width = 32

local default_sidebar_cols = function()
    local neovim_cols = vim.o.columns
    local sidebar_cols = neovim_cols - min_buffer_width - 1
    if total_dual_panel_cols < (neovim_cols - min_sidebar_width) then
        sidebar_cols = neovim_cols - total_dual_panel_cols - 1
    end
    if sidebar_cols < min_sidebar_width then
        sidebar_cols = min_sidebar_width
    end
    if sidebar_cols > max_sidebar_width then
        sidebar_cols = max_sidebar_width
    end
    return sidebar_cols
end

local function get_sidebar_cols()
    local sidebar_width = 0
    if nvim_tree_api.tree.is_visible() then
        local wins = vim.api.nvim_list_wins()
        for _, win in pairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if nvim_tree_api.tree.is_tree_buf(buf) then
                sidebar_width = vim.api.nvim_win_get_width(win)
                break
            end
        end
    end
    return sidebar_width
end

local find_buffer = function(buffer_name)
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find(buffer_name, 1, true) then
            return buf
        end
    end
    return nil
end

local get_big_window = function(mode, create_if_doesnt_exist)
    local num_proper_windows = 0
    local last_window = nil
    local first_window = nil

    local wins = vim.api.nvim_list_wins()
    for _, win in pairs(wins) do
        local window_is_really_small_vertically = vim.api.nvim_win_get_height(win) <= 4
        if not require('nvim-tree.api').tree.is_tree_buf(vim.api.nvim_win_get_buf(win)) and not window_is_really_small_vertically then
            num_proper_windows = num_proper_windows + 1
            if not first_window then first_window = win end
            last_window = win
        end
    end

    if create_if_doesnt_exist then
        if num_proper_windows == 0 then
            vim.cmd("vertical rightb new")
            return vim.api.nvim_get_current_win()
        end

        if num_proper_windows == 1 and mode == "secondary" then
            local sidebar_width = get_sidebar_cols()
            local remaining_width = vim.o.columns - sidebar_width
            if remaining_width >= total_dual_panel_cols then
                vim.cmd('rightb vsplit')
            else
                vim.cmd('rightb split')
            end
            return vim.api.nvim_get_current_win()
        end
    end

    if mode == "secondary" then
        if last_window == first_window then return nil end
        return last_window
    elseif mode == "primary" then
        return first_window
    elseif mode == "other" then
        if last_window == first_window then return nil end

        local current = vim.api.nvim_get_current_win()
        if current == last_window then
            return first_window
        elseif current == first_window then
            return last_window
        else
            return first_window
        end
    else
        assert(false)
        return first_window
    end
end

local toggle_secondary_window = function()
    local win = get_big_window("secondary", false)
    if win then
        vim.api.nvim_win_close(win, false)
    else
        get_big_window("secondary", true)
    end
end

local open_buffer_in_secondary_window_if_possible = function(buffer_name, focus)
    local buf = find_buffer(buffer_name)
    if buf then
        local win = get_big_window("secondary", true)
        vim.api.nvim_win_set_buf(win, buf)
        if focus then
            vim.api.nvim_set_current_win(win)
        end
        return buf, win
    end
    return nil, nil
end

local quickfix_pos = 0

-- IMPROVE: add ability to kill a command (jobstop())

local rtrim = function(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end

local efm = table.concat({
    '%f:%l:%c: %t%*[^:]: %m', -- clang format

    -- TypeScript/JavaScript error formats
    '%A%f:%l:%c',  -- filename:line:col
    '%ZError: %m', -- Error message
    '%C%.%#',      -- Continuation lines
    '%-G%.%#',     -- Ignore other lines
}, ',')

local run_command = function(command, on_exit)
    local buf = find_buffer(command_output_buffer_name)
    if buf then
        vim.api.nvim_buf_delete(buf, { force = true })
    end

    local win = get_big_window("secondary", true)
    assert(win)

    -- if the secondary window is current, move its buffer to the primary window before
    -- we replace it with the command output buffer
    if vim.api.nvim_get_current_win() == win then
        local b = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_win_set_buf(get_big_window('primary', false), b)
    end

    vim.api.nvim_set_current_win(win)
    local command_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(win, command_buf)

    vim.fn.setqflist({}, 'r') -- clear quickfix
    quickfix_pos = 0
    -- NOTE: using termopen sets the terminal width to the width of the window. This means
    --       that you might have lines cut in half if they are long.
    vim.fn.termopen(command, {
        on_stdout = function(_, d, _)
            local lines = {}
            for _, line in pairs(d) do
                line = rtrim(line)
                line = line:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") -- remove ANSI colours
                line = line:gsub('C:\\', '/mnt/c/')                              -- WSL hack
                local i1, i2 = line:find("clang failed with stderr: ", 1, true)
                if i1 ~= nil then
                    table.insert(lines, line:sub(0, i2))
                    table.insert(lines, line:sub(i2 + 1, line:len()))
                else
                    table.insert(lines, line)
                end
            end
            local qf = vim.fn.getqflist({ efm = efm, lines = lines })
            for _, q in pairs(qf) do
                vim.fn.setqflist(q, 'a')
            end
        end,
        on_exit = function(job_id, exit_code, event_type)
            vim.api.nvim_buf_call(command_buf, function()
                vim.cmd("normal! G") -- scroll to bottom
                vim.api.nvim_set_option_value("modified", false, { buf = command_buf })
            end)
            if on_exit then on_exit(job_id, exit_code, event_type) end
        end,
        stderr_buffered = false,
        stdout_buffered = false
    })

    vim.api.nvim_buf_attach(command_buf, false, {
        on_lines = function(_)
            vim.cmd("normal! G") -- scroll to bottom
        end
    })

    vim.api.nvim_buf_set_name(command_buf, command_output_buffer_name)

    vim.api.nvim_set_current_win(get_big_window("primary", true))
end

vim.api.nvim_create_user_command("Run",
    function(args)
        run_command(args.args)
    end,
    { nargs = '*' }
)

-- I found use :cn and :cp to be annoying when there is only one error in the list,
-- and when you reach the start/end, so these are my alternatives that funciton as I want
local jump_forward_in_quickfix = function()
    local list = vim.fn.getqflist()
    local jumped = false
    local qf_line = 1
    local last_error_line = nil
    for _, v in pairs(list) do
        if v.lnum > 0 and v.valid then
            last_error_line = qf_line
            if qf_line > quickfix_pos then
                quickfix_pos = qf_line
                vim.cmd("cc " .. quickfix_pos)
                jumped = true
                break
            end
        end
        qf_line = qf_line + 1
    end

    if not jumped and last_error_line then
        vim.cmd("cc " .. last_error_line)
    end
end

local jump_backward_in_quickfix = function()
    local list = vim.fn.getqflist()
    local jumped = false
    local qf_line = #list
    local first_error_line = nil
    for i = #list, 1, -1 do
        local v = list[i]
        if v.lnum > 0 and v.valid then
            first_error_line = qf_line
            if qf_line < quickfix_pos then
                quickfix_pos = qf_line
                vim.cmd("cc " .. quickfix_pos)
                jumped = true
                break
            end
        end
        qf_line = qf_line - 1
    end

    if not jumped and first_error_line then
        vim.cmd("cc " .. first_error_line)
    end
end

local dap = require("dap")
local dap_ui_widgets = require("dap.ui.widgets")
local dap_terminal_float = require('dap-terminal-float')
local dap_repl_float = require('dap-repl-float')

nvim_tree.setup {
    sync_root_with_cwd = true,
    view = {
        width = default_sidebar_cols(),
        signcolumn = "auto"
    },
    filters = { custom = { "^.git$" } }
}

local first_debug_launch = true

vim.keymap.set({ 'n' }, '<c-a>', '<Cmd>%y+<CR>', { desc = 'Copy all text' })

local dap_frames_view = nil
local dap_scopes_view = nil
local dap_threads_view = nil

-- DAP mappings
vim.keymap.set('n', '<F4>', function() dap.pause() end, { desc = '[DAP] pause' })
vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = '[DAP] continue' })
vim.keymap.set('n', '<F6>', function() dap.terminate() end, { desc = '[DAP] terminate' })
vim.keymap.set('n', '<F10>', function() dap.step_over() end, { desc = '[DAP] step over' })
vim.keymap.set('n', '<F11>', function() dap.step_into() end, { desc = '[DAP] step into' })
vim.keymap.set('n', '<F12>', function() dap.step_out() end, { desc = '[DAP] step out' })
vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = '[DAP] toggle breakpoint' })
vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
    { desc = '[DAP] set condition breakpoint' })
vim.keymap.set('n', '<leader>dl', function() dap.list_breakpoints(true) end, { desc = '[DAP] list breakpoints' })
vim.keymap.set('n', '<leader>dd', function() dap.clear_breakpoints() end, { desc = '[DAP] clear breakpoints' })
vim.keymap.set('n', '<leader>do', dap_terminal_float.toggle_dap_float,
    { noremap = true, silent = true, desc = "Toggle DAP Terminal" })
vim.keymap.set('n', '<leader>dq', function() dap.terminate() end, { desc = '[DAP] terminate' })
vim.keymap.set('n', '<leader>dr', function() dap.run_to_cursor() end, { desc = '[DAP] run to cursor' })
vim.keymap.set('n', '<leader>dc', dap_repl_float.toggle_dap_repl,
    { noremap = true, silent = true, desc = "Toggle DAP REPL" })
vim.keymap.set('n', '<leader>dk', function() dap_ui_widgets.hover() end, { desc = '[DAP] hover' })
vim.keymap.set('n', '<leader>dp', function() dap_ui_widgets.preview() end, { desc = '[DAP] preview' })
vim.keymap.set('n', '<leader>df', function()
        if dap_frames_view then
            dap_frames_view.toggle()
        else
            dap_frames_view = dap_ui_widgets.centered_float(dap_ui_widgets.frames)
        end
    end,
    { desc = '[DAP] frames window' })
vim.keymap.set('n', '<leader>ds', function()
        if dap_scopes_view then
            dap_scopes_view.toggle()
        else
            dap_scopes_view = dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
        end
    end,
    { desc = '[DAP] scopes window' })
vim.keymap.set('n', '<leader>dt', function()
        if dap_threads_view then
            dap_threads_view.toggle()
        else
            dap_threads_view = dap_ui_widgets.centered_float(dap_ui_widgets.threads)
        end
    end,
    { desc = '[DAP] scopes window' })
vim.keymap.set('n', '<leader>dy', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
    { desc = '[DAP] log point message' })

-- Find related mappings
vim.keymap.set('n', '<leader>fj', function() require("telescope").extensions.smart_open.smart_open({}) end,
    { desc = 'Find File' })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<cr>', { desc = 'Find Git File' })
vim.keymap.set('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', { desc = 'Find Recent File' })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>', { desc = 'Find Diagnostic' })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<cr>', { desc = 'Find Text' })
vim.keymap.set('n', '<leader>fG', ':Telescope grep_string<cr>', { desc = 'Find String Under Cursor' })
vim.keymap.set('n', '<leader>fk', ':Telescope keymaps<cr>', { desc = 'Find Keymap' })

-- General mappings
vim.keymap.set("n", "/", [[/\v]], { desc = 'Magic search' })
vim.keymap.set('n', '<leader>rc', '<cmd>source ~/.config/nvim/lua/nvim-init.lua<cr>', { desc = 'Reload Config' })
vim.keymap.set('n', '<leader>n', '<cmd>enew<cr>', { desc = 'New File' })
vim.keymap.set('n', '<leader>s', '<cmd>write<cr>', { desc = 'Save File' })
vim.keymap.set('n', '<leader>S', '<cmd>write<cr>', { desc = 'Save File' })
vim.keymap.set({ 'i', 'v', 's' }, 'kj', '<esc>', { desc = 'Normal mode' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from OS clipboard after cursor' })
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P', { desc = 'Paste from OS clipboard before cursor' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set("n", "<leader>o", "printf('m`%so<ESC>``', v:count1)", {
    expr = true,
    desc = "Create new line below",
})
vim.keymap.set("n", "<leader>O", "printf('m`%sO<ESC>``', v:count1)", {
    expr = true,
    desc = "Create new line above",
})
vim.keymap.set('v', '<leader>/', 'y/\\V<C-R>=escape(@",\'/\\\')<CR><CR>N', { desc = 'Search for selection' })
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { desc = 'Normal mode' })
vim.keymap.set('t', 'kj', '<C-\\><C-n>', { desc = 'Normal mode' })

-- Diagnostic mappings
vim.keymap.set('n', '<leader>eK', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>ej', vim.diagnostic.goto_next, { desc = 'Goto next diagnostic' })
vim.keymap.set('n', '<leader>ek', vim.diagnostic.goto_prev, { desc = 'Goto prev diagnostic' })
vim.keymap.set('n', '<leader>eh', jump_forward_in_quickfix, { desc = 'Goto next quickfix' })
vim.keymap.set('n', '<leader>el', jump_backward_in_quickfix, { desc = 'Goto prev quickfix' })

-- Task mappings
vim.keymap.set('n', '<leader>gj', function()
    vim.cmd [[ wa ]]
    run_command("just default")
end, { desc = 'Build' })

vim.keymap.set('n', '<leader>gk', function()
    vim.cmd [[ wa ]]
    run_command("just pre-debug", function(_, exit_code, _)
        if exit_code == 0 then
            require('dap.ext.vscode').load_launchjs()
            if first_debug_launch then
                first_debug_launch = false
                dap.continue()
            else
                dap.run_last()
            end
        end
    end)
end, { desc = 'Debug' })

-- Buffer management mappings
vim.keymap.set('n', '<A-tab>', '<cmd>BufferLineMoveNext<cr>', { desc = 'Move buffer forward' })
vim.keymap.set('n', '<A-s-tab>', '<cmd>BufferLineMovePrev<cr>', { desc = 'Move buffer backward' })
vim.keymap.set('n', '<tab>', '<cmd>BufferLineCycleNext<cr>', { desc = 'Next buffer' })
vim.keymap.set('n', '<s-tab>', '<cmd>BufferLineCyclePrev<cr>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>i', '<cmd>BufferLinePick<cr>', { desc = 'Pick buffer' })
vim.keymap.set('n', '<leader>q', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd("bnext")
    vim.cmd("bd " .. buf)
end, { desc = 'Close buffer' })

-- Window management mappings
vim.keymap.set('n', '<leader>1', function()
        nvim_tree_api.tree.toggle({ focus = false })
    end,
    { desc = 'Toggle files sidebar' })
vim.keymap.set('n', '<leader>' .. secondary_window_key, toggle_secondary_window, { desc = 'Toggle secondary window' })
vim.keymap.set('n', '<leader>' .. primary_window_key, function()
    local secondary = get_big_window("secondary", false)
    if secondary then
        vim.api.nvim_win_close(get_big_window("primary", false), false)
    end
end, { desc = 'Solo secondary window' })
vim.keymap.set('n', '<leader>4', function()
    local secondary = get_big_window("secondary", false)
    if secondary then
        local initial_win = vim.api.nvim_get_current_win()
        local primary = get_big_window("primary", false)
        local b1 = vim.api.nvim_win_get_buf(primary)
        local b2 = vim.api.nvim_win_get_buf(secondary)
        vim.api.nvim_win_set_buf(primary, b2)
        vim.api.nvim_win_set_buf(secondary, b1)

        if initial_win == primary then
            vim.api.nvim_set_current_win(secondary)
        else
            vim.api.nvim_set_current_win(primary)
        end
    end
end, { desc = 'Swap primary and secondary windows' })
vim.keymap.set({ 'n' }, '<leader>wh', '<C-w>h', { desc = 'Goto right window' })
vim.keymap.set({ 'n' }, '<leader>wl', '<C-w>l', { desc = 'Goto left window' })
vim.keymap.set({ 'n' }, '<leader>wj', '<C-w>j', { desc = 'Goto down window' })
vim.keymap.set({ 'n' }, '<leader>wk', '<C-w>k', { desc = 'Goto up window' })
vim.keymap.set({ 'n' }, '<leader>wy', '<cmd>vertical resize -12<CR>', { desc = 'Decrease window width' })
vim.keymap.set({ 'n' }, '<leader>wo', '<cmd>vertical resize +12<CR>', { desc = 'Increase window width' })
vim.keymap.set({ 'n' }, '<leader>wi', '<cmd>resize +8<CR>', { desc = 'Increase window height' })
vim.keymap.set({ 'n' }, '<leader>wu', '<cmd>resize -8<CR>', { desc = 'Decrease window height' })

-- Refactoring
vim.keymap.set(
    { "n", "x" },
    "<leader>fl",
    function() require('telescope').extensions.refactoring.refactors() end
)

-- Copilot
vim.keymap.set('i', '<C-O>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- 
vim.keymap.set({ 'i', 's' }, '<c-l>', function()
    local luasnip = require('luasnip')
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    else
        -- accept Copilot word
        vim.cmd('normal! <Plug>(copilot-accept-word)')
    end
end, { desc = 'Goto next node in snippet', silent = true })

vim.keymap.set({ 'i', 's' }, '<c-h>', function()
    local luasnip = require('luasnip')
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
    end
end, { desc = 'Goto previous node in snippet', silent = true })

--=================================================================
require("bufferline")

require('refactoring').setup({
    -- prompt for return type
    prompt_func_return_type = {
        cpp = true,
        c = true,
    },
    -- prompt for function parameters
    prompt_func_param_type = {
        cpp = true,
        c = true,
    },
})


local handle_telescope_open_split_helper = function(prompt_bufnr, big_window_type)
    local action_state = require('telescope.actions.state')
    local entry = action_state.get_selected_entry()
    if not entry then
        return
    end

    local filename
    if entry.path or entry.filename then
        filename = entry.path or entry.filename
    else
        return
    end

    require("telescope.actions").close(prompt_bufnr)
    local win = get_big_window(big_window_type, true)
    vim.api.nvim_set_current_win(win)
    vim.cmd("edit " .. filename)
end

-- Open the selected file in the primary or secondary window
local telescope_mappings = {
    ["<C-j>"] = function(prompt_bufnr)
        handle_telescope_open_split_helper(prompt_bufnr, "primary")
    end,
    ["<C-k>"] = function(prompt_bufnr)
        handle_telescope_open_split_helper(prompt_bufnr, "secondary")
    end,
}

local telescope_builtin = require('telescope.builtin')
local telescope = require('telescope')
local file_ignore_patterns = {
    '^node_modules/',
    '^.git/',
    '^.venv/',
    '^.zig-cache/',
    '^zig-out/',
    '^build/',
    '^.vscode/extensions/',
    '^.vscode/.*cache/',
    '^__pycache__/',
    '^.cache/',
}
telescope.setup({
    defaults = {
        mappings = {
            n = telescope_mappings,
            i = telescope_mappings,
        },
    },
    pickers = {
        grep_string = {
            file_ignore_patterns = file_ignore_patterns,
            additional_args = { "--hidden" }
        },
        live_grep = {
            file_ignore_patterns = file_ignore_patterns,
            additional_args = { "--hidden" }
        },
        find_files = {
            file_ignore_patterns = file_ignore_patterns,
            hidden = true
        }
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
        },
        smart_open = {
            match_algorithm = "fzf",
        },
    }
})
telescope.load_extension('fzf')
telescope.load_extension('dap')
telescope.load_extension("smart_open")
telescope.load_extension("refactoring")

dap.adapters.lldb = {
    type = 'executable',
    command = lldb_vscode_path,
    name = 'lldb',
}

local notify = require('notify')

-- Create a notification helper function
local function notify_debug(msg, level)
    notify(msg, level, {
        title = "Debug",
        icon = "🐛" -- This will only show in GUI clients that support it
    })
end

-- Set up listeners for debug events
-- Debug continue
dap.listeners.after['event_continue']['dap-notify'] = function()
    notify_debug("Continuing debug session", "info")
end

-- Debug stopped
dap.listeners.after['event_stopped']['dap-notify'] = function(_, body)
    local reason = body.reason or "Unknown"
    notify_debug("Stopped: " .. reason, "warn")
end

-- Debug exited
dap.listeners.after['event_exited']['dap-notify'] = function(_, body)
    local exitCode = body.exitCode or "Unknown"
    notify_debug("Debug session exited (code " .. exitCode .. ")", "info")
end


vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })


-- Open help files in the secondary window.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_secondary_window", {}),
    pattern = { "*.txt" },
    callback = function()
        -- Run every time a help buffer is opened
        if vim.o.filetype == 'help' then
            -- When a help buffer is first created, it's opened in a new window and it is not 'listed'.
            -- 'listed' is a var of a buffer that dictates if it should be listed in certain situations.
            -- For example, bufferline will only show listed buffers.
            local buf = vim.api.nvim_get_current_buf()
            if not vim.api.nvim_buf_get_option(buf, "buflisted") then
                -- If the buffer is unlisted it must be the first time it's opened. Let's close the window
                -- that vim made for us, and put the buffer in our 'secondary' window instead.
                vim.api.nvim_buf_set_option(buf, "buflisted", true)
                vim.api.nvim_win_close(0, false)
                local win = get_big_window("secondary", true)
                vim.api.nvim_win_set_buf(win, buf)
                vim.api.nvim_set_current_win(win)
            end
        end
    end
})

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition,
        { desc = 'Goto definition of the type of symbol under cursor' })
    vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions, { desc = 'Goto definition of symbol under cursor' })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto declaration of symbol under cursor' })
    vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations,
        { desc = 'Goto implementation of symbol under cursor' })
    vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, { desc = 'List references of symbol under cursor' })

    -- LSP information
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show info float for symbol under cursor' })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Show help float for symbol under cursor' })

    -- LSP symbol search
    vim.keymap.set('n', '<leader>fr', telescope_builtin.lsp_document_symbols, { desc = 'Find symbol in file' })
    vim.keymap.set('n', '<leader>fe', telescope_builtin.lsp_workspace_symbols, { desc = 'Find symbol in workspace' })

    -- LSP formatting and modifications
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { desc = 'Format document' })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        -- Get the buffer number from the event arguments
        local bufnr = args.buf

        -- Get the clients attached to the current buffer
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

        for _, client in ipairs(clients) do
            if client.server_capabilities.documentFormattingProvider then
                vim.lsp.buf.format({
                    bufnr = bufnr,
                    async = false
                })
                break
            end
        end
    end,
})

local supported_lsp_servers = {
    'cmake',
    'jsonls',
    'clangd',
    'lua_ls',
    'pylsp',
    'zls',
    'svelte',
    'ts_ls',
    'html',
    'nixd'
}

local lspconfig = require('lspconfig')
local server_config =
{
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        nixd = {
            formatting = {
                command = { "nixfmt" },
            },
        },
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
            format = {
                enable = true,
            }
        },
    }
}

for _, v in pairs(supported_lsp_servers) do
    if (v == 'clangd') then
        server_config.cmd = { "clangd", "--offset-encoding=utf-16", "--clang-tidy", }
    else
        server_config.cmd = nil
    end
    lspconfig[v].setup(server_config);
end


local cmp = require('cmp')
require('cmp_luasnip')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete({}),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        ['<C-j>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-k>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'path' },
    },
    enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
            or require("cmp_dap").is_dap_buffer()
    end
})


require("cmp").setup.filetype({ "dap-repl" }, {
    sources = {
        { name = "dap" },
    },
})

local count = 0

local function handle_resize()
    count = count + 1
    local secondary_win = get_big_window("secondary", false)
    if secondary_win then
        local sidebar_width = get_sidebar_cols()

        local remaining_width = vim.o.columns - sidebar_width
        local primary_win = get_big_window("primary", false)
        local main_panels_are_vertical = vim.api.nvim_win_get_position(primary_win)[2] ==
            vim.api.nvim_win_get_position(secondary_win)[2]
        if remaining_width >= total_dual_panel_cols then
            -- we have enough space for both windows, so the secondary window should be on the right, halfway
            if main_panels_are_vertical then
                vim.api.nvim_set_current_win(secondary_win)
                vim.cmd("wincmd L")
            end
        else
            -- we don't have enough space for windows to be side by side, so they should be above and below
            if not main_panels_are_vertical then
                local buf = vim.api.nvim_win_get_buf(secondary_win)
                vim.api.nvim_win_close(secondary_win, false)
                vim.api.nvim_set_current_win(get_big_window("primary", false))
                vim.cmd("split")
                vim.api.nvim_win_set_buf(0, buf)
            end
        end
    end
end

nvim_tree_api.events.subscribe(nvim_tree_api.events.Event.TreeOpen, handle_resize)
nvim_tree_api.events.subscribe(nvim_tree_api.events.Event.TreeClose, handle_resize)
vim.api.nvim_create_autocmd('VimResized', { callback = handle_resize })

require('textcase').setup {}

require('gitsigns').setup()
require('illuminate').configure({ delay = 50 })
require('leap').add_default_mappings()
require("nvim-surround").setup()
require('snippets')
require("visual-whitespace").setup()

-- Normal Mode
-- `gcc` - Toggles the current line using linewise comment
-- `gbc` - Toggles the current line using blockwise comment
-- `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
-- `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
-- `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
-- `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment
-- `gco` - Insert comment to the next line and enters INSERT mode
-- `gcO` - Insert comment to the previous line and enters INSERT mode
-- `gcA` - Insert comment to end of the current line and enters INSERT mode
require('Comment').setup()
require('Comment.ft').set('objcpp', '//%s')

local function dap_status()
    if dap.session() then
        return '🐛 ' .. dap.status()
    end
    return ''
end

require('lualine').setup(
    {
        extensions = { 'nvim-tree' },
        sections = { lualine_x = { dap_status, 'searchcount', 'filetype' } }
    })

---@diagnostic disable-next-line: missing-fields
require 'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        disable = {
            "nix", "c", "cpp", "lua", "json", "yaml", "toml", "html", "css", "javascript", "typescript", "svelte"
        },
    },
    textobjects = {
        select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                -- You can optionally set descriptions to the mappings (used in the desc parameter of
                -- nvim_buf_set_keymap) which plugins like which-key display
                ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                -- You can also use captures from other query groups like `locals.scm`
                ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V',  -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = true,
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
            },
            swap_previous = {
                ["<leader>A"] = "@parameter.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]p"] = "@parameter.inner",
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
                --
                -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
                ["]o"] = "@loop.*",
                -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                --
                -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]P"] = "@parameter.inner",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
                ["]d"] = "@conditional.outer",
            },
            goto_previous = {
                ["[d"] = "@conditional.outer",
            }
        },
    },
}

local function start_up_func()
    nvim_tree_api.tree.toggle({ focus = false })
end
-- scheduling it avoids a problem where it's always focused
vim.schedule(start_up_func)
