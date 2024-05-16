local M = {}
local J = require("plenary.job")
local log = require("tunguyen.utils.log")
local commands = require("tunguyen.dbt.commands")

M.clone_model = function(args)
    local model_name = vim.fn.expand("%:t:r")

    local notify = require("notify").notify

    notify("Cloning dbt model: " .. model_name, "info", { render = "compact", title = "dbt" })

    local on_exit = function(result, code)
        if code >= 1 then
            notify(
                "Failed to clone dbt model: " .. model_name .. " error: " .. table.concat(result, " "),
                "error",
                { render = "wrapped-compact", title = "dbt" }
            )
            return
        end
        notify("Cloned dbt model: " .. model_name, "info", { render = "compact", title = "dbt" })
    end

    -- List out all dependencies
    local dbt_path, dbt_args = commands.build_dbt_path_args("ls", {
        "--quiet",
        "--models",
        "+" .. model_name,
        "--output",
        "json",
        "--output-keys",
        "database schema name depends_on unique_id alias",
    })

    local clone_py = vim.fn.fnamemodify("~/.config/nvim/scripts/dbt/clone_dbt_model.py", ":p")
    if vim.fn.filereadable(clone_py) == 0 then
        log.warn("Cannot find the python script to clone dbt model: ", clone_py)
        return
    end

    local dependencies = {}
    -- List out all dependencies of the model
    local job = J:new({
        command = dbt_path,
        args = dbt_args,
        on_exit = function(j, code)
            log.info("dbt ls command exited with code: ", code)
            if code >= 1 then
                vim.schedule(function()
                    on_exit(j:result(), code)
                end)
                return
            end

            vim.list_extend(dependencies, j:result())
        end,
    })

    job:and_then_on_success(

    -- Here we don't try to find which python path is active,
    -- we just assume that user activated the python venv before opening the project.
        J:new({
            command = "python3",
            args = {
                clone_py,
                table.concat(dependencies, "\n"),
            },
            on_exit = function(j, code)
                vim.schedule(function()
                    on_exit(j:result(), code)
                end)
            end,
        })
    )

    job:start()
end

return M
