-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

-- Autocommand that reloads neovim whenever you save packer.lua
vim.api.nvim_create_autocmd("BufWritePost", {
    -- clear = true (delele all cmd in group)
    group = vim.api.nvim_create_augroup("packer_user_config", { clear = true }),

    pattern = "packer.lua",
    callback = function()
        vim.cmd("PackerSync")
    end
})



return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.0',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- this is for lsp + autocomplete
  use {
	'VonHeikemen/lsp-zero.nvim',
	branch = 'v2.x',
	requires = {
		-- LSP Support
		{'neovim/nvim-lspconfig'},             -- Required
		{                                      -- Optional, this will auto install lsp server for you
		  'williamboman/mason.nvim',
		  run = function()
			pcall(vim.cmd, 'MasonUpdate')
		  end,
		},
        {'williamboman/mason-lspconfig.nvim'}, -- Optional

		-- Autocompletion
		{'hrsh7th/nvim-cmp'},     -- Required
		{'hrsh7th/cmp-nvim-lsp'}, -- Required
		{'L3MON4D3/LuaSnip'},     -- Required
	  }
	}

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate'})

    use('jose-elias-alvarez/null-ls.nvim')

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    -- this for surrouding words 
    use({
        "kylechui/nvim-surround",
        tag = "*", -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    })

    -- manage mulitple terminal windows 
    use {"akinsho/toggleterm.nvim", tag = '*'}

    -- file explorer
    use {
      'nvim-tree/nvim-tree.lua',
    }

    -- rust
    use { 'simrat39/rust-tools.nvim', }

    -- golang built tools
    use { 'ray-x/go.nvim' }
    use 'ray-x/guihua.lua' -- recommended if need floating window support
    use {
      'rmagatti/auto-session',
    }

    use {"ellisonleao/glow.nvim", config = function() require("glow").setup() end}

    use({
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v2.0.0", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        after = 'nvim-cmp',
        dependencies = { "rafamadriz/friendly-snippets" },

    })

    use { 'saadparwaiz1/cmp_luasnip' }

    use { 'mfussenegger/nvim-jdtls' }

    use { 'folke/tokyonight.nvim' }
    -- use { 'Mofiqul/dracula.nvim' }

    use {
      "nvim-neotest/neotest",
      dependencies = {
        "antoinemadec/FixCursorHold.nvim"
      },
      requires = {
          -- others adapter here: https://github.com/nvim-neotest/neotest#supported-runners
          "nvim-neotest/neotest-python"
      }
    }

    use {
        "f-person/git-blame.nvim",
        config = function()
            require("gitblame").setup({
                enabled = true,
                message_template = '<summary> • <date> • <author>',

            })
        end
    }

    -- scala
    use({'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" }})


    -- dap for debuging and running application
    use({ 'mfussenegger/nvim-dap', tag = '0.6.0' })

    -- dbt setup
    use {'PedramNavid/dbtpal',
        requires = { { 'nvim-lua/plenary.nvim' }, {'nvim-telescope/telescope.nvim'} }
    }

end)

