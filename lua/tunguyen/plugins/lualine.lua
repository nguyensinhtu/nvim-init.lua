local ok, lualine = pcall(require, "lualine")

if not ok then
    return
end

lualine.setup({
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = {},
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
})
