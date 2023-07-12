vim.opt.nu = true
vim.opt.relativenumber = true

-- tab config
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- number of ending lines 
vim.opt.scrolloff = 8

-- vim.opt.guifont={ "Monospace",  ":h12" }
vim.opt.guifont = { "Source Code Pro", ":h12" }


-- auto complete
--Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true}
vim.api.nvim_set_option('updatetime', 300) 
