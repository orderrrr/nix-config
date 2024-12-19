return {
    -- require('plugins.lsp'),
    -- require('plugins.completion'),
    -- require('plugins.git'),
    -- require('plugins.luasnip'),

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },

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
    },

    -- "gc" to comment visual regions/lines
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

    {
        'nvimdev/guard.nvim',

        config = function()
            local _ = require 'guard.filetype'

            -- TODO
            -- https://github.com/nvimdev/guard.nvim#supported-tools

            vim.g.guard_config = {
                -- the only options for the setup function
                -- Use lsp if no formatter was defined for this filetype
                lsp_as_default_formatter = false,
            }
        end,
    },
    { 'unblevable/quick-scope' },
    {
        'stevearc/dressing.nvim',
        config = function()
            require('dressing').setup {
                input = { default_prompt = '➤ ' },
                select = {
                    backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },
                },
            }
        end,
    },
    {
        'mrjones2014/smart-splits.nvim',
        config = function()
            vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = 'SmartSplit Left' })
            vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = 'SmartSplit Down' })
            vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = 'SmartSplit Up' })
            vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = 'SmartSplit Right' })
            vim.keymap.set('n', '<leader>ss', require('smart-splits').start_resize_mode,
                { desc = 'SmartSplit Resize Mode' })

            require('smart-splits').setup {}
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = function()
            require('toggleterm').setup {}

            vim.cmd [[autocmd TermEnter term://*toggleterm#*\ tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>]]
            vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>', { desc = 'Open Term' })
        end,
    },
    {
        'RRethy/vim-illuminate',
        config = function()
            -- default configuration
            require('illuminate').configure {
                -- providers: provider used to get references in the buffer, ordered by priority
                providers = {
                    'lsp',
                    'treesitter',
                    'regex',
                },
                -- delay: delay in milliseconds
                delay = 100,
                -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
                filetypes_denylist = {
                    'dirvish',
                    'fugitive',
                },
                under_cursor = true,
            }
        end,
    },
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
        'echasnovski/mini.nvim',
        version = false,
        lazy = false,
        config = function()
            -- vim.keymap.set('n', '<leader>nt', ':lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>',
            --     { desc = 'Open min.nvim' })
            require('mini.ai').setup()
            -- require('mini.files').setup()
            require('mini.statusline').setup()
        end,
    },
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        -- opts = {},
        -- Optional dependencies
        config = function()
            vim.keymap.set('n', '<leader>nt', ':Oil<CR>', { desc = 'Open oil.nvim' })

            require('oil').setup({
                default_file_explorer = true,

                columns = {
                    "icon",
                    -- "permissions",
                    -- "size",
                    -- "mtime",
                },
                lsp_file_methods = {
                    -- Enable or disable LSP file operations
                    enabled = true,
                    -- Time to wait for LSP file operations to complete before skipping
                    timeout_ms = 1000,
                    -- Set to true to autosave buffers that are updated with LSP willRenameFiles
                    -- Set to "unmodified" to only save unmodified buffers
                    autosave_changes = false,
                },
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },

            })
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
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
                },
            }
        end,
    },
    {
        "vague2k/vague.nvim",
        config = function()
            require("vague").setup({
                -- optional configuration here
                transparent = true,
                style = {
                    -- "none" is the same thing as default. But "italic" and "bold" are also valid options
                    boolean = "none",
                    number = "none",
                    float = "none",
                    error = "none",
                    comments = "none",
                    conditionals = "none",
                    functions = "none",
                    headings = "bold",
                    operators = "none",
                    strings = "none",
                    variables = "none",

                    -- keywords
                    keywords = "none",
                    keyword_return = "none",
                    keywords_loop = "none",
                    keywords_label = "none",
                    keywords_exception = "none",

                    -- builtin
                    builtin_constants = "none",
                    builtin_functions = "none",
                    builtin_types = "none",
                    builtin_variables = "none",
                },
                colors = {
                    func = "#bc96b0",
                    keyword = "#787bab",
                    -- string = "#d4bd98",
                    string = "#8a739a",
                    -- string = "#f2e6ff",
                    -- number = "#f2e6ff",
                    -- string = "#d8d5b1",
                    number = "#8f729e",
                    -- type = "#dcaed7",
                },
            })

            vim.cmd.colorscheme("vague")
        end
    },
    -- {
    --     "supermaven-inc/supermaven-nvim",
    --     config = function()
    --         require("supermaven-nvim").setup({
    --             disable_inline_completion = true, -- disables inline completion for use with cmp
    --             disable_keymaps = true,           -- disables built in keymaps for more manual control
    --             -- keymaps = {
    --             --     accept_suggestion = "<C-Right>",
    --             --     clear_suggestion = "<C-]>",
    --             --     accept_word = "<C-j>",
    --             -- },
    --         })
    --     end,
    -- },
    {
        'akinsho/flutter-tools.nvim',
        lazy = true,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
    },
    { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
    'mfussenegger/nvim-jdtls',
    {
        'nvim-neotest/neotest',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'antoinemadec/FixCursorHold.nvim',
        },
        config = function()
            require('neotest').setup {
                adapters = {
                    require 'neotest-java' {
                        dap = { justMyCode = false },
                    },
                    -- require 'neotest-plenary',
                    -- require 'neotest-vim-test' {
                    --   ignore_file_types = { 'python', 'vim', 'lua' },
                    -- },
                },
            }
        end,
    },
    {
        'rcasia/neotest-java',
        config = function()
            require('neotest').setup {
                adapters = {
                    require 'neotest-java' {
                        ignore_wrapper = false, -- whether to ignore maven/gradle wrapper
                    },
                },
            }
        end,
    },
    {
        'ziglang/zig.vim'
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "vault",
                    path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault",
                },
            },
            ui = { enable = false }
        },
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    -- {
    --     'toppair/peek.nvim',
    --     event = { 'VeryLazy' },
    --     build = 'deno task --quiet build:fast',
    --     config = function()
    --         require('peek').setup()
    --         -- refer to `configuration to change defaults`
    --         vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
    --         vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    --     end,
    -- },
    -- {
    --     'tpope/vim-dadbod',
    --     dependencies = {
    --         'kristijanhusak/vim-dadbod-ui',
    --         'kristijanhusak/vim-dadbod-completion',
    --     },
    --     config = function()
    --         vim.g.db_ui_save_location = '~/.config/nvim/db_ui'
    --         vim.keymap.set('n', '<leader>ud', ':DBUI<CR>', { desc = 'Dadbod UI open' })
    --     end,
    --     event = 'UIEnter',
    -- },
    -- {
    --     'subnut/nvim-ghost.nvim',
    -- },
}
