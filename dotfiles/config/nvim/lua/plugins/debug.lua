return {
    { 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
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
