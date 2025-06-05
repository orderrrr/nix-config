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
            require('smart-splits').setup {}

            vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = 'SmartSplit Left' })
            vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = 'SmartSplit Down' })
            vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = 'SmartSplit Up' })
            vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = 'SmartSplit Right' })
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = function()
            require('toggleterm').setup {
                -- highlights = {
                --     Normal = { guibg = "#d0d0d0" },
                --     NormalFloat = { guibg = "#d0d0d0" },
                --     FloatBorder = { guibg = "#d0d0d0", guifg = "#454545" },
                -- },
                shade_terminals = false,
                float_opts = {
                    -- Explicitly set float background
                    winblend = 0, -- No transparency
                },
            }

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
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                compile = false,  -- enable compiling the colorscheme
                undercurl = true, -- enable undercurls
                commentStyle = { italic = true },
                functionStyle = {},
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                typeStyle = {},
                transparent = true,    -- do not set background color
                dimInactive = true,    -- dim inactive window `:h hl-NormalNC`
                terminalColors = true, -- define vim.g.terminal_color_{0,17}
                colors = {             -- add/modify theme and palette colors
                    palette = {},
                    theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
                },
                overrides = function(colors) -- add/modify highlights
                    return {}
                end,
                theme = "dragon",    -- Load "dragon" theme
                background = {       -- map the value of 'background' option to a theme
                    dark = "dragon", -- try "dragon" !
                    light = "dragon"
                },
            })
            vim.cmd("colorscheme kanagawa-dragon")
        end
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
        opts = {
            file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },

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
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require 'colorizer'.setup { '*', css = { rgb_fn = true, }, html = { names = false, } }
        end
    }
}
