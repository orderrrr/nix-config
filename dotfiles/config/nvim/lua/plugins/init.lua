return {
    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },
    {
        'nvim-pack/nvim-spectre',
        opts = {},
        config = function()
            vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
                desc = "Toggle Spectre"
            })
            vim.keymap.set('n', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
                desc = "Search current word"
            })
            vim.keymap.set('v', '<leader>Sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
                desc = "Search current word"
            })
            vim.keymap.set('n', '<leader>Sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
                desc = "Search on current file"
            })
        end
    },
    {
        "sindrets/diffview.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            use_icons = true,       -- Requires nvim-web-devicons
            show_help_hints = true, -- Show hints for how to open the help panel
            watch_index = true,     -- Update views and index buffers when the git index changes.
            icons = {               -- Only applies when use_icons is true.
                folder_closed = "",
                folder_open = "",
            },
            signs = {
                fold_closed = "",
                fold_open = "",
                done = "✓",
            },
        }
    },
    {
        "rbong/vim-flog",
        lazy = true,
        cmd = { "Flog", "Flogsplit", "Floggit" },
        dependencies = {
            "tpope/vim-fugitive",
        },
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
            local tt = function() vim.cmd(":ToggleTerm<CR>") end

            vim.keymap.set({ 'n', 't' }, '<leader>tt', tt, { desc = 'Open [T]erm' })
            vim.keymap.set({ 't' }, '<C-\\>', '<C-\\><C-n>', { desc = 'Exit terminal Mode' })
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
        "RRethy/base16-nvim",
        config = function()
            local light = function()
                require('base16-colorscheme').setup({
                    base00 = '#efeeee', -- Light background (was dark)
                    base01 = '#eaeae8', -- Subtle highlight
                    base02 = '#d8d8d6', -- Muted selection background
                    base03 = '#b0b0b0', -- Desaturated comments
                    base04 = '#808080', -- Medium gray foreground
                    base05 = '#505050', -- Desaturated main text
                    base06 = '#404040', -- Darker foreground
                    base07 = '#303030', -- Darkest foreground
                    base08 = '#a07078', -- Desaturated rose (was red)
                    base09 = '#9d8f7c', -- Muted tan (was orange)
                    base0A = '#a49b80', -- Soft taupe (was yellow)
                    base0B = '#7d9178', -- Sage green (was vibrant green)
                    base0C = '#7c9ca6', -- Muted steel blue (was aqua)
                    base0D = '#6f8e9a', -- Desaturated slate blue (was blue)
                    base0E = '#9c8fa4', -- Soft mauve (was purple)
                    base0F = '#8f8276', -- Muted taupe (was brown))
                })
            end

            local dark = function()
                require('base16-colorscheme').setup({
                    base00 = '#1e1e24', -- Desaturated dark background
                    base01 = '#2a2a32', -- Subtle dark highlight
                    base02 = '#3a3a45', -- Muted selection background
                    base03 = '#656570', -- Desaturated comments
                    base04 = '#7f8088', -- Medium gray foreground
                    base05 = '#9a9aa5', -- Desaturated main text
                    base06 = '#b0b0b8', -- Lighter foreground
                    base07 = '#c6c6cc', -- Lightest foreground
                    base08 = '#9e7c80', -- Desaturated rose (was vibrant red)
                    base09 = '#9c8b7e', -- Muted tan (was orange)
                    base0A = '#a09784', -- Soft taupe (was yellow)
                    base0B = '#7e9082', -- Sage green (was vibrant green)
                    base0C = '#7a969e', -- Muted steel blue (was aqua)
                    base0D = '#758b96', -- Desaturated slate blue (was blue)
                    base0E = '#907e95', -- Soft mauve (was purple)
                    base0F = '#8a7c74', -- Muted taupe (was brown)
                })
            end

            vim.keymap.set({ 'n', 't' }, '<leader>cd', dark, { desc = 'Dark Mode' })
            vim.keymap.set({ 'n', 't' }, '<leader>cl', dark, { desc = 'Light Mode' })

            light()
        end
    },
    -- {
    --     "vague2k/vague.nvim",
    --     config = function()
    --         require("vague").setup({
    --             -- optional configuration here
    --             transparent = true,
    --             style = {
    --                 -- "none" is the same thing as default. But "italic" and "bold" are also valid options
    --                 boolean = "none",
    --                 number = "none",
    --                 float = "none",
    --                 error = "none",
    --                 comments = "none",
    --                 conditionals = "none",
    --                 functions = "none",
    --                 headings = "bold",
    --                 operators = "none",
    --                 strings = "none",
    --                 variables = "none",
    --
    --                 -- keywords
    --                 keywords = "none",
    --                 keyword_return = "none",
    --                 keywords_loop = "none",
    --                 keywords_label = "none",
    --                 keywords_exception = "none",
    --
    --                 -- builtin
    --                 builtin_constants = "none",
    --                 builtin_functions = "none",
    --                 builtin_types = "none",
    --                 builtin_variables = "none",
    --             },
    --             colors = {
    --                 func = "#bc96b0",
    --                 keyword = "#787bab",
    --                 -- string = "#d4bd98",
    --                 string = "#8a739a",
    --                 -- string = "#f2e6ff",
    --                 -- number = "#f2e6ff",
    --                 -- string = "#d8d5b1",
    --                 number = "#8f729e",
    --                 -- type = "#dcaed7",
    --             },
    --         })
    --
    --         vim.cmd.colorscheme("vague")
    --     end
    -- },
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
            ui = { enable = false },
            follow_url_func = function(url)
                -- Open the URL in the default web browser.
                vim.fn.jobstart({ "open", url }) -- Mac OS
                -- vim.fn.jobstart({"xdg-open", url})  -- linux
                -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
                -- vim.ui.open(url) -- need Neovim 0.10.0+
            end,
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
    {
        'subnut/nvim-ghost.nvim',
    },
    {
        "oysandvik94/curl.nvim",
        cmd = { "CurlOpen" },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = true,
    },
}
