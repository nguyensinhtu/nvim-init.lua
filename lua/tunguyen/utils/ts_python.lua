local tsutil = require('nvim-treesitter.ts_utils')

local M = {
}

function M.in_class()
	local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
	if not ok then
		return false
	end
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return false
	end

	local expr = current_node
	while expr do
		if expr:type() == 'class_definition' then
			return true
		end
		expr = expr:parent()
	end
	return false
end

function M.in_def()
	local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
	if not ok then
		return false
	end
	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		return false
	end

	local expr = current_node
	while expr do
		if expr:type() == 'function_definition' then
			return true
		end
		expr = expr:parent()
	end
	return false
end

return M
