local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

-- format on save
local format_sync_grp = vim.api.nvim_create_augroup("PyFmt", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
        vim.lsp.buf.format()
  end,
  group = format_sync_grp,
})


--- snipets
local ls = require("luasnip")

-- This is a snippet creator
local s = ls.s

-- This is insert mode
local i = ls.insert_node

local c = ls.choice_node

local t = ls.text_node

local python_ts = require('tunguyen.ts.python')

function in_class_but_not_in_def()
    return python_ts.in_class() and not python_ts.in_def() 
end

local in_class_only = {
  show_condition = in_class_but_not_in_def,
  condition = in_class_but_not_in_def,
}

-- This is format node.
local fmt = require('luasnip.extras.fmt').fmt

local snippets = {
    -- s(
    --     { trig = "main", dscr = "main function" },
    --     fmt(
    --         "if __name__==\"__main__\":\n\t{}" 
    --         , {
    --             ls.i(1, "pass"), 
    --         }
    --     ),
    -- ),
    -- s(
    --     { trig = "ifep", name = "Simple if error panic", dscr = "If error, panic" },
    --     fmt("if {} != nil {{\n\tpanic(err)\n}}\n", {
    --       ls.i(1, "err"),
    --     }),
    -- ),

    s(
        { trig = "main", dscr = "main function" },
		fmt("if __name__==\"__main__\":\n\t{}", {
			i(1, "pass"),
		})
	),
    s(
        { trig = "for", dscr = "for in" },
		fmt("for {} in {}:\n\t{}", {
			i(1, "var1"),
			i(2, "var2"),
			i(3, "pass"),
		})
	),
    s(
        { trig = "fori", dscr = "for with index" },
		fmt("for {}, {} in enumerate({}):\n\t{}", {
			i(1, "idx"),
			i(2, "var1"),
			i(3, "var2"),
			i(4, "pass"),
		})
	),
    s(
        { trig = "forr", dscr = "for in range" },
		fmt("for {} in range({}, {}):\n\t{}", {
			i(1, "idx"),
			i(2, "start"),
			i(3, "end"),
			i(4, "pass"),
		})
	),


    -- try catch
    s(
        { trig = "try", dscr = "try catch exception" },
		fmt("try:\n\t{}\nexcept {}:\n\t{}", {
			i(1, "pass"),
			i(2, "Exception as e"),
			i(3, "print(e)"),
		})
	),

    s(
        { trig = "tryf", dscr = "try catch finally exception" },
		fmt("try:\n\t{}\nexcept {}:\n\t{}\nfinally:\n\t{}", {
			i(1, "pass"),
			i(2, "Exception as e"),
			i(3, "print(e)"),
			i(3, "pass"),
		})
	),


    -- def __init__ --
    s(
        { trig = "init", dscr = "def __init__" },
		fmt("def __init__(self, {}):\n\t{}", {
			i(1, "params"),
			i(2, "pass"),
		})
	),

    -- functions
    s(
        { trig = "def", dscr = "create definition" },
		fmt("def {}(self, {}):\n\t{}", {
			i(1, "func"),
			i(2, "params"),
			i(3, "pass"),
		}),
        in_class_only
	),
    s(
        { trig = "def", dscr = "create definition" },
		fmt("def {}({}):\n\t{}", {
			i(1, "func"),
			i(2, "params"),
			i(3, "pass"),
		})
	),
}

ls.add_snippets("python", snippets)
