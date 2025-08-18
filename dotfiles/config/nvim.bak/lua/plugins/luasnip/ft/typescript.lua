local ls = require "luasnip"

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local d = ls.dynamic_node

local function exports()
    local path = vim.fn.expand("%:p"):gsub("/[^/]*$", "")
    local out = io.popen("ls " .. path):read "*a"
    local result = {}
    for filename in out:gmatch "[^\n]+" do
        if filename == "index.ts" then
            local final_name = ""
            if vim.fn.isdirectory(path .. "/" .. filename) == 1 then
                final_name = filename .. "/index"
            else
                final_name = filename:gsub("%.ts", "")
            end
            result[#result + 1] = "export * from './" .. final_name .. "';"
        end
    end
    return sn(nil, i(nil, result))
end

ls.add_snippets("typescript", {
    s("exp", {
        d(1, exports, {}, {}),
    }),
})
