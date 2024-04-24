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
			{ "j-hui/fidget.nvim", opts = {} },

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

	{
		-- File explorer
		"nvim-tree/nvim-tree.lua",
		config = load_config("nvim-tree"),
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

	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

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

	{
		"PedramNavid/dbtpal",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		ft = {
			"sql",
			"md",
			"yaml",
		},
		keys = {
			{ "<leader>drf", "<cmd>DbtRun<cr>" },
			{ "<leader>drp", "<cmd>DbtRunAll<cr>" },
			{ "<leader>dtf", "<cmd>DbtTest<cr>" },
			{ "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
		},
		config = function()
			require("dbtpal").setup({
				path_to_dbt = "dbt",
				path_to_dbt_project = "",
				path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
				extended_path_search = true,
				protect_compiled_files = true,
			})
			require("telescope").load_extension("dbtpal")
		end,
	},
})

-- Loading personal settings
require("tunguyen.settings.python")

require("tunguyen.settings.themes")

require("tunguyen.settings.telescope")

local function close_nvim_tree()
	require("nvim-tree.view").close()
end

local function open_nvim_tree()
	require("nvim-tree.api").tree.open()
end
require("auto-session").setup({
	log_level = "error",
	pre_save_cmds = { close_nvim_tree },
	post_save_cmds = { open_nvim_tree },
	post_open_cmds = { open_nvim_tree },
	post_restore_cmds = { open_nvim_tree },
	cwd_change_handling = {
		restore_upcoming_session = true, -- <-- THE DOCS LIE!! This is necessary!!
	},
})

-- Load dbt commands
require("tunguyen.dbt")
