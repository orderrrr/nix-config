vim.pack.add({
    { src = "https://github.com/NickvanDyke/opencode.nvim.git" },
})

require("opencode").setup({});

vim.keymap.set('n', '<leader>ot', function() require('opencode').toggle() end)
vim.keymap.set('n', '<leader>oa', function() require('opencode').ask('@cursor: ') end)
vim.keymap.set('v', '<leader>oa', function() require('opencode').ask('@selection: ') end)
vim.keymap.set({ 'n', 'v' }, '<leader>op', function() require('opencode').select_prompt() end)
vim.keymap.set('n', '<leader>on', function() require('opencode').command('session_new') end)
vim.keymap.set('n', '<leader>oy', function() require('opencode').command('messages_copy') end)
vim.keymap.set('n', '<S-C-u>', function() require('opencode').command('messages_half_page_up') end)
vim.keymap.set('n', '<S-C-d>', function() require('opencode').command('messages_half_page_down') end)
