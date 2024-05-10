local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local api = require("nvim-tree.api")
local options = { noremap = true, silent = true, nowait = true }
local keymap = vim.keymap
keymap.set("n", "<leader>pe", function()
    if api.tree.is_visible() then
        api.tree.focus()
    else
        api.tree.toggle()
    end
end, options)
keymap.set("n", "<leader>pt", function()
    api.tree.toggle()
end, options)

-- this is like a double linked-list, every new opening item will be insert at the beginning of the list, so the prev with will be the next in the list
keymap.set("n", "<leader>pw", function()
    api.node.navigate.opened.prev()
    api.node.open.edit()
end, options)

keymap.set("n", "<leader>pb", function()
    api.node.navigate.opened.next()
    api.node.open.edit()
end, options)

nvim_tree.setup({
    auto_close = true,
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
    renderer = {
        root_folder_modifier = ":t",
        highlight_opened_files = "name",
        group_empty = true,
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
    view = {
        -- width = 30,
        adaptive_size = true,
        side = "left",
    },
    actions = {
        open_file = {
            resize_window = true,
        },
        change_dir = {
            global = true,
        },
    },
    -- sync_root_with_cwd = true,
    prefer_startup_root = true,

    respect_buf_cwd = false,
})

-- Auto close nvim-tree
-- code: https://github.com/nvim-tree/nvim-tree.lua/discussions/1130
-- vim.api.nvim_create_autocmd("BufEnter", {
--     nested = true,
--     callback = function()
--         -- Check if the nvim-tree window is open and there is another buffer open
--         if #vim.api.nvim_list_wins() == 2 and vim.api.nvim_buf_get_name(1):match("NvimTree_") ~= nil then
--             local window_to_close = vim.fn.win_getid(vim.fn.bufwinnr(1))
--             if window_to_close > 0 then
--                 vim.api.nvim_win_close(window_to_close, true)
--             end
--         end
--     end,
-- })
