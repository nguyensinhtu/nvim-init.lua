local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- local config_status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
-- if not config_status_ok then
--   return
-- end

-- local tree_cb = nvim_tree_config.nvim_tree_callback

local api = require "nvim-tree.api"
local options = { noremap = true, silent = true, nowait = true } 
local keymap = vim.keymap
keymap.set('n', '<leader>pe', function()
    if ( api.tree.is_visible() )
    then
        api.tree.focus()
    else
        api.tree.toggle()
    end
end, options)
-- this is like a double linked-list, every new opening item will be insert at the beginning of the list, so the prev with will be the next in the list  
keymap.set('n', '<leader>pw', function()
    api.node.navigate.opened.prev()
    api.node.open.edit()
end, options)

keymap.set('n', '<leader>pb', function()
    api.node.navigate.opened.next()
    api.node.open.edit()
end, options)


nvim_tree.setup {
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  renderer = {
    root_folder_modifier = ":t",
    highlight_opened_files = "name",
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  view = {
    width = 30,
    side = "left",
  },
}

-- this cmd will check NvimTree was openned when it is restored and refresh it 
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = 'NvimTree*',
  callback = function()
    local api = require('nvim-tree.api')
    local view = require('nvim-tree.view')

    if not view.is_visible() then
      api.tree.open()
    end
  end,
})
