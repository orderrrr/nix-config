local ls = require "luasnip"

ls.setup()

ls.config.set_config {}
ls.auto_snippets = true

require("plugins.luasnip.ft.all")
require("plugins.luasnip.ft.java")
require("plugins.luasnip.ft.sql")
require("plugins.luasnip.ft.typescript")
