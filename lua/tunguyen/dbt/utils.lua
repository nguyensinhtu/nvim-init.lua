local log = require("tunguyen.utils.log")

local M = {}

M.buf = {
    for_each_bufnr = function(cb)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
                cb(bufnr)
            end
        end
    end,
}

M.build_generator_path_args = function(cmd, args, config, args_spec)
    local dbt_path = config.path_to_dbt
    local dbt_project = config.path_to_dbt_project
    local dbt_profile = config.path_to_dbt_profiles_dir

    local cmd_args = {}

    -- TODO: make this configurable
    local pre_cmd_args = config.pre_cmd_args or {}

    vim.list_extend(pre_cmd_args, { "--quiet" })

    local post_cmd_args = {}
    if dbt_profile ~= "v:null" then
        table.insert(post_cmd_args, "--profiles-dir")
        table.insert(post_cmd_args, dbt_profile)
    end

    table.insert(post_cmd_args, "--project-dir")
    table.insert(post_cmd_args, dbt_project)

    vim.list_extend(cmd_args, pre_cmd_args)
    vim.list_extend(cmd_args, cmd)


    if type(args) == "string" then
        args = vim.split(args, " ")
    end

    local payload = {}
    local key = nil
    for _, v in ipairs(args) do
        if v:sub(1, 2) == "--" then
            key = v:gsub("%-%-", "")
        else
            if key ~= nil then
                payload[key] = payload[key] or {}
                table.insert(payload[key], v)
            end
        end
    end

    for _, spec in pairs(args_spec) do
        local arg_name = spec.name
        local required = spec.required
        local default = spec.default
        local type = spec.type

        if payload[arg_name] == nil then
            if required then
                error("Missing required argument: " .. arg_name .. ", argument spec: " .. vim.inspect(spec))
                return
            end

            if default ~= nil then
                payload[arg_name] = default
            end

            goto continue
        end

        if type == "string" then
            payload[arg_name] = table.concat(payload[arg_name], " ")
        elseif type == "boolean" then
            payload[arg_name] = payload[arg_name][1] == "true"
        end

        ::continue::
    end

    if payload ~= nil and payload then
        table.insert(cmd_args, "--args")
        table.insert(cmd_args, vim.fn.json_encode(payload))
    end

    -- log.debug("payload: " .. vim.inspect(payload))

    vim.list_extend(cmd_args, post_cmd_args)

    return dbt_path, cmd_args
end

return M
