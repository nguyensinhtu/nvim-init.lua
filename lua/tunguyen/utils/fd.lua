-- Call fd command to find a file

local M = {

    find = function(current_dir, filename, max_depth)
        max_depth = max_depth or 3
        local cmd = "fd -HItd -tl --absolute-path --max-depth " .. max_depth .. " --color never " .. filename .. " " .. current_dir
        local openPop = assert(io.popen(cmd, "r"))
        local found = openPop:read()
        openPop:close()
        return found
    end,
}

return M
