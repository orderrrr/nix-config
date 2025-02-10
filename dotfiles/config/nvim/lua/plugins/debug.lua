return {
    {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
        config = function()
            vim.keymap.set('n', '<leader>do', function()
                require('dapui').setup(); require('dapui').open()
            end, { desc = 'Open dapui' })

            vim.keymap.set('n', '<leader>dt', function()
                require('dap').toggle_breakpoint()
            end, { desc = 'Toggle breakpoint' })
        end
    },
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
}
