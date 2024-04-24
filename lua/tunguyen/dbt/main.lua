local vfn = vim.fn
local client = require("tunguyen.dbt.client")
local log = require("tunguyen.utils.log")
local Utils = require("tunguyen.dbt.utils")
local J = require("plenary.job")
local display = require("dbtpal.display")

local M = {}

M._cmd_run_operation = function(operation, args, arg_spec)
    return M._create_job({ "run-operation", operation }, args, arg_spec, vim.api.nvim_buf_get_name(0))
end

M.generate_model_yaml = function(args)
    local arg_spec = {
        {
            name = "model_names",
            required = true,
            type = "list",
        },
        {
            name = "include_data_types",
            required = false,
            default = false,
            type = "boolean",
        },
    }
    return M._cmd_run_operation("generate_model_yaml", args, arg_spec)
end

M.generate_base_model = function(args)
    local arg_spec = {
        {
            name = "source_name",
            required = true,
            type = "string",
        },
        {
            name = "table_name",
            required = true,
            type = "string",
        },
    }
    return M._cmd_run_operation("generate_base_model", args, arg_spec)
end

M.generate_source = function(args)
    local arg_spec = {
        {
            name = "schema_name",
            required = true,
            type = "string",
        },

        {
            name = "database_name",
            required = false,
            type = "string",
        },
        {
            name = "table_names",
            required = false,
            type = "list",
        },

        {
            name = "generate_columns",
            required = false,
            type = "boolean",
            default = "false",
        },

        {
            name = "include_descriptions",
            required = false,
            type = "boolean",
            default = "false",
        },
        {
            name = "include_data_types",
            required = false,
            type = "boolean",
            default = "true",
        },

        {
            name = "include_database",
            required = false,
            type = "boolean",
            default = "false",
        },
        {
            name = "include_schema",
            required = false,
            type = "boolean",
            default = "false",
        },
    }
    return M._cmd_run_operation("generate_source", args, arg_spec)
end

M._create_job = function(cmd, args, arg_spec, bufname)
    if client.get_dbt_project_root() == nil then
        log.warn(
            "Could not detect dbt project dir, try setting it manually or make sure this file is in a dbt project folder"
        )
        return
    end

    local onexit_success = function(data, bufname)
        -- Get bufnr from bufname
        local bufnr = vim.uri_to_bufnr("file:///" .. bufname)

        if not vim.api.nvim_buf_is_loaded(bufnr) then
            return
        end

        vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, data)
        client.retry_add(bufnr)
    end

    local onexit_failed = function(data)
        display.popup(data)
    end

    if args == "" then
        args = nil
    end

    local config = {
        path_to_dbt = "dbt",
        path_to_dbt_project = client.get_dbt_project_root(),
        path_to_dbt_profiles_dir = client.get_dbt_project_root(),
    }

    local dbt_path, cmd_args, err = Utils.build_generator_path_args(cmd, args, config, arg_spec)

    -- log.debug("Executing dbt command: ", dbt_path, cmd_args)

    if err then
        log.error("Failed to build dbt command: ", err)
        return
    end

    local response = {}
    local job = J:new({
        command = dbt_path,
        args = cmd_args,
        on_exit = function(j, code)
            if code == 1 then
                vim.list_extend(response, j:result())
                log.info("dbt command encounted a handled error, see popup for details")
            elseif code >= 2 then
                table.insert(response, "Failed to run dbt command. Exit Code: " .. code .. "\n")
                local a = table.concat(cmd_args, " ") or ""
                local err = string.format("dbt command failed: dbt_path: %s args: %s\n\n", dbt_path, a)
                table.insert(response, "------------\n")
                table.insert(response, err)
                vim.list_extend(response, j:result())
                vim.list_extend(response, j:stderr_result())
            else
                vim.schedule(function()
                    onexit_success(j:result(), bufname)
                end)
            end

            if code >= 1 then
                vim.schedule(function()
                    onexit_failed(response)
                end)
            end
        end,
    })
    job:start()
    return job
end

return M
