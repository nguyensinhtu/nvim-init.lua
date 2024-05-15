local log = require("tunguyen.utils.log")
local commands = require("tunguyen.dbt.commands")

local M = {}

local _do_nothing_callback = function() end

local _cmd_select_args = function(cmd, selector, args, onexit_failed, onexit_success)
	local a = require("plenary.async")

	a.run(function()
		local notify = require("notify").async
		notify("Running " .. cmd .. " command").events.close(function()
			if selector == nil then
				return M._create_job({
					cmd = cmd,
					args = args,
					onexit_failed = onexit_failed,
					onexit_success = onexit_success,
				})
			end

			if type(selector) == "string" then
				return M._create_job({
					cmd = cmd,
					args = vim.list_extend({ "--select", selector }, args or {}),
					onexit_failed = onexit_failed,
					onexit_success = onexit_success,
				})
			end

			if type(selector) == "table" then
				return M._create_job({
					cmd = cmd,
					args = vim.list_extend({ "--select", table.concat(selector, " ") }, args or {}),
					onexit_failed = onexit_failed,
					onexit_success = onexit_success,
				})
			end
		end)
	end, _do_nothing_callback)
end

local _cmd_fix_model_args = function(cmd, model_path)
	if type(model_path) == "string" then
		local a = require("plenary.async")
		a.run(function()
			local notify = require("notify").async
			notify("Running sqlfluff with " .. cmd .. " command").events.close(function()
				return M._create_job({
					cmd = cmd,
					args = { model_path },
					onexit_success = nil,
					onexit_failed = nil,
					is_dbt_cmd = false,
				})
			end)
		end, _do_nothing_callback)
	end
end

local _run = function(selector, args)
	return _cmd_select_args("run", selector, args)
end

local _test = function(selector, args)
	return _cmd_select_args("test", selector, args)
end

local _compile = function()
	return _cmd_select_args("compile", vim.fn.expand("%:t:r"), nil, nil, function(data)
		local pattern = "([0-9][0-9]):([0-9][0-9]):([0-9][0-9])"
		local cleaned = {}
		for _, line in ipairs(data) do
			if line ~= nil and line ~= "" and string.match(line, pattern) == nil then
				table.insert(cleaned, line)
			end
		end
		vim.fn.setreg("*", table.concat(cleaned, "\n"))
	end)
end

local _build = function(selector, args)
	return _cmd_select_args("build", selector, args)
end

M.run_all = function(args)
	return _run(nil, args)
end

M.run_model = function(selector, args)
	return _run(selector, args)
end

M.run = function()
	return _run(vim.fn.expand("%:t:r"))
end

M.run_children = function()
	return _run(vim.fn.expand("%:t:r") .. "+")
end
M.run_parents = function()
	return _run("+" .. vim.fn.expand("%:t:r"))
end
M.run_family = function()
	return _run("+" .. vim.fn.expand("%:t:r") .. "+")
end

M.test_all = function(args)
	return _test(nil, args)
end

M.test_model = function(selector, args)
	return _test(selector, args)
end

M.test = function()
	return _test(vim.fn.expand("%:t:r"))
end

M.compile = function(selector, args)
	return _compile(selector, args)
end

M.compile_and_copy = function(selector, args)
	return _compile_and_copy(vim.fn.expand("%:t:r"), args)
end

M.build = function(selector, args)
	return _build(selector, args)
end

M.run_command = function(cmd, args)
	return _cmd_select_args(cmd, args)
end

M.fix = function(cmd, args)
	return _cmd_fix_model_args("fix", vim.fn.expand("%:p"))
end

M._create_job = function(options)
	local J = require("plenary.job")
	options = options or {}

	local cmd, args, in_onexit_failed, in_onexit_success =
		options.cmd, options.args, options.onexit_failed, options.onexit_success

	-- log.info("dbt " .. cmd .. " queued")

	if args == "" then
		args = nil
	end

	local cmd_path, cmd_args
	if options.is_dbt_cmd == nil or options.is_dbt_cmd == true then
		cmd_path, cmd_args = commands.build_dbt_path_args(cmd, args)
	else
		log.debug("sqlfluff command")
		cmd_path, cmd_args = commands.build_sqlfluff_path_args(cmd, args)
	end

	local onexit_failed = function(data)
		if in_onexit_failed then
			in_onexit_failed(data)
		end
		require("notify").notify(table.concat(data, "\n"), "error", { timeout = 10000, title = cmd_path })
	end

	local onexit_success = function(data)
		if in_onexit_success then
			in_onexit_success(data)
		end

		require("notify").notify(
			table.concat(cmd_args, " ") .. " ran success",
			"info",
			{ timeout = 5000, render = "wrapped-compact", title = cmd_path }
		)
	end

	local response = {}
	local job = J:new({
		command = cmd_path,
		args = cmd_args,
		on_exit = function(j, code)
			if code == 1 then
				vim.list_extend(response, j:result())
				log.warn(cmd .. " command encounted a handled error, see popup for details")
			elseif code >= 2 then
				table.insert(response, "Failed to run " .. cmd_path .. " command. Exit Code: " .. code .. "\n")
				local a = table.concat(cmd_args, " ") or ""
				local err = string.format(cmd_path .. " command failed: %s %s\n\n", cmd_path, a)
				table.insert(response, "------------\n")
				table.insert(response, err)
				log.debug(j)
				vim.list_extend(response, j:result())
				vim.list_extend(response, j:stderr_result())
			else
				response = j:result()
			end

			if code >= 1 then
				vim.schedule(function()
					onexit_failed(response)
				end)
			else
				vim.schedule(function()
					onexit_success(response)
				end)
			end
		end,
	})
	job:start()
	return job
end

return M
