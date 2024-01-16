-- TODO: maybe add https://github.com/ThePrimeagen/harpoon/tree/harpoon2

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

if vim.loop.os_uname().sysname == "Darwin" then
    vim.keymap.set('i', "<a-3>", "#")
end

-- flash text when it's yanked
vim.cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}]]

-- use ripgrep as vimgrep
vim.cmd [[set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case]]
vim.cmd [[set grepformat+=%f:%l:%c:%m]]

local primary_window_key = '2'
local secondary_window_key = '3'
local dap_repl_buffer_name = "[dap-repl]"
local dap_terminal_buffer_name = "[dap-terminal]"
local command_output_buffer_name = "[command-output]"

vim.g.vim_svelte_plugin_use_typescript = true

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

local split_string_by_words = function(text)
    local e      = 0
    local result = {}
    while true do
        local b = e + 1
        b = text:find("%S", b)
        if b == nil then break end
        if text:sub(b, b) == "'" then
            e = text:find("'", b + 1)
            b = b + 1
        elseif text:sub(b, b) == '"' then
            e = text:find('"', b + 1)
            b = b + 1
        else
            e = text:find("%s", b + 1)
        end
        if e == nil then e = #text + 1 end
        table.insert(result, text:sub(b, e - 1))
    end
    return result
end

local signcolumn_width = 7 -- AKA gutter width
local min_buffer_width = 110 + signcolumn_width
local total_dual_panel_cols = min_buffer_width * 2 + 1
local min_sidebar_width = 10
local max_sidebar_width = 32

local get_sidebar_cols = function()
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
        local window_is_really_small_vertically = vim.api.nvim_win_get_height(win) <= (vim.o.lines / 2 - 3)
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
            if vim.o.columns >= total_dual_panel_cols then
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

local run_command = function(command, on_exit)
    local buf = find_buffer(command_output_buffer_name)
    if buf then
        vim.api.nvim_buf_delete(buf, { force = true })
    end

    local win = get_big_window("secondary", true)
    assert(win)
    vim.api.nvim_set_current_win(win)

    local command_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(win, command_buf)

    vim.fn.setqflist({}, 'r') -- clear quickfix
    quickfix_pos = 0
    -- NOTE: using termopen sets the terminal width to the width of the window. This means
    --       that you might have lines cut in half if they are long.
    vim.fn.termopen(command,
        {
            on_stdout = function(job_id, d, _)
                local lines = {}
                for _, line in pairs(d) do
                    line = rtrim(line)
                    -- remove ANSI colours
                    line = line:gsub('\x1b%[%d+;%d+;%d+;%d+;%d+m', '')
                        :gsub('\x1b%[%d+;%d+;%d+;%d+m', '')
                        :gsub('\x1b%[%d+;%d+;%d+m', '')
                        :gsub('\x1b%[%d+;%d+m', '')
                        :gsub('\x1b%[%d+m', '')
                    local i1, i2 = line:find("clang failed with stderr: ", 1, true)
                    if i1 ~= nil then
                        table.insert(lines, line:sub(0, i2))
                        table.insert(lines, line:sub(i2 + 1, line:len()))
                    else
                        table.insert(lines, line)
                    end
                end
                local qf = vim.fn.getqflist({ efm = "%f:%l:%c: %t%*[^:]: %m", lines = lines })
                for _, q in pairs(qf) do
                    vim.fn.setqflist(q, 'a')
                end
            end,
            on_exit = function(job_id, exit_code, event_type)
                vim.api.nvim_buf_call(command_buf, function()
                    vim.cmd("normal! G") -- scroll to bottom
                    vim.api.nvim_buf_set_option(command_buf, "modified", false)
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

local read_ini_file = function(filename)
    local file = io.open(filename, 'r')
    if not file then return nil end
    local result = {}
    local section = nil
    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$')
        if tempSection then
            section = tempSection
            result[section] = result[section] or {}
        end
        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$')
        if param ~= nil and value ~= nil then
            if (tonumber(value)) then
                value = tonumber(value)
            elseif (value == 'true') then
                value = true
            elseif (value == 'false') then
                value = false
            end

            local as_num = tonumber(param)
            if as_num then
                param = as_num
            end

            if not section then
                result[param] = value
            else
                result[section][param] = value
            end
        end
    end
    file:close()
    return result
end

local read_project_file = function()
    local project = read_ini_file(vim.fn.getcwd() .. "/nvim-project.ini")
    local cross_platform_project = read_ini_file(vim.fn.getcwd() .. "/nvim-project-cross-platform.ini")
    if not project and not cross_platform_project then return nil end

    if not project then project = {} end
    if not cross_platform_project then cross_platform_project = {} end

    for k, v in pairs(cross_platform_project) do project[k] = v end

    if project.variables then
        local do_all_variable_substitutions = function(value)
            for variable_key, variable_value in pairs(project.variables) do
                value = value:gsub("{{" .. variable_key .. "}}", variable_value)
            end
            return value
        end

        for key, value in pairs(project.variables) do
            project.variables[key] = do_all_variable_substitutions(value)
        end


        for key, value in pairs(project) do
            if key ~= "variables" then
                project[key] = do_all_variable_substitutions(value)
            end
        end
    end

    return project
end

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

local function prepare_for_recreating_secondary_split()
    local sec = get_big_window("secondary", false)
    if sec then
        vim.api.nvim_win_close(sec, false)
    end

    local prim = get_big_window("primary", true)
    vim.api.nvim_set_current_win(prim)
    local width = vim.api.nvim_win_get_width(prim)
    local wincmd = nil
    if width < total_dual_panel_cols then
        wincmd = "split"
    else
        wincmd = "rightb vsplit"
    end
    return wincmd
end

local open_dap_repl = function()
    if open_buffer_in_secondary_window_if_possible(dap_repl_buffer_name, true) then
        return
    end

    local wincmd = prepare_for_recreating_secondary_split()
    dap.repl.open({}, wincmd)

    sec = get_big_window("secondary", false)
    vim.api.nvim_set_current_win(sec)
end

local nvim_tree = require("nvim-tree")
local nvim_tree_api = require("nvim-tree.api")
nvim_tree.setup {
    sync_root_with_cwd = true,
    view = {
        width = get_sidebar_cols(),
        signcolumn = "auto"
    }
}

local which_key = require('which-key')
which_key.setup()
which_key.register({
    ["<c-a>"]                            = { "<Cmd>%y+<CR>", "Copy all text" },
    ["<F4>"]                             = { function() dap.pause() end, "Pause | dap" },
    ["<F5>"]                             = { function() dap.continue() end, "Start/continue | dap" },
    ["<F6>"]                             = { function() dap.run_last() end, "Run last | dap" },
    ["<S-F5>"]                           = { function() dap.terminate() end, "Stop | dap" },
    ["<F10>"]                            = { function() dap.step_over() end, "Step over | dap" },
    ["<F11>"]                            = { function() dap.step_into() end, "Step into | dap" },
    ["<F12>"]                            = { function() dap.step_out() end, "Step out | dap" },
    ["<leader>b"]                        = { function() dap.toggle_breakpoint() end, "Toggle breakpoint | dap" },
    ["<leader>B"]                        = { function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        "Set condition breakpoint | dap" },

    ["<leader>d"]                        = {
        r = { open_dap_repl, "Toggle REPL | dap" },
        k = { function() dap_ui_widgets.hover() end, "Dap hover" },
        p = { function() dap_ui_widgets.preview() end, "Dap preview" },
        f = {
            function()
                dap_ui_widgets.centered_float(dap_ui_widgets.frames)
            end,
            "Dap frames window"
        },
        s = {
            function()
                dap_ui_widgets.centered_float(dap_ui_widgets.scopes)
            end,
            "Dap scopes window"
        },
        -- TODO: play with this, what does this do?
        y = { function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
            "Log point message | dap" },
    },

    ["<leader>f"]                        = {
        name = "+find",
        j = { function() require("telescope").extensions.smart_open.smart_open({}) end, "Find File" },
        f = { "<cmd>Telescope git_files<cr>", "Find Git File" },
        o = { "<cmd>Telescope oldfiles<cr>", "Find Recent File" },
        b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        d = { "<cmd>Telescope diagnostics<cr>", "Find Diagnostic" },
        g = { ':Telescope live_grep<cr>', 'Find Text' },
        G = { ':Telescope grep_string<cr>', 'Find String Under Cursor' },
        k = { ':Telescope keymaps<cr>', 'Find Keymap' },
    },
    ['<leader>rc']                       = { '<cmd>source ~/.config/nvim/lua/nvim-init.lua<cr>', 'Reload Config' },
    ['<leader>n']                        = { '<cmd>enew<cr>', 'New File' },
    ['<leader>s']                        = { '<cmd>write<cr>', 'Save File' }, -- This is overridden with format-and-save
    ['<leader>S']                        = { '<cmd>write<cr>', 'Save File' },
    ['<leader>e']                        = {
        name = "+diagnostic",
        K = { vim.diagnostic.open_float, 'Open diagnostic float' },
        j = { vim.diagnostic.goto_next, 'Goto next diagnostic' },
        k = { vim.diagnostic.goto_prev, 'Goto prev diagnostic' },
        h = { jump_forward_in_quickfix, "Goto next quickfix" },
        l = { jump_backward_in_quickfix, "Goto prev quickfix" },
    },
    ['<leader>g']                        = {
        name = '+task',
        j = { function()
            local project = read_project_file()
            if project and project.build then
                vim.cmd [[ wa ]]
                run_command(project.build)
            else
                print("Error: missing \"build\" field in nvim-project")
            end
        end, "Build" },
        k = { function()
            local project = read_project_file()
            if project and project.debug_target then
                vim.cmd [[ wa ]]
                run_command(project.build, function(_, exit_code, _)
                    if exit_code == 0 then
                        local command = split_string_by_words(project.debug_target)
                        local config = {
                            program = command[1],
                            type = "lldb",
                            request = "launch",
                            name = "Debug",
                            runInTerminal = true,
                        }
                        if #command ~= 1 then
                            table.remove(command, 1)
                            config.args = command
                        end
                        dap.run(config)
                    end
                end)
            else
                print("Error: missing \"debug_target\" field in nvim-project")
            end
        end, "Debug" },
        h = { function()
            local project = read_project_file()
            if project and project.configure then
                run_command(project.configure)
            else
                print("Error: missing \"configure\" field in nvim-project")
            end
        end, "Configure" },
    },
    ['<A-tab>']                          = { '<cmd>BufferLineMoveNext<cr>', 'Move buffer forward' },
    ['<A-s-tab>']                        = { '<cmd>BufferLineMovePrev<cr>', 'Move buffer backward' },
    ['<tab>']                            = { '<cmd>BufferLineCycleNext<cr>', 'Next buffer' },
    ['<s-tab>']                          = { '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer' },
    ['<leader>q']                        = { function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd("bnext")
        vim.cmd("bd " .. buf)
    end, 'Close buffer' },

    ['<leader>1']                        = { function() nvim_tree_api.tree.toggle({ focus = false }) end, 'Toggle files sidebar' },
    ['<leader>' .. secondary_window_key] = { toggle_secondary_window, "Toggle secondary window" },
    ['<leader>' .. primary_window_key]   = { function()
        local secondary = get_big_window("secondary", false)
        if secondary then
            vim.api.nvim_win_close(get_big_window("primary", false), false)
        end
    end, "Solo secondary window" },
    ['<leader>4']                        = { function()
        local secondary = get_big_window("secondary", false)
        if secondary then
            local primary = get_big_window("primary", false)
            local b1 = vim.api.nvim_win_get_buf(primary)
            local b2 = vim.api.nvim_win_get_buf(secondary)
            vim.api.nvim_win_set_buf(primary, b2)
            vim.api.nvim_win_set_buf(secondary, b1)
        end
    end, "Swap primary and secondary windows" },
})

vim.keymap.set({ 'n' }, '<leader>wh', '<C-w>h', { desc = 'Goto right window' })
vim.keymap.set({ 'n' }, '<leader>wl', '<C-w>l', { desc = 'Goto left window' })
vim.keymap.set({ 'n' }, '<leader>wj', '<C-w>j', { desc = 'Goto down window' })
vim.keymap.set({ 'n' }, '<leader>wk', '<C-w>k', { desc = 'Goto up window' })

vim.keymap.set('v', '<leader>/', 'y/\\V<C-R>=escape(@",\'/\\\')<CR><CR>N', { desc = 'Search for selection' })

vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { desc = 'Normal mode' })
vim.keymap.set('t', 'kj', '<C-\\><C-n>', { desc = 'Normal mode' })

vim.keymap.set({ 'i', 's' }, '<c-l>', function()
    local luasnip = require('luasnip')
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    end
end, { desc = 'Goto next node in snippet', silent = true })

vim.keymap.set({ 'n', 'i' }, '<c-;>', function()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    vim.api.nvim_buf_set_text(0, row - 1, #line, row - 1, #line, { ";" })
end, { desc = "Append semicolon on line" })

vim.keymap.set('n', "<space><space>s",
    "<cmd>source ~/.config/nvim/lua/snippets.lua<CR>")

require("bufferline")

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

-- Magic mode for search; AKA use proper regex syntax
vim.keymap.set("n", "/", [[/\v]])

vim.keymap.set(
    { "n", "x" },
    "<leader>fl",
    function() require('telescope').extensions.refactoring.refactors() end
)

--=================================================================
--
require('refactoring').setup({
    -- prompt for return type
    prompt_func_return_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
    },
    -- prompt for function parameters
    prompt_func_param_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
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

local telescope_mappings = {
    [("<C-%s>"):format(primary_window_key)] = function(prompt_bufnr)
        handle_telescope_open_split_helper(prompt_bufnr, "primary")
    end,
    [("<C-%s>"):format(secondary_window_key)] = function(prompt_bufnr)
        handle_telescope_open_split_helper(prompt_bufnr, "secondary")
    end,
}

local telescope_builtin = require('telescope.builtin')
local telescope = require('telescope')
telescope.setup({
    defaults = {
        mappings = {
            n = telescope_mappings,
            i = telescope_mappings,
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
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

dap.configurations.cpp = {
    {
        name = "Debug C++",
        type = "lldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        args = function()
            return split_string_by_words(vim.fn.input('Args: '))
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        runInTerminal = true,
        stopCommands = { 'bt' },
    },
}

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

dap.defaults.fallback.terminal_win_cmd = function()
    local prim = get_big_window("primary", true)
    vim.api.nvim_command(prepare_for_recreating_secondary_split())
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(prim)
    return bufnr, win
end

dap.listeners.before['event_initialized']['sam'] = function(_, _)
    open_buffer_in_secondary_window_if_possible(dap_terminal_buffer_name)
end

dap.listeners.after['event_stopped']['sam'] = function(_, _)
    open_dap_repl()
end

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    which_key.register({
        ['gt'] = { vim.lsp.buf.type_definition, 'Goto definition of the type of symbol under cursor' },
        ['gd'] = { telescope_builtin.lsp_definitions, 'Goto definition of symbol under cursor' },
        ['gD'] = { vim.lsp.buf.declaration, 'Goto declaration of symbol under cursor' },
        ['gi'] = { telescope_builtin.lsp_implementations, 'Goto implementation of symbol under cursor' },
        ['gr'] = { telescope_builtin.lsp_references, 'List references of symbol under cursor' },
        ['K'] = { vim.lsp.buf.hover, 'Show info float for symbol under cursor' },
        ['<C-k>'] = { vim.lsp.buf.signature_help, 'Show help float for symbol under cursor' },
        ['<leader>fr'] = { telescope_builtin.lsp_document_symbols, "Find symbol in file" },
        ['<leader>fe'] = { telescope_builtin.lsp_workspace_symbols, "Find symbol in workspace" },
        ['<leader>f'] = { function() vim.lsp.buf.format { async = true } end, 'Format document' },
        ['<leader>s'] = { function()
            vim.lsp.buf.format()
            vim.cmd [[ write ]]
        end, 'Format and save' },
        ['<leader>rn'] = { vim.lsp.buf.rename, "Rename symbol" },
        ['<leader>ca'] = { vim.lsp.buf.code_action, "LSP code action" },
    })
end

-- NOTE(Sam): might want to remove this, it makes the LSP _really_ sluggish
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
    -- add any options here, or leave empty to use the default settings
})

local supported_lsp_servers = {
    'cmake',
    'jsonls',
    'clangd',
    'lua_ls',
    'pylsp',
    'zls',
    'svelte',
    'tsserver',
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
        formatting = {
            command = "nixpkgs-fmt"
        }
    }
}

for _, v in pairs(supported_lsp_servers) do
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
    },
})

local handle_resize = function()
    local secondary_win = get_big_window("secondary", false)
    if secondary_win then
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

        local remaining_width = vim.o.columns - sidebar_width
        local secondary_col = vim.api.nvim_win_get_position(secondary_win)[2]
        if remaining_width >= total_dual_panel_cols then
            if secondary_col == sidebar_width then
                vim.api.nvim_set_current_win(secondary_win)
                vim.cmd("wincmd L")
            end
        else
            if secondary_col ~= sidebar_width and secondary_col ~= (sidebar_width + 1) then
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

require('gitsigns').setup()
require('illuminate').configure({ delay = 50 })
require('leap').add_default_mappings()
require("nvim-surround").setup()
require('snippets')
require('Comment').setup()
require('lualine').setup(
    {
        extensions = { 'nvim-tree' },
        sections = { lualine_x = { 'searchcount', 'filetype' } }
    })

require 'nvim-treesitter.configs'.setup {
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
