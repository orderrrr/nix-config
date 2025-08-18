return {
    {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup {
                formatters_by_ft = {
                    lua = { 'stylua' },
                    -- Conform will run multiple formatters sequentially
                    python = { 'isort', 'black' },
                    -- Use a sub-list to run only the first available formatter
                    javascript = { { 'prettierd', 'prettier' } },
                    toml = { 'taplo' },
                    slang = { 'slangd' },
                },
            }
        end,
    },
    {
        'numToStr/Comment.nvim',
        opts = {},
        config = function()
            vim.keymap.set('n', '<leader>/', function()
                require('Comment.api').toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)
            end, { desc = 'Toggle comment line' })

            vim.keymap.set(
                'v',
                '<leader>/',
                "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
                { desc = 'Toggle comment for selection' }
            )
        end,
    },
    -- {
    --     'nvimdev/guard.nvim',
    --
    --     config = function()
    --         local _ = require 'guard.filetype'
    --
    --         -- TODO
    --         -- https://github.com/nvimdev/guard.nvim#supported-tools
    --
    --         vim.g.guard_config = {
    --             -- the only options for the setup function
    --             -- Use lsp if no formatter was defined for this filetype
    --             lsp_as_default_formatter = false,
    --         }
    --     end,
    -- },
    {
        'folke/todo-comments.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        main = 'ibl',
        opts = {},
        config = function()
            require('ibl').setup()
        end,
    }
}
