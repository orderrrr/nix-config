vim.pack.add({
    require('util').pf('vague2k/vague.nvim'),
    require('util').pf('unblevable/quick-scope'),
    require('util').pf('RRethy/vim-illuminate'),
    require('util').pf('norcalli/nvim-colorizer.lua'),
    require('util').pf('kdheepak/lazygit.nvim'),
    require('util').pf('folke/snacks.nvim'),
})

require("snacks").setup({
    bigfile = { enabled = false },
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
