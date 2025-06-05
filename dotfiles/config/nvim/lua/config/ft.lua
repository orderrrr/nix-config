-- Create an autogroup for build configurations
local build_group = vim.api.nvim_create_augroup('BuildConfigs', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'zig',
    group = build_group,
    callback = function()
        vim.opt_local.makeprg = 'zig build'
        vim.opt_local.errorformat = '%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m,%-G%.%#'
    end
})

vim.keymap.set('n', '<leader>m', ':make<CR>', {
    desc = "Run make command for current filetype"
})
vim.keymap.set('n', '<leader>do', ':copen<CR>', {
    desc = "Open quickfix list"
})
