local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    vim.fn.notify("null-ls not found", "error")
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
    debug = true,
    sources = {
        null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.prettier.with({
            extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
            filetypes = { "html", "json", "yaml", "markdown" },
        }),
        null_ls.builtins.formatting.sqlfluff.with({
            args = {
                "fix",
                "--templater",
                "jinja",
                "--ignore",
                "templating",
                "--force",
                "--nocolor",
                "-",
            },
            extra_args = function(params)
                -- TODO: cache this path.
                local sqlfluff_cfg_path = vim.fn.findfile(".sqlfluff", params.bufname .. ";")
                if sqlfluff_cfg_path ~= "" then
                    local fullpath = vim.fn.fnamemodify(sqlfluff_cfg_path, ":p")
                    return params.options and { "--config", fullpath }
                else
                    return params.options
                end
            end,
        }),
        null_ls.builtins.formatting.isort.with({ "--stdout", "--filename", "$FILENAME", "-" }),
        null_ls.builtins.formatting.xmllint.with({ "--format" }),
        null_ls.builtins.formatting.stylua,
    },

    on_attach = function(client, bufnr)
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
            vim.lsp.buf.format({ async = true, timeout_ms = 10000 })
        end, "Format current buffer")
    end,
})
