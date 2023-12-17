local lsp_zero = require("lsp-zero")

lsp_zero.preset("recommended")

require("mason").setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    -- Replace these with whatever servers you want to install
    'pyright',
    'gopls',
    'ruff',
    'ruff_lsp',
    'black',
    'jdtls',
    'isort',
  },
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
    -- metals = lsp_zero.noop,
    rust_analyzer = lsp_zero.noop,
  }
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- define your keymap here
lsp_zero.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true, remap = false }
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
    vim.keymap.set('n', '<leader>lf', function()
        vim.lsp.buf.format({
            async = false,
            timeout_ms = 3200,
        })
    end, opts)

    vim.keymap.set('n', 'lf', '<cmd>lua vim.lsp.buf.format{ aync = true }<cr>', opts)
	vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

    -- dap
    vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, opts)
    vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end, opts)
    vim.keymap.set("n", "<leader>dK", function() require("dap.ui.widgets").hover() end, opts)

    vim.keymap.set("n", "<leader>dt", function()
      require("dap").toggle_breakpoint()
    end, opts)

    vim.keymap.set("n", "<leader>dso", function()
      require("dap").step_over()
    end, opts)

    vim.keymap.set("n", "<leader>dsi", function()
      require("dap").step_into()
    end, opts)

    vim.keymap.set("n", "<leader>dl", function()
      require("dap").run_last()
    end, opts)
end)

-- autocomplete
-- setup source
-- installed sources
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp_zero.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

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
    },
    mapping = cmp_mappings,
    -- Make the first item in completion menu always be selected.
    preselect = 'item',
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
})


-- ui
lsp_zero.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

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
local rust_tools = require('rust-tools')
rust_tools.setup({
  server = {
    on_attach = function()
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})

-- format on save
lsp_zero.format_on_save({
    format_opts = {
        async = false,
        timeout_ms = 10000,
    },
	servers = {
		['gopls'] = {'go', 'gomod', 'mod'},
		['pyright'] = {'py'},
        ['rust_analyzer']= { 'rs' },
        ['metals']= { 'scala' },
	}
})


-- scala
---
-- Create the configuration for metals
---
local metals_config = require('metals').bare_config()
metals_config.capabilities = lsp_zero.get_capabilities()

-- Debug settings if you're using nvim-dap
local dap = require("dap")

dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "RunOrTest",
    metals = {
      runType = "runOrTestFile",
      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = {
      runType = "testTarget",
    },
  },
}

metals_config.on_attach = function(client, bufnr)
  require("metals").setup_dap()
end

---
-- Autocmd that will actually be in charging of starting metals
---
local metals_augroup = vim.api.nvim_create_augroup('nvim-metals', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
  group = metals_augroup,
  pattern = {'scala', 'sbt'},
  callback = function()
    require('metals').initialize_or_attach(metals_config)
  end
})
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.scala",
--   callback = function()
--         vim.cmd("MetalsOrganizeImports") 
--   end,
--   group = metals_augroup,
-- })
--




-- DBT Setup --
if not lspconfig.dbtls then
    lspconfig.dbtls = {
        default_config = {
            root_dir = util.root_pattern('dbt_project.yml'),
            cmd = { 'dbt-language-server', '--stdio' },
            filetypes = {"sql"},
            init_options = { pythonInfo = { path = 'python3' }, lspMode = 'dbtProject', enableSnowflakeSyntaxCheck = false },
            settings = {},
      },
  }
end
lspconfig.dbtls.setup{}
