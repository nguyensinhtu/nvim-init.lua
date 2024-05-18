require("oil").setup({

    view_options = {
        is_hidden_file = function(name, bufnr)
            if vim.tbl_contains({ ".dlt", ".env" }, name) then
                return false
            end
            return vim.startswith(name, ".")
        end,
    },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd("DirChanged", {
    pattern = "*",
    callback = function()
        vim.notify("DirChanged")
        vim.schedule_wrap(require("oil").open)(vim.v.event.cwd)
    end,
})

-- vim.keymap.set("n", "<C-p>", "<cmd>lua actions.preview<cr>", { desc = "Open parent directory" })
