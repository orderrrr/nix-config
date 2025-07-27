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

-- Simple Quickfix Toggle Function
local function toggle_quickfix()
    -- Get all window info
    local windows = vim.fn.getwininfo()
    local qf_open = false

    -- Loop through windows to see if the quickfix is open
    for _, win in ipairs(windows) do
        if win.quickfix == 1 then
            qf_open = true
            break
        end
    end

    -- Toggle based on whether it's open or not
    if qf_open then
        vim.cmd('cclose')
    else
        -- Optional: Check if the quickfix list has items before opening
        if not vim.tbl_isempty(vim.fn.getqflist()) then
            vim.cmd('copen')
        else
            vim.notify("Quickfix list is empty", vim.log.levels.INFO)
        end
    end
end

-- Set the keymap in Normal mode
-- Using <leader>q is a common choice
vim.keymap.set('n', '<leader>mo', toggle_quickfix, { desc = 'Toggle Quickfix List' })
