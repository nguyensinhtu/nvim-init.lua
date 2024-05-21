local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Define your keymap here
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true, remap = false }

    local nmap = function(keys, func, desc)
        local default_opts = opts
        if desc then
            desc = "LSP: " .. desc
            default_opts = vim.tbl_extend("force", default_opts, { desc = desc })
        end

        vim.keymap.set("n", keys, func, default_opts)
    end

    nmap("gd", vim.lsp.buf.definition)
    nmap("gi", vim.lsp.buf.implementation)
    nmap("[d", vim.diagnostic.goto_prev)
    nmap("]d", vim.diagnostic.goto_next)
    nmap("gr", require("telescope.builtin").lsp_references)
    nmap("<leader>lf", function()
        vim.lsp.buf.format({ async = false, timeout_ms = 3200 })
    end, "Format current buffer")
    nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")

    -- DAP
    nmap("<leader>dc", function()
        require("dap").continue()
    end, "Debug: Continue")
    nmap("<leader>dr", function()
        require("dap").repl.toggle()
    end, "Debug: Toggle Repl")
    nmap("<leader>dK", function()
        require("dap.ui.widgets").hover()
    end, "Debug: Hover")
    nmap("<leader>dt", function()
        require("dap").toggle_breakpoint()
    end, "Debug: Toggle breakpoint")
    nmap("<leader>dso", function()
        require("dap").step_over()
    end, "Debug: Step over")
    nmap("<leader>dsi", function()
        require("dap").step_into()
    end, "Debug: Step into")
    nmap("<leader>dl", function()
        require("dap").run_last()
    end, "Debug: Run last")
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local lspconfig = require("lspconfig")
local servers = {
    rust_analyzer = {},

    gopls = {
        cmd = { "gopls", "serve" },
        filetypes = { "go", "gomod" },
        root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
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

    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },

    pyright = {},
    ruff = {},
    ruff_lsp = {
        init_options = {
            settings = {
                interpreter = { "/Users/tunguyensinh/.pyenv/shims/python3" },
            },
        },
    },
    black = {},
    jdtls = {},
    isort = {},
}

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            init_options = (servers[server_name] or {}).init_options,
            settings = ((servers[server_name] or {}).settings or servers[server_name]),
            filetypes = (servers[server_name] or {}).filetypes,
        })
    end,
})

-- Could not install dbtls via Mason
local lsp_configs = require("lspconfig.configs")
if not lsp_configs.dbtls then
    lsp_configs.dbtls = {
        default_config = {
            root_dir = lspconfig.util.root_pattern("dbt_project.yml"),
            cmd = { "dbt-language-server", "--stdio" },
            filetypes = { "sql" },
            init_options = {
                pythonInfo = { path = "python3" },
                lspMode = "dbtProject",
                enableSnowflakeSyntaxCheck = false,
            },
            settings = {},
        },
    }
end
lspconfig.dbtls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- [[ DAP figuration ]]
-- For scala debugging
local metals_config = require("metals").bare_config()
metals_config.capabilities = capabilities

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

-- Autocmd that will actually be in charging of starting metals
local metals_augroup = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = metals_augroup,
    pattern = { "scala", "sbt" },
    callback = function()
        require("metals").initialize_or_attach(metals_config)
    end,
})
