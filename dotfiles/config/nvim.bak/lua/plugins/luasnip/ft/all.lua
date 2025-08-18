local ls = require "luasnip"

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local d = ls.dynamic_node

local function uuid()
    local handle = io.popen "uuidgen | tr -d '\n'"
    if handle == nil then return "notconfigured" end
    local result = handle:read "*a"
    return sn(nil, i(nil, result:lower()))
end

ls.add_snippets("all", {
    s("uuid", {
        d(1, uuid, {}, {}),
    }),
})
