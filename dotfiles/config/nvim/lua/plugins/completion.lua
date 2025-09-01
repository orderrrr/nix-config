vim.pack.add({
    { src = "https://github.com/Saghen/blink.cmp",             version = vim.version.range('1.*'), },
    { src = "https://github.com/L3MON4D3/LuaSnip",             version = vim.version.range('2.*'), },
    { src = "https://github.com/rafamadriz/friendly-snippets", },
})

require("luasnip.loaders.from_vscode").lazy_load()

require('blink.cmp').setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    keymap = { preset = 'default' },
    completion = {
        menu = {
            draw = {
                columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
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
