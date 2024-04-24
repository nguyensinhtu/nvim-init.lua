local log = require("tunguyen.utils.log")

local client

local M = {}

M._get_clients = function()
    local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({
        name = "dbtls",
    })

    for _, c in ipairs(clients) do
        if c.name == "dbtls" then
            return c
        end
    end

    return nil
end

M.get_dbt_client = function()
    if client then
        return client
    end

    client = M._get_clients()
    return client
end

M.get_dbt_project_root = function()
    local dbt_client = M.get_dbt_client()
    if dbt_client then
        return dbt_client.config.root_dir
    end

    return nil
end

M.try_add = function(bufnr)
    local id = M.get_dbt_client().id
    if not id then
        return
    end

    local did_attach = vim.lsp.buf_is_attached(bufnr, id) or vim.lsp.buf_attach_client(bufnr, id)
    if not did_attach then
        log:warn(string.format("failed to attach buffer %d", bufnr))
    end

    return did_attach
end

M.retry_add = function(bufnr)
    local did_attach = M.try_add(bufnr)
    if did_attach then
        -- send synthetic didOpen notification to regenerate diagnostics
        M.get_dbt_client().notify("textDocument/didOpen", {
            textDocument = { uri = vim.uri_from_bufnr(bufnr) },
        })
    end
end

return M
