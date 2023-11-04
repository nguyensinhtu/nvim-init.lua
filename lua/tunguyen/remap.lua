local km = vim.keymap

vim.g.mapleader = ","


-- in visual mode, this will move selected text around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


-- this keep search result in the middle of screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- replace on copy
-- normal: select word -> copy word -> delete word (this is suck, this will lose the clipboard) -> can not paste
-- this will be: select word -> copy word -> highlight destination word(visual mode) -> replace
vim.keymap.set("x", "<leader>p", "\"_dP")


-- yank to system clipboard (without switch clipboards)
vim.keymap.set("n", "<leader>yy", "\"+y")
vim.keymap.set("v", "<leader>yy", "\"+y")

-- yank all file
vim.keymap.set("n", "<leader>yf", "gg\"+yG")
vim.keymap.set("v", "<leader>yf", "gg\"+yG")


-- unmap
-- unmap gd (go to global definition is very slow)
vim.keymap.set("n", "gd", "<NOP>")
vim.keymap.set("v", "gd", "<NOP>")
