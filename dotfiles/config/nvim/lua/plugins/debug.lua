vim.pack.add({
    require('util').pf('nvim-neotest/nvim-nio'),
    require('util').pf('mfussenegger/nvim-dap'),
    require('util').pf('rcarriga/nvim-dap-ui'),
})

require("dapui").setup()

vim.keymap.set('n', '<leader>do', require('dapui').toggle)
vim.keymap.set('n', '<leader>dt', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<leader>dn', require('dap').continue)
