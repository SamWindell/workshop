-- NOTE: in home.nix, we set use mkOutOfStoreSymlink to manage the nvim config so that
-- we don't need to home-manager switch with every change of this file.

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4      -- Number of visual spaces per TAB>
vim.opt.softtabstop = 4  -- Number of spaces in tab when editing
vim.opt.shiftwidth = 4   -- Number of spaces to use for autoindent
vim.opt.expandtab = true -- Expand tab to spaces so that tabs are spaces
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
vim.lsp.log.set_level("OFF")

if vim.loop.os_uname().sysname == "Darwin" then
    vim.keymap.set('i', "<a-3>", "#")
end

vim.filetype.add({
    pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
})

-- flash text when it's yanked
vim.cmd [[autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup=(vim.fn['hlexists']('HighlightedyankRegion') > 0 and 'HighlightedyankRegion' or 'IncSearch'), timeout=500}]]

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

local nvim_tree = require("nvim-tree")
local nvim_tree_api = require("nvim-tree.api")
local layout = require("layout")
local runner = require("runner")

nvim_tree.setup {
    sync_root_with_cwd = true,
    view = {
        width = layout.default_sidebar_cols(),
        signcolumn = "auto"
    },
    filters = { custom = { "^.git$" } }
}

layout.setup()
runner.setup()

local first_debug_launch = true

-- vim.keymap.set({ 'n' }, '<c-a>', '<Cmd>%y+<CR>', { desc = 'Copy all text' })

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

-- Task mappings
vim.keymap.set('n', '<leader>gj', function()
    vim.cmd [[ wa ]]
    runner.run("bash .workshop/build.sh")
end, { desc = 'Build' })
vim.keymap.set('n', '<leader>gk', function() runner.stop() end, { desc = 'Stop run' })


-- Buffer management mappings
vim.keymap.set('n', '<leader>q', function()
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd("bnext")
    vim.cmd("bd " .. buf)
end, { desc = 'Close buffer' })

-- Window management mappings
vim.keymap.set('n', '<leader>1', layout.focus_sidebar, { desc = 'Focus sidebar (toggle if already there)' })
vim.keymap.set('n', '<leader>2', function() layout.focus('primary') end, { desc = 'Focus primary' })
vim.keymap.set('n', '<leader>3', function() layout.focus('secondary') end, { desc = 'Focus secondary' })
vim.keymap.set('n', '<leader>z', layout.zoom, { desc = 'Zoom: solo current big window' })
vim.keymap.set('n', '<leader>x', layout.swap_buffers, { desc = 'Swap primary/secondary buffers' })
vim.keymap.set('n', '<leader>X', layout.close_secondary, { desc = 'Close secondary' })
vim.keymap.set('n', '<leader><Tab>', layout.toggle_focus, { desc = 'Jump between primary/secondary' })
vim.keymap.set({ 'n' }, '<leader>wh', '<C-w>h', { desc = 'Goto left window' })
vim.keymap.set({ 'n' }, '<leader>wl', '<C-w>l', { desc = 'Goto right window' })
vim.keymap.set({ 'n' }, '<leader>wj', '<C-w>j', { desc = 'Goto down window' })
vim.keymap.set({ 'n' }, '<leader>wk', '<C-w>k', { desc = 'Goto up window' })
vim.keymap.set({ 'n' }, '<leader>wy', '<cmd>vertical resize -12<CR>', { desc = 'Decrease window width' })
vim.keymap.set({ 'n' }, '<leader>wo', '<cmd>vertical resize +12<CR>', { desc = 'Increase window width' })
vim.keymap.set({ 'n' }, '<leader>wi', '<cmd>resize +8<CR>', { desc = 'Increase window height' })
vim.keymap.set({ 'n' }, '<leader>wu', '<cmd>resize -8<CR>', { desc = 'Decrease window height' })

-- Copilot
-- vim.keymap.set('i', '<C-O>', 'copilot#Accept("\\<CR>")', {
--     expr = true,
--     replace_keycodes = false
-- })
-- vim.keymap.set('i', '<C-s-o>', '<Plug>(copilot-accept-word)')
-- vim.g.copilot_no_tab_map = true


--=================================================================

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
    local win = layout.get_window(big_window_type, { create = true })
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
telescope.setup({
    defaults = {
        mappings = {
            n = telescope_mappings,
            i = telescope_mappings,
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        smart_open = {
            match_algorithm = "fzf",
        },
    }
})
telescope.load_extension('fzf')
telescope.load_extension("smart_open")
telescope.load_extension("ui-select")

-- Open help files in the secondary window.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_secondary_window", { clear = true }),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == 'help' then
            -- First open: buffer is unlisted, in a vim-created window. Re-home
            -- it in our 'secondary' window.
            local buf = vim.api.nvim_get_current_buf()
            if not vim.bo[buf].buflisted then
                vim.bo[buf].buflisted = true
                vim.api.nvim_win_close(0, false)
                layout.open_buffer(buf, 'secondary', { focus = true })
            end
        end
    end
})

-- LspAttach autocmd for keymaps and per-buffer setup
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Keymaps
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', 'gt', vim.lsp.buf.type_definition, 'Goto definition of the type of symbol under cursor')
        map('n', 'gd', require('telescope.builtin').lsp_definitions, 'Goto definition of symbol under cursor')
        map('n', 'gD', vim.lsp.buf.declaration, 'Goto declaration of symbol under cursor')
        map('n', 'gi', require('telescope.builtin').lsp_implementations, 'Goto implementation of symbol under cursor')
        map('n', 'gr', require('telescope.builtin').lsp_references, 'List references of symbol under cursor')
        map('n', 'K', vim.lsp.buf.hover, 'Show info float for symbol under cursor')
        map('n', '<C-k>', vim.lsp.buf.signature_help, 'Show help float for symbol under cursor')
        map('n', '<leader>fr', require('telescope.builtin').lsp_document_symbols, 'Find symbol in file')
        map('n', '<leader>fe', require('telescope.builtin').lsp_workspace_symbols, 'Find symbol in workspace')
        map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, 'Format document')
        map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
        map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP code action')

        -- Auto-format on save
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr, id = client.id, async = false })
                end,
            })
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
    'nixd',
    'yamlls',
    'harper_ls',
    'mdx_analyzer',
}

-- Base capabilities for all servers
local capabilities = {}
capabilities.general = capabilities.general or {}
capabilities.general.positionEncodings = { "utf-16" }
capabilities.offsetEncoding = { 'utf-16' }

-- Configure base settings for all servers
vim.lsp.config('*', {
    capabilities = capabilities,
})

-- Server-specific settings
local server_settings = {
    nixd = {
        nixd = {
            formatting = {
                command = { "nixfmt" },
            },
        },
    },
    lua_ls = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'Lua 5.4',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            -- workspace = {
            --     -- Make the server aware of Neovim runtime files
            --     library = vim.api.nvim_get_runtime_file("", true),
            -- },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
            format = {
                enable = true,
            }
        },
    },
    harper_ls = {
        ["harper-ls"] = {
            dialect = "British",
            linters = {
                LongSentences = false,
            },
        },
    },
}

-- Configure each server
for _, server_name in pairs(supported_lsp_servers) do
    local config = {}

    if server_settings[server_name] then
        config.settings = server_settings[server_name]
    end

    if server_name == 'clangd' then
        config.cmd = { "clangd", "--offset-encoding=utf-16", "--clang-tidy" }
    end

    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
end

require('textcase').setup {}

require('gitsigns').setup()

-- Leap keymaps (default arrangement)
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

require('mini.comment').setup()
require('mini.icons').setup()
require('mini.snippets').setup()
require('mini.completion').setup()
require('mini.surround').setup()
require('mini.cursorword').setup()
require('mini.ai').setup()
require('mini.bracketed').setup()
require('mini.cmdline').setup()
require('mini.statusline').setup()
require('mini.tabline').setup()
require('mini.trailspace').setup()
require('mini.notify').setup()
-- require('mini.clue').setup()

require('note-to-midi')

-- .sh files get filetype `sh`, but our parser is named `bash`.
vim.treesitter.language.register('bash', 'sh')

-- tree-sitter-nix highlights use `is-not?`, which core nvim doesn't ship.
-- Stub it out so the parser's queries don't error.
vim.treesitter.query.add_predicate('is-not?', function() return true end, { force = true })

vim.filetype.add({
    extension = {
        mdx = "markdown",
    }
})

local function start_up_func()
    nvim_tree_api.tree.toggle({ focus = false })
end
-- scheduling it avoids a problem where it's always focused
vim.schedule(start_up_func)
