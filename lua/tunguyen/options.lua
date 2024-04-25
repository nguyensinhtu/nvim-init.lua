vim.opt.nu = true
vim.opt.relativenumber = true

-- tab config
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- search
vim.opt.hlsearch = true
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
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option("updatetime", 300)

-- color of floating window
-- vim.api.nvim_set_hl(0, 'FloatBorder', {bg='#3B4252', fg='#5E81AC'})
-- vim.api.nvim_set_hl(0, 'NormalFloat', {bg='#3B4252'})
-- vim.api.nvim_set_hl(0, 'TelescopeNormal', {bg='#3B4252'})
-- vim.api.nvim_set_hl(0, 'TelescopeBorder', {bg='#3B4252'})

-- disable language provider support (lua and vimscript plugins only)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
