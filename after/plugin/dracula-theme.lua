local status_ok, dracula = pcall(require, "dracula")
if not status_ok then
	return
end

dracula.setup({})

local colorscheme = "dracula"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end


