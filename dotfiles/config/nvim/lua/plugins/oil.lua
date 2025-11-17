local pf = require('util').pf

require("oil").setup()

vim.keymap.set('n', '<leader>e', ':Oil<CR>');

vim.api.nvim_create_autocmd('VimEnter', {
    desc = "Open Oil if launched on a directory",
    group = vim.api.nvim_create_augroup('OilOnDir', { clear = true }),
    callback = function()
        local arg1 = vim.fn.argv(0)
        if (vim.fn.argc() == 0 and vim.fn.bufname('%') == '') or
            (vim.fn.argc() == 1 and arg1 ~= nil and vim.fn.isdirectory(arg1) == 1)
        then
            vim.schedule(function()
                require('oil').open()
                local bufnr = vim.api.nvim_get_current_buf()
                local buf_name = vim.fn.bufname(bufnr)
                if buf_name == "" and not vim.bo[bufnr].modified then
                    vim.api.nvim_buf_delete(bufnr, { force = true })
                end
            end)
        end
    end,
})
