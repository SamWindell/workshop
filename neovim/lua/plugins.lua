local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd [[packadd packer.nvim]]

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function(use)
    use {
        "danielfalk/smart-open.nvim",
        -- branch = "0.2.x",
        requires = {
            { "kkharji/sqlite.lua" },
            { "nvim-telescope/telescope-fzy-native.nvim" },
        }
    }
    use 'williamboman/mason-lspconfig.nvim'
    use 'ggandor/leap.nvim'
    use { 'leafOfTree/vim-svelte-plugin',
        requires = { 'leafgarland/typescript-vim' }
    }
    use 'theHamsta/nvim-dap-virtual-text'
    use 'nvim-telescope/telescope-dap.nvim'
    use "folke/neodev.nvim"
    use 'RRethy/vim-illuminate'
    use 'ziglang/zig.vim'
    use { 'akinsho/bufferline.nvim' }
    use 'projekt0n/github-nvim-theme'
    use 'wbthomason/packer.nvim'
    use "rebelot/kanagawa.nvim"
    use 'Pocco81/true-zen.nvim'
    use {
        'nvim-telescope/telescope.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run =
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
    }
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/cmp-path'
    use 'L3MON4D3/LuaSnip'
    use({
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })
    use 'saadparwaiz1/cmp_luasnip'
    use 'bkad/CamelCaseMotion'
    use 'williamboman/mason.nvim'
    use 'lewis6991/gitsigns.nvim'
    use 'numToStr/Comment.nvim'
    use { "mfussenegger/nvim-dap" }
    use 'folke/which-key.nvim'
    use 'wellle/targets.vim'
    use 'kyazdani42/nvim-web-devicons'
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
