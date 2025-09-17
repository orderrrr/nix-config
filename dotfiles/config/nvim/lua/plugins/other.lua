vim.pack.add({
    require('util').pf('kepano/flexoki-neovim'),
    require('util').pf('unblevable/quick-scope'),
    require('util').pf('RRethy/vim-illuminate'),
    require('util').pf('uga-rosa/ccc.nvim'),
    require('util').pf('folke/snacks.nvim'),
})

require('snacks').setup({
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
});

vim.keymap.set({ 'n', 't' }, '<leader>tt', function() require('snacks').terminal() end)
vim.keymap.set({ 't' }, '<C-\\>', '<C-\\><C-n>')

vim.cmd('colorscheme flexoki-dark')
vim.cmd('hi statusline guibg=NONE')

require('illuminate').configure {
    providers = {
        'lsp',
        'treesitter',
        'regex',
    },
    delay = 50,
    filetypes_denylist = {
        'dirvish',
        'fugitive',
    },
    under_cursor = true,
}

require('ccc').setup({})
