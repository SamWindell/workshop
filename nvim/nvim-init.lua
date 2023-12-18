-- REMEMBER: you can use the mason plugin to install things like codelldb and lsp servers: MasonInstall
-- REMEMBER: if you have a motion like <leader>ww somewhere, as well as <leader>w, the latter will seem like it's delayed because it's waiting to see if you are adding another w
-- REMEMVER: you can use ctrl+h in insert move instead of backspace

local os_name = vim.loop.os_uname().sysname
local is_windows = os_name == "Windows_NT"
local is_linux = os_name == "Linux"
local is_mac = os_name == "Darwin"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spaces in tab when editing
vim.opt.shiftwidth = 4 -- number of spaces to use for autoindent
vim.opt.expandtab = true --  expand tab to spaces so that tabs are spaces
vim.opt.shiftround = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.equalalways = true
if not is_windows then
    vim.opt.guifont = { "JetBrainsMono Nerd Font Mono:h11" }
else
    vim.opt.guifont = { "JetBrainsMono NFM", ":h11" }
end
vim.opt.signcolumn = "yes"
vim.opt.title = true
vim.opt.timeoutlen = 500
vim.opt.spelllang = 'en_gb'
vim.opt.wrap = true
vim.opt.linebreak = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.cmd [[set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case]]
vim.cmd [[set grepformat+=%f:%l:%c:%m]]

if vim.g.neovide then
    vim.g.neovide_scroll_animation_length = 0.2
    vim.opt.mousemodel = 'extend'
    vim.g.neovide_refresh_rate = 120

    if is_linux then
        vim.g.neovide_transparency = 0.95
    elseif is_mac then
        vim.g.neovide_refresh_rate = 60
        vim.g.neovide_input_macos_alt_is_meta = true
        vim.g.neovide_scale_factor = 1.32
    end
end

vim.g.vim_svelte_plugin_use_typescript = true

if is_mac then
    vim.keymap.set('i', "<a-3>", "#")
end

vim.g.mapleader = ' '

require('plugins')
require('snippets')

vim.g.camelcasemotion_key = '<leader>'

--=================================================================

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
vim.cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}]]

--=================================================================

vim.g.zig_fmt_autosave = 0

--=================================================================
--
require 'nvim-web-devicons'.setup {}

--=================================================================
--
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

local get_sidebar_cols = function()
    local neovim_cols = vim.o.columns
    local sidebar_cols = neovim_cols - min_buffer_width - 1
    if total_dual_panel_cols < (neovim_cols - 10) then
        sidebar_cols = neovim_cols - total_dual_panel_cols - 1
    end
    return sidebar_cols
end

local get_big_window = function(mode, create_if_doesnt_exist)
    local num_proper_windows = 0
    local last_window = nil
    local first_window = nil

    local wins = vim.api.nvim_list_wins()
    for _, win in pairs(wins) do
        local buf_name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        local window_is_really_small_vertically = vim.api.nvim_win_get_height(win) <= (vim.o.lines / 2 - 3)
        if not buf_name:find("NvimTree") and not window_is_really_small_vertically then
            num_proper_windows = num_proper_windows + 1
            if not first_window then first_window = win end
            last_window = win
        end
    end

    if create_if_doesnt_exist then
        if num_proper_windows == 0 then
            vim.cmd(string.format("vertical rightb %dnew", vim.o.columns - get_sidebar_cols()))
            return vim.api.nvim_get_current_win()
        end

        if num_proper_windows == 1 then
            if vim.o.columns >= total_dual_panel_cols then
                vim.cmd(string.format('rightb %dvsplit', min_buffer_width))
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

local quickfix_pos = 0

-- IMPROVE: add ability to kill a command (jobstop())

local rtrim = function(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end

local run_command = function(command, on_exit)
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find("%[command%-output%]") then
            vim.api.nvim_buf_delete(buf, { force = true })
            break
        end
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
                    local i1, i2 = line:find("clang failed with stderr: ")
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

    vim.api.nvim_buf_set_name(command_buf, "[command-output]")

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
-- require("nvim-dap-virtual-text").setup({})

local which_key = require('which-key')
which_key.setup()
which_key.register({
    ["<c-a>"] = { "<Cmd>%y+<CR>", "Copy all text" },
    ["<F4>"] = { "<Cmd>lua require'dap'.pause()<CR>", "Pause | dap" },
    ["<F5>"] = { "<Cmd>lua require'dap'.continue()<CR>", "Start/continue | dap" },
    ["<F6>"] = { "<Cmd>lua require'dap'.run_last()<CR>", "Run last | dap" },
    ["<S-F5>"] = { "<Cmd>lua require'dap'.close()<CR>", "Stop | dap" },
    ["<F10>"] = { "<Cmd>lua require'dap'.step_over()<CR>", "Step over | dap" },
    ["<F11>"] = { "<Cmd>lua require'dap'.step_into()<CR>", "Step into | dap" },
    ["<F12>"] = { "<Cmd>lua require'dap'.step_out()<CR>", "Step out | dap" },
    ["<Leader>b"] = { "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", "Toggle breakpoint | dap" },
    ["<Leader>B"] = { "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        "Set condition breakpoint | dap" },
    ["<Leader>lp"] = { "<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
        "Log point message | dap" },
    ["<Leader>dr"] = { "<Cmd>lua require'dap'.repl.open()<CR>", "REPL | dap" },
    ["<leader>f"] = {
        name = "+find",
        j = { "<cmd>Telescope smart_open<cr>", "Find File" },
        -- f = { function()
        --     local project = read_project_file()
        --     if project and project.find_files then
        --         require('telescope.builtin').find_files({ find_command = split_string_by_words(project.find_files) })
        --     else
        --         require('telescope.builtin').find_files()
        --     end
        -- end, "Find File" },
        f = { "<cmd>Telescope git_files<cr>", "Find Git File" },
        o = { "<cmd>Telescope oldfiles<cr>", "Find Recent File" },
        b = { "<cmd>Telescope buffers<cr>", "Find Buffer" },
        d = { "<cmd>Telescope diagnostics<cr>", "Find Diagnostic" },
        g = { ':Telescope live_grep<cr>', 'Find Text' },
        G = { ':Telescope grep_string<cr>', 'Find String Under Cursor' },
        k = { ':Telescope keymaps<cr>', 'Find Keymap' },
    },
    ['<leader>za'] = { '<cmd>TZAtaraxis<cr>', 'Zen Mode' }, -- TODO: remove this? I dont use this
    ['<leader>rc'] = { '<cmd>source $MYVIMRC<cr>', 'Reload Config' },
    ['<leader>n'] = { '<cmd>enew<cr>', 'New File' },
    ['<leader>s'] = { '<cmd>write<cr>', 'Save File' }, -- This is overridden with format-and-save
    ['<leader>S'] = { '<cmd>write<cr>', 'Save File' },
    ['<leader>d'] = {
        name = "+diagnostic",
        K = { vim.diagnostic.open_float, 'Open diagnostic float' },
        j = { vim.diagnostic.goto_next, 'Goto next diagnostic', opts = { noremap = true, silent = true } },
        k = { vim.diagnostic.goto_prev, 'Goto prev diagnostic', opts = { noremap = true, silent = true } },
        h = { jump_forward_in_quickfix, "Goto next quickfix" },
        l = { jump_backward_in_quickfix, "Goto prev quickfix" },
    },
    ['<leader>g'] = {
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
                            type = "codelldb",
                            request = "launch",
                            name = "Debug",
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
    ['<A-tab>'] = { '<cmd>BufferLineMoveNext<cr>', 'Move buffer forward' },
    ['<A-s-tab>'] = { '<cmd>BufferLineMovePrev<cr>', 'Move buffer backward' },
    ['<tab>'] = { '<cmd>BufferLineCycleNext<cr>', 'Next buffer', opts = { noremap = true, silent = true } },
    ['<s-tab>'] = { '<cmd>BufferLineCyclePrev<cr>', 'Previous buffer' },
    ['<leader>q'] = { function()
        local buf = vim.api.nvim_get_current_buf()
        vim.cmd("bnext")
        vim.cmd("bd " .. buf)
    end, 'Close buffer' },
    ['<leader>t'] = { '<cmd>NvimTreeToggle<cr>', 'Toggle files sidebar' },
    ['<leader>e'] = { function()
        local win = get_big_window("secondary", false)
        if win then
            vim.api.nvim_win_close(win, false)
        else
            get_big_window("secondary", true)
        end
    end, "Toggle secondary window" },
})

vim.keymap.set('v', '<leader>/', 'y/\\V<C-R>=escape(@",\'/\\\')<CR><CR>N', { desc = 'Search for selection' })

vim.keymap.set('t', '<esc>', '<C-\\><C-n>', { desc = 'Normal mode' })
vim.keymap.set('t', 'kj', '<C-\\><C-n>', { desc = 'Normal mode' })

vim.keymap.set({ 'n', 'i', 'v' }, '<A-h>', '<C-w>h', { desc = 'Goto right window' })
vim.keymap.set({ 'n', 'i', 'v' }, '<A-l>', '<C-w>l', { desc = 'Goto left window' })
vim.keymap.set({ 'n', 'i', 'v' }, '<A-j>', '<C-w>j', { desc = 'Goto down window' })
vim.keymap.set({ 'n', 'i', 'v' }, '<A-k>', '<C-w>k', { desc = 'Goto up window' })

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

local bufferline = require("bufferline")
vim.keymap.set('n', '<A-1>', function() bufferline.go_to_buffer(1, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-2>', function() bufferline.go_to_buffer(2, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-3>', function() bufferline.go_to_buffer(3, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-4>', function() bufferline.go_to_buffer(4, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-5>', function() bufferline.go_to_buffer(5, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-6>', function() bufferline.go_to_buffer(6, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-7>', function() bufferline.go_to_buffer(7, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-8>', function() bufferline.go_to_buffer(8, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-9>', function() bufferline.go_to_buffer(9, true) end, { desc = 'Go to bufferline ' })
vim.keymap.set('n', '<A-$>', function() bufferline.go_to_buffer( -1, true) end, { desc = 'Go to bufferline ' })

vim.keymap.set({ 'i', 't' }, '<A-h>', '<C-\\><C-N><C-w>h', { desc = 'Goto right window' })
vim.keymap.set({ 'i', 't' }, '<A-l>', '<C-\\><C-N><C-w>l', { desc = 'Goto left window' })
vim.keymap.set({ 'i', 't' }, '<A-j>', '<C-\\><C-N><C-w>j', { desc = 'Goto down window' })
vim.keymap.set({ 'i', 't' }, '<A-k>', '<C-\\><C-N><C-w>k', { desc = 'Goto up window' })

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

--=================================================================

if is_windows then
    -- path for telescope smart_open
    vim.g.sqlite_clib_path = 'C:\\ProgramData\\chocolatey\\lib\\SQLite\\tools\\sqlite3.dll'
end

local builtin = require('telescope.builtin')
local telescope = require('telescope')
telescope.load_extension('dap')
telescope.load_extension("smart_open")

require('Comment').setup()

require('lualine').setup(
    {
        extensions = { 'nvim-tree' },
        sections = { lualine_x = { 'searchcount', 'filetype' } }
    })

require("nvim-treesitter.configs").setup {
    ensure_installed = { "python", "cpp", "lua", },
    auto_install = true,
    highlight = {
        enable = false, -- it's buggy overall and broken for markdown
    }
}

local path_api = require "mason-core.path"

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = path_api.concat { vim.fn.stdpath "data", "mason", "bin", is_windows and "codelldb.cmd" or "codelldb" },
        args = { "--port", "${port}" },

        -- On windows you may have to uncomment this:
        -- detached = false,
    }
}
dap.configurations.cpp = {
    {
        name = "Debug C++",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        args = function()
            return split_string_by_words(vim.fn.input('Args: '))
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
}

vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })

local handle_telescope_open_split = function(prompt_bufnr)
    local action_state = require('telescope.actions.state')
    local entry = action_state.get_selected_entry()
    local filename = entry[1]

    require("telescope.actions").close(prompt_bufnr)
    local win = get_big_window("other", true)
    vim.api.nvim_set_current_win(win)
    vim.cmd("edit " .. filename)
end

telescope.setup({
    defaults = {
        mappings = {
            n = {
                ["<C-v>"] = handle_telescope_open_split
            },
            i = {
                ["<C-v>"] = handle_telescope_open_split
            }
        },
        -- path_display = {
        --     "smart"
        -- }
    }
})

function _G.open_help_split()
    if vim.bo.filetype == 'man' or vim.bo.buftype == 'help' then
        ---The ID of the origin window from which help window was opened:
        ---i.e. last accessed window.
        local origin_win = vim.fn.win_getid(vim.fn.winnr('#'))
        local origin_buf = vim.api.nvim_win_get_buf(origin_win)

        local origin_textwidth = vim.bo[origin_buf].textwidth
        if origin_textwidth == 0 then origin_textwidth = 80 end

        local help_buf = vim.fn.bufnr()

        ---Origin 'bufhidden' property or the help buffer.
        local bufhidden = vim.bo.bufhidden
        vim.bo.bufhidden = 'hide'

        local old_help_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(origin_win)

        vim.api.nvim_win_close(old_help_win, false)

        local new_win = get_big_window("secondary", true)
        vim.api.nvim_win_set_buf(new_win, help_buf)
        vim.bo.bufhidden = bufhidden
    end
end

vim.cmd([[
      augroup HelpSplit
         autocmd!
         autocmd WinNew * autocmd BufEnter * ++once lua _G.open_help_split()
      augroup end
   ]])

dap.defaults.fallback.terminal_win_cmd = function()
    local buffer = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(get_big_window("secondary", true), buffer)
    return buffer
end

dap.listeners.before['event_initialized']['sam'] = function(_, _)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in pairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("%[dap%-terminal%]") then
            vim.api.nvim_win_set_buf(get_big_window("secondary", true), buf)
        end
    end
end

dap.listeners.after['event_stopped']['sam'] = function(_, _)
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in pairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name:match("%[dap%-repl%]") then
            vim.api.nvim_win_set_buf(get_big_window("secondary", true), buf)
        end
    end
end

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({})

require("mason").setup()

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "cmake", "clangd", "svelte", "html", "tsserver" }
})

local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    which_key.register({
        ['gt'] = { vim.lsp.buf.type_definition, 'Goto definition of the type of symbol under cursor' },
        ['gd'] = { builtin.lsp_definitions, 'Goto definition of symbol under cursor' },
        ['gD'] = { vim.lsp.buf.declaration, 'Goto declaration of symbol under cursor' },
        ['gi'] = { builtin.lsp_implementations, 'Goto implementation of symbol under cursor' },
        ['gr'] = { builtin.lsp_references, 'List references of symbol under cursor' },
        ['K'] = { vim.lsp.buf.hover, 'Show info float for symbol under cursor' },
        ['<C-k>'] = { vim.lsp.buf.signature_help, 'Show help float for symbol under cursor' },
        ['<leader>fr'] = { builtin.lsp_document_symbols, "Find symbol in file" },
        ['<leader>fe'] = { builtin.lsp_workspace_symbols, "Find symbol in workspace" },
        ['<leader>f'] = { function() vim.lsp.buf.format { async = true } end, 'Format document' },
        ['<leader>s'] = { function()
            vim.lsp.buf.format()
            vim.cmd [[ write ]]
        end, 'Format and save' },
        ['<space>rn'] = { vim.lsp.buf.rename, "Rename symbol" },
        ['<space>ca'] = { vim.lsp.buf.code_action, "LSP code action" },
    })
end

local supported_lsp_servers = {
    'cmake',
    'jsonls',
    'clangd',
    'csharp_ls',
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
        ['<C-d>'] = cmp.mapping.scroll_docs( -4),
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


require('gitsigns').setup()
require("nvim-tree").setup {
    open_on_setup = true,
    sync_root_with_cwd = true,
    view = {
        width = get_sidebar_cols(),
        signcolumn = "auto"
    }
}

vim.api.nvim_create_autocmd('VimResized', {
    callback = function()
        require("nvim-tree").setup({ view = { width = get_sidebar_cols() } })
    end
})

require("true-zen").setup {
    integrations = { lualine = true },
    modes = {
        ataraxis = {
            callbacks = {
                open_pre = function()
                    require 'nvim-tree.view'.close()
                end,
                close_pos = function()
                    vim.cmd [[NvimTreeToggle]]
                end,
            }
        }
    }
}

require('illuminate').configure({ delay = 50 })

require('leap').add_default_mappings()
