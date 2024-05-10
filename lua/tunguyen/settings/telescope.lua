local builtin = require("telescope.builtin")

vim.api.nvim_set_hl(0, "NormalFloat", { fg = LightGrey })
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

vim.keymap.set("n", "<leader>sc", builtin.colorscheme, {})
