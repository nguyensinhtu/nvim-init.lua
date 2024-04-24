local main = require("tunguyen.dbt.main")

vim.api.nvim_create_user_command("DbtGenerateModelYaml", function(cmd)
	main.generate_model_yaml(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtGenerateBaseModel", function(cmd)
	main.generate_base_model(cmd.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("DbtGenerateSource", function(cmd)
    main.generate_source(cmd.args)
end, { nargs = 1 })
