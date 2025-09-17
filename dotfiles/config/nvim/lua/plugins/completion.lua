vim.pack.add({
    { src = 'https://github.com/Saghen/blink.cmp',             version = vim.version.range('1.*'), },
    { src = 'https://github.com/L3MON4D3/LuaSnip',             version = vim.version.range('2.*'), },
    { src = 'https://github.com/rafamadriz/friendly-snippets', },
})

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

require('luasnip.loaders.from_vscode').lazy_load()

require('blink.cmp').setup({
    snippets = { preset = 'luasnip' },
    keymap = { preset = 'default' },
    completion = {
        menu = {
            draw = {
                columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
            },
        },
    },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal'
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    signature = { enabled = true },
})
