local pf = require('util').pf

vim.pack.add({
    -- require('util').pf('kepano/flexoki-neovim'),
    pf("thesimonho/kanagawa-paper.nvim"),
    pf('unblevable/quick-scope'),
    pf('RRethy/vim-illuminate'),
    pf('uga-rosa/ccc.nvim'),
    pf('folke/snacks.nvim'),
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

require("kanagawa-paper").setup({ transparent = true })
vim.cmd.colorscheme("kanagawa-paper")
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
