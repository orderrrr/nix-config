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
        {
            "Exafunction/windsurf.nvim",
            config = function()
                require("codeium").setup({
                })
            end
        },
        -- {
        --     'tzachar/cmp-ai',
        --     config = function()
        --         local cmp_ai = require('cmp_ai.config')
        --         cmp_ai:setup({
        --             max_lines = 100,
        --             provider = 'Ollama',
        --             provider_options = {
        --                 model = 'codeqwen:7b',
        --                 auto_unload = true,
        --             },
        --             prompt = function(lines_before, lines_after)
        --                 return lines_before
        --             end,
        --             suffix = function(lines_after)
        --                 return lines_after
        --             end,
        --             notify = true,
        --             notify_callback = function(msg)
        --                 vim.notify(msg)
        --             end,
        --             run_on_every_keystroke = true,
        --             ignored_file_types = {
        --             },
        --         })
        --     end
        -- },
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
            preset = "luasnip"
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
            default = { 'lsp', 'codeium', 'path', 'snippets', 'buffer' },
            per_filetype = {
                prompt = { 'lsp', 'path', 'snippets', 'buffer' },
                oil = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            providers = {
                codeium = { name = 'Codeium', module = 'codeium.blink', async = true },
            },
        },

        -- experimental signature help support
        signature = { enabled = true },

    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.default" }
}
