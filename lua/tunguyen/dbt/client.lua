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

return M
