local ls = require("luasnip")
local snips = require("go.snips")

local in_fn = {
  show_condition = snips.in_function,
  condition = snips.in_function,
}

-- tutorial: https://www.youtube.com/watch?v=Dn800rlPIho

-- This is a snippet creator
s = ls.s

-- This is insert mode
i = ls.insert_mode

-- This is format node.
local fmt = require('luasnip.extras.fmt').fmt


local clipboard = function()
	return f(function(_args, snip)
        return snip.snippet.env.CLIPBOARD
	end)
end

local snippets = {
    -- logrus
    s(
        { trig = "lod", dscr = "Log debugs" },
        fmt(
            "logrus.Debug(\"[{}]: {}\")" 
            , {
                ls.i(1, "function_name"), 
                ls.i(2, "message"), 
            }
        ),
        in_function
    ),
    s(
        { trig = "lodf", dscr = "Log debugs" },
        fmt(
            "logrus.Debugf(\"[{}]: {}\", {})" 
            , {
                ls.i(1, "function_name"), 
                ls.i(2, "message"), 
                ls.i(3, "vars"),
            }
        ),
        in_function
    ),
    s(
        { trig = "loff", dscr = "Log fatal" },
        fmt(
            "logrus.Fatalf(\"[{}]: {}\", {})" 
            , {
                ls.i(1, "function_name"), 
                ls.i(2, "message"), 
                ls.i(3, "vars"),
            }
        ),
        in_function
    ),
    s(
        { trig = "loif", dscr = "Log info" },
        fmt(
            "logrus.Infof(\"[{}]: {}\", {})" 
            , {
                ls.i(1, "function_name"), 
                ls.i(2, "message"), 
                ls.i(3, "vars"),
            }
        ),
        in_function
    ),

    s(
        { trig = "fsf", dscr = "String format" },
        fmt(
            "fmt.Sprintf(\"{}\", {})" 
            , {
                ls.i(1, "text"), 
                ls.i(2, "vars"),
            }
        ),
        in_function
    ),
    -- If error
    s(
        { trig = "ife", name = "Simple if error", dscr = "If error, return err with dynamic node" },
        fmt("if {} != nil {{\n\treturn {}, err\n}}\n", {
          ls.i(1, "err"),
          ls.i(1, "return_v"),
        }),
        in_fn
    ),
    s(
        { trig = "ifep", name = "Simple if error panic", dscr = "If error, panic" },
        fmt("if {} != nil {{\n\tpanic(err)\n}}\n", {
          ls.i(1, "err"),
        }),
        in_fn
    ),
}

ls.add_snippets("go", snippets)
