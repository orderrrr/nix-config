return {
    'echasnovski/mini.nvim',
    version = false,
    lazy = false,
    config = function()
        require('mini.ai').setup()
        require('mini.statusline').setup()
    end,
}
