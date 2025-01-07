local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end

    return false
end

return {
    'saghen/blink.cmp',

    dependencies = {
        {
            "MattiasMTS/cmp-dbee",
            dependencies = {
                { "kndndrj/nvim-dbee", "MunifTanjim/nui.nvim", }
            },
            ft = "sql", -- optional but good to have
            opts = {},  -- needed
            build = function()
                require("dbee").install()
            end,
            config = function()
                require("dbee").setup( --[[optional config]])
            end
        },
        {
            'saghen/blink.compat',
            -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
            version = '*',
            -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
            lazy = true,
            -- make sure to set opts so that lazy.nvim calls blink.compat's setup
            opts = {
                impersonate_nvim_cmp = true,
            },
        },
    },

    -- use a release tag to download pre-built binaries
    version = '*',
    opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- see the "default configuration" section below for full documentation on how to define
        -- your own keymap.
        keymap = { preset = 'default' },
        snippets = {
            expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
            active = function(filter)
                if filter and filter.direction then
                    return require('luasnip').jumpable(filter.direction)
                end
                return require('luasnip').in_snippet()
            end,
            jump = function(direction) require('luasnip').jump(direction) end,
        },

        completion = {
            menu = {
                draw = {
                    columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
                },
            },
        },


        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
            default = function()
                local ftype = { "sql", "mysql", "plsql" }

                if has_value(ftype, vim.bo.filetype) then
                    return { 'lsp', 'dbee', 'path', 'luasnip', 'buffer' }
                end

                return { 'lsp', 'dbee', 'path', 'luasnip', 'buffer' }
            end,
            -- create provider
            providers = {
                dbee = {
                    name = 'cmp-dbee', -- IMPORTANT: use the same name as you would for nvim-cmp
                    module = 'blink.compat.source',

                    -- all blink.cmp source config options work as normal:
                    score_offset = -3,

                    -- this table is passed directly to the proxied completion source
                    -- as the `option` field in nvim-cmp's source config
                    --
                    -- this is NOT the same as the opts in a plugin's lazy.nvim spec
                    opts = {
                        -- this is an option from cmp-digraphs
                        cache_digraphs_on_start = true,
                    },
                }
            },
            -- optionally disable cmdline completions
            -- cmdline = {},
        },

        -- experimental signature help support
        signature = { enabled = true },

    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.default" }
}
