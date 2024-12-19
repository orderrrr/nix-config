local ls = require "luasnip"

-- some shorthands...
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

ls.add_snippets("sql", {
    -- sql
    s("tables", {
        t "select * from information_schema.tables where table_schema = 'public'",
    }),
    s("slt", {
        t "select * from ",
        i(0),
    }),
})
