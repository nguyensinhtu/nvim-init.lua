require("tunguyen")

-- Lazy load
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load config
local load_config = function(name)
    return function()
        require("tunguyen.plugins." .. name)
    end
end

-- [[ Configure plugins ]]
require("lazy").setup({

    -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
    },

    {
        -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { "j-hui/fidget.nvim",       opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            -- Easy to view docs of functions, APIs, etc.
            "folke/neodev.nvim",
        },
        config = load_config("lsp-config"),
    },

    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets",
        },

        config = load_config("cmp"),
    },

    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        build = ":TSUpdate",

        config = load_config("treesitter"),
    },

    {
        -- Code formatting
        "jose-elias-alvarez/null-ls.nvim",
        config = load_config("null-ls"),
    },

    {
        -- Code commenting
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({
                padding = true,
                toggler = {
                    line = "gcc",
                    block = "gbc",
                },
            })
        end,
    },

    {
        -- This for surrouding words
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end,
    },

    {
        -- Manage mulitple terminal windows
        "akinsho/toggleterm.nvim",
        tag = "2.9.0",
        config = load_config("toggleterm"),
    },

    -- {
    --     -- File explorer
    --     "nvim-tree/nvim-tree.lua",
    --     config = load_config("nvim-tree"),
    -- },

    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = load_config("oil"),
    },

    -- [[ Rust setup ]]
    {
        -- Rust Tools
        "simrat39/rust-tools.nvim",
    },

    -- [[ Go setup ]]
    {
        "ray-x/go.nvim",
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
    },

    {
        -- recommended if need floating window support
        "ray-x/guihua.lua",
    },

    {
        -- View markdown files in nvim
        "ellisonleao/glow.nvim",
        config = function()
            require("glow").setup()
        end,
    },

    {
        -- JVM Language Server
        "mfussenegger/nvim-jdtls",
    },

    {
        -- A framework for interacting with tests within NeoVim.
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "f-person/git-blame.nvim",
        config = function()
            require("gitblame").setup({
                enabled = true,
                message_template = "<summary> • <date> • <author>",
            })
        end,
    },

    {
        -- scala
        "scalameta/nvim-metals",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
        -- dap for debuging and running application
        "mfussenegger/nvim-dap",
        tag = "0.6.0",
    },

    {
        -- Themes
        "folke/tokyonight.nvim",
    },

    {
        -- Copilot
        "github/copilot.vim",
    },

    {
        -- Watch file changes
        "rktjmp/fwatch.nvim",
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        config = load_config("null-ls"),
    },

    -- Themes
    { "catppuccin/nvim",             name = "catppuccin", priority = 1000 },
    { "Mofiqul/vscode.nvim",         priority = 1001 },
    { "projekt0n/github-nvim-theme", priority = 1001 },

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    -- For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins.
    -- { import = "tunguyen.plugins" },

    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_session_suppress_dirs = {
                    "~/",
                    "~/Projects",
                    "~/Downloads",
                    "/Documents",
                    "~/Pictures",
                    "~/Desktop",
                },
            })
        end,
    },

    { "rcarriga/nvim-notify" },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = load_config("lualine"),
    },
})

-- Loading personal settings
require("tunguyen.settings.python")

require("tunguyen.settings.themes")

require("tunguyen.settings.telescope")

require("auto-session").setup({
    log_level = "error",
    cwd_change_handling = {
        restore_upcoming_session = true, -- <-- THE DOCS LIE!! This is necessary!!
    },
})

-- Load dbt commands
require("tunguyen.dbt")

-- Handle cwd is different from starting directory when opening with oil.
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "oil:///*",
    callback = function()
        local current_dir = require("oil").get_current_dir()
        local parent = vim.fn.fnamemodify(current_dir, ":h")
        if vim.fn.getcwd() ~= parent then
            vim.notify("Changing directory to " .. parent)
            vim.api.nvim_set_current_dir(parent)
        end
    end,
})
