local operator = require("tunguyen.dbt.operator")

-- dbt run-operator cmds
vim.api.nvim_create_user_command("DbtGenModelYaml", function(cmd)
    operator.generate_model_yaml(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtGenBaseModel", function(cmd)
    operator.generate_base_model(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtGenSource", function(cmd)
    operator.generate_source(cmd.args)
end, { nargs = 1 })

-- dbt model commands
local model = require("tunguyen.dbt.model")

-- Commands
vim.api.nvim_create_user_command("DbtRun", function()
    model.run()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DbtRunAll", function(cmd)
    model.run_all(cmd.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("DbtRunModel", function(cmd)
    model.run_model(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtTest", function()
    model.test()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DbtTestAll", function(cmd)
    model.test_all(cmd.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("DbtTestModel", function(cmd)
    model.test_model(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtCompile", function()
    model.compile()
end, { nargs = 0 })

vim.api.nvim_create_user_command("DbtBuild", function()
    model.build()
end, { nargs = 0 })

-- Show notify history
vim.api.nvim_create_user_command("DbtHistory", function()
    require("telescope").extensions.notify.notify()
end, { nargs = 0 })

-- Format model

vim.api.nvim_create_user_command("DbtFix", function()
    model.fix()
end, { nargs = 0 })

vim.api.nvim_set_keymap("n", "<leader>dm", ":lua require('notify').dismiss()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>dh", "<", { noremap = true, silent = true })

return M
