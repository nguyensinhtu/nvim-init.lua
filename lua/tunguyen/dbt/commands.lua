local log = require("tunguyen.utils.log")

local M = {}

local get_dbt_version = function()
    local cmd = vim.fn.systemlist("dbt --version | grep -Eo '[0-9]+\\.[0-9]+' | head -n 1")
    local version = cmd[1]
    -- log.debug("dbt version: " .. version)
    return tonumber(version)
end

M.build_sqlfluff_path_args = function(cmd, args)
    local client = require("tunguyen.dbt.client")
    local sqlfluff_path = "sqlfluff"

    local cmd_args = {}

    local post_cmd_args = {}
    table.insert(post_cmd_args, "--force")
    table.insert(post_cmd_args, "--quiet")
    table.insert(post_cmd_args, "--nocolor")

    local sqlfluff_cfg_path = client.get_dbt_project_root() .. "/.sqlfluff"
    if vim.fn.filereadable(sqlfluff_cfg_path) == 1 then
        table.insert(post_cmd_args, "--config")
        table.insert(post_cmd_args, sqlfluff_cfg_path)
    end

    vim.list_extend(cmd_args, { cmd })
    vim.list_extend(cmd_args, args)
    vim.list_extend(cmd_args, post_cmd_args)

    -- log.debug("Building sqlfluff command: " .. sqlfluff_path .. " " .. table.concat(cmd_args, " "))

    return sqlfluff_path, cmd_args
end

M.build_dbt_path_args = function(cmd, args)
    local client = require("tunguyen.dbt.client")
    local dbt_path = "dbt"
    local dbt_project = client.get_dbt_project_root()
    local dbt_profile = client.get_dbt_project_root()

    local cmd_args = {}

    local pre_cmd_args = {}

    vim.list_extend(pre_cmd_args, { "--log-level=INFO" })

    local post_cmd_args = {}
    if dbt_profile ~= "v:null" then
        table.insert(post_cmd_args, "--profiles-dir")
        table.insert(post_cmd_args, dbt_profile)
    end

    table.insert(post_cmd_args, "--project-dir")
    table.insert(post_cmd_args, dbt_project)

    vim.list_extend(cmd_args, pre_cmd_args)
    vim.list_extend(cmd_args, { cmd })

    if type(args) == "string" then
        args = vim.split(args, " ")
    end

    if args ~= nil then
        vim.list_extend(cmd_args, args)
    end

    vim.list_extend(cmd_args, post_cmd_args)

    -- log.debug("Building dbt command: " .. dbt_path .. " " .. table.concat(cmd_args, " "))

    return dbt_path, cmd_args
end

return M
