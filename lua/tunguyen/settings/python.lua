local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    return
end

-- Supporting when using pyproject.toml,
-- Problem: when using `peotry add` to add packages to pyproject.toml lsp server didn't know about it
-- Solution: watch poetry.lock changes and restart pyright server

local fwatch = require("fwatch")
function py_watch_file(fname)
    local fullpath = vim.api.nvim_call_function("fnamemodify", { fname, ":p" })
    fwatch.watch(fullpath, {
        on_event = function()
            local clients = (vim.lsp.get_clients or vim.lsp.get_active_clients)({
                name = "pyright",
            })

            for _, client in ipairs(clients) do
                -- vim.notify("[pyright] Restarting pyright server")
                client.notify("workspace/didChangeConfiguration", { settings = nil })
            end
        end,
    })
end

-- Auto select watch env changes when opening project.
-- vim.api.nvim_create_autocmd("VimEnter", {
--     desc = "Auto select virtualenv Nvim open",
--     pattern = "*",
--     callback = function()
--         -- First check if current virtualenv is activated
--         local exepath = vim.fn.exepath("python")
--         if exepath == "" then
--             vim.notify("[pyright] Error: Can't find python executable")
--             return
--         end
--
--         -- Get absolute path of python executable
--         local pythonpath = vim.api.nvim_call_function("fnamemodify", { exepath, ":h:h" })
--
--         -- Search for site-packages of current virtualenv
--         local site_packages = nil
--         if pythonpath:find(vim.fn.getcwd(), 1, true) then
--             local cmd = "fd -HItd -tl --absolute-path --max-depth 3 --color never site-packages " .. pythonpath
--             local openPop = assert(io.popen(cmd, "r"))
--             site_packages = openPop:read()
--             openPop:close()
--         end
--
--         if site_packages ~= nil and site_packages ~= "" then
--             vim.notify("[pyright] Watching site-packages: " .. site_packages)
--             py_watch_file(site_packages)
--             return
--         end
--
--         -- In case of poetry project
--         -- Check if pyproject.toml and poetry.lock exists
--         local pyproject_toml = vim.fn.findfile("pyproject.toml", ".;", true)
--         -- Watching pyproject.lock changes and restart pyright
--         local poetry_lock = vim.fn.findfile("poetry.lock", vim.fn.getcwd() .. ";")
--
--         if pyproject_toml ~= "" and poetry_lock ~= "" then
--             vim.notify("[pyright] Watching poetry.lock")
--             py_watch_file(poetry_lock)
--             return
--         end
--     end,
--     once = true,
-- })
-- END --

-- TESTIGN AND CMDS ---
local create_cmd = function(cmd, func, opt)
    opt = vim.tbl_extend("force", { desc = "python_nvim " .. cmd }, opt or {})
    vim.api.nvim_create_user_command(cmd, func, opt)
end

-- require("neotest").setup({
-- 	adapters = {
-- 		require("neotest-python")({
-- 			-- Extra arguments for nvim-dap configuration
-- 			-- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
-- 			dap = { justMyCode = false },
-- 			-- Command line arguments for runner
-- 			-- Can also be a function to return dynamic values
-- 			args = { "--log-level", "DEBUG" },
-- 			-- Runner to use. Will use pytest if available by default.
-- 			-- Can be a function to return dynamic value.
-- 			runner = "pytest",
-- 			-- Custom python path for the runner.
-- 			-- Can be a string or a list of strings.
-- 			-- Can also be a function to return dynamic value.
-- 			-- If not provided, the path will be inferred by checking for
-- 			-- virtual envs in the local directory and for Pipenev/Poetry configs
-- 			python = { ".venv/bin/python", ".pyenv/bin/python", "pyenv/bin/python" },
-- 			-- Returns if a given file path is a test file.
-- 			-- NB: This function is called a lot so don't perform any heavy tasks within it.
-- 			-- is_test_file = function(file_path)
-- 			-- ...
-- 			-- end,
-- 		}),
-- 	},
-- })

-- Run all tests in current file
create_cmd("PyTestFile", function(opts)
    require("neotest").run.run(vim.fn.expand("%"))
end, {})

-- Ruff fix all in current file
create_cmd("RuffFix", function(opts)
    vim.lsp.buf.code_action({
        context = { only = { "source.fixAll.ruff" } },
        apply = true,
    })
end, {})

--- SNIPETS ---
local ls = require("luasnip")

-- This is a snippet creator
local s = ls.s

-- This is insert mode
local i = ls.insert_node

local c = ls.choice_node

local t = ls.text_node

local ts_python = require("tunguyen.utils.ts_python")

function in_class_but_not_in_def()
    return ts_python.in_class() and not ts_python.in_def()
end

local in_class_only = {
    show_condition = in_class_but_not_in_def,
    condition = in_class_but_not_in_def,
}

local in_function = {
    show_condition = ts_python.in_def,
    condition = ts_python.in_def,
}

-- This is format node.
local fmt = require("luasnip.extras.fmt").fmt

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
        fmt('if __name__=="__main__":\n\t{}', {
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

    -- logging
    s(
        { trig = "lod", dscr = "Log debugs" },
        fmt('logger.debug("{}")', {
            ls.i(1, "message"),
        }),
        in_function
    ),

    s(
        { trig = "lodf", dscr = "Log debugs with format string" },
        fmt('logger.debug("{}", {})', {
            ls.i(1, "message"),
            ls.i(2, "vars"),
        }),
        in_function
    ),

    s(
        { trig = "lode", dscr = "Log debugs with extra param" },
        fmt('logger.debug("{}", extra{{{}}})', {
            ls.i(1, "message"),
            ls.i(2, "keyvalue"),
        }),
        in_function
    ),

    s(
        { trig = "loinf", dscr = "Log infos" },
        fmt('logger.info("{}")', {
            ls.i(1, "message"),
        }),
        in_function
    ),
}

ls.add_snippets("python", snippets)
