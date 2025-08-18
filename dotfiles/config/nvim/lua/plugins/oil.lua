vim.pack.add({
    require("util").pf("stevearc/oil.nvim"),
})

require("oil").setup()

vim.keymap.set('n', '<leader>nt', ':Oil<CR>');
