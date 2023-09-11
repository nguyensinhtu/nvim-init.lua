local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

-- Define a custom command that runs a Python file in a floating window
vim.cmd([[command! PyRun :lua RunPythonFile()]])
-- Function to execute a Python file in a floating window
function RunPythonFile()
  local python_file = vim.fn.expand('%')  -- Get the current file name
  if python_file == '' then
    print('No file name')
    return

  local cmd = "python " .. vim.fn.shellescape(python_file)
  local term_name = "python_term"

  -- Check if the terminal already exists
  if not vim.g["term_" .. term_name] then
    toggleterm.open({
      cmd = cmd,
      name = term_name,
      direction = "float",
      float_opts = {
        border = "single",
        width = 0.8,
        height = 0.8,
        winblend = 3,
        external_border = 1,
      },
    })
  else
    toggleterm.exec(term_name, cmd)
  end
end


