local lsp = require("lsp-zero")

lsp.preset("recommended")


-- skip jdtls to make sure lsp-zero does not start jdtls
lsp.skip_server_setup({'jdtls'})

require("mason").setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    -- Replace these with whatever servers you want to install
    'pyright',
    'gopls',
    'ruff',
    'ruff_lsp',
    'black',
    'isort',
  }
})


local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- define your keymap here
lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
    vim.keymap.set('n', '<leader>lf', function()
        vim.lsp.buf.format({
            async = false,
            timeout_ms = 2000,
        })
    end, opts)
    vim.keymap.set('n', 'lf', '<cmd>lua vim.lsp.buf.format{ aync = true }<cr>', opts)
end)
	vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- autocomplete
-- setup source
-- installed sources
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
    sources = {
        {name = 'path'}, --file paths 
        {name = 'nvim_lsp', keyword_length = 3}, -- from language servers 
        {name = 'nvim_lsp_signature_help'}, -- display function signature with current parameters
        {name = 'nvim_lua', keyword_length = 2}, -- complete nvim's Lua runtime API
        {name = 'luasnip', keyword_length = 2},
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    }
})

local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

-- ui
lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.setup()

local lspconfig = require('lspconfig.configs')
local util = require("lspconfig/util")

------ Golang setup ------
require("go").setup({
    go = "go", -- go command, can be go[default] or go1.18beta1
    goimport = "gopls", -- goimport command, can be gopls[default] or goimport
    fillstruct = "gopls", -- can be nil (use fillstruct, slower) and gopls
    gofmt = "gofumpt", -- gofmt cmd,
    max_line_len = 120, -- max line length in goline format
    verbse = false, -- output loginf in message
    gopls_cmd = nil, -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
    luasnip = true,
    run_in_floaterm = true, -- floating window
    lsp_cfg = true, -- using non-default lspconfig
})


-- Run GoFmt before write file
local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
        vim.cmd("GoFmt") 
  end,
  group = format_sync_grp,
})

lspconfig.gopls.setup {
	default_config = {
		cmd = {"gopls", "serve"},
		filetypes = {"go", "gomod"},
		root_dir = util.root_pattern("go.mod", ".git"),
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
				},
				staticcheck = true,
                usePlaceholders = true,
                completeUnimported = true,
			},
		},
	},
}

------ Rust setup ------
lsp.skip_server_setup({'rust_analyzer'})
lsp.setup()
local rust_tools = require('rust-tools')
rust_tools.setup({
  server = {
    on_attach = function()
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})


------ Python setup ------
require('lspconfig').ruff_lsp.setup {
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}
lsp.setup()

-- format on save
lsp.format_on_save({
	servers = {
		['gopls'] = {'go', 'gomod', 'mod'},
		['pyright'] = {'py'},
        ['rust_analyzer']= { 'rs' },
	}
})
