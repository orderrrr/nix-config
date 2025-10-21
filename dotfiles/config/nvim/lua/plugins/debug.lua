local pf = require('util').pf

vim.pack.add({
    pf('nvim-neotest/nvim-nio'),
    pf('mfussenegger/nvim-dap'),
    pf('rcarriga/nvim-dap-ui'),
})

require("dapui").setup()

vim.keymap.set('n', '<leader>do', require('dapui').toggle)
vim.keymap.set('n', '<leader>dt', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<leader>dn', require('dap').continue)
