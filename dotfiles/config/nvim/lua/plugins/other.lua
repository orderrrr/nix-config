vim.pack.add({
    require('util').pf('vague2k/vague.nvim'),
    require('util').pf('unblevable/quick-scope'),
    require('util').pf('RRethy/vim-illuminate'),
    require('util').pf('norcalli/nvim-colorizer.lua'),
    require('util').pf('kdheepak/lazygit.nvim'),
    require('util').pf('folke/snacks.nvim'),
})

require("snacks").setup({
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = false },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
});


vim.keymap.set({ 'n', 't' }, "<leader>tt", function() require("snacks").terminal() end)
vim.keymap.set({ 't' }, '<C-\\>', '<C-\\><C-n>')

vim.cmd('colorscheme vague')
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

require('colorizer').setup({ '*', css = { rgb_fn = true, }, html = { names = false, } })

vim.keymap.set('n', '<leader>lg', ':LazyGit<CR>')
