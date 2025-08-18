vim.pack.add({
    require("util").pf("vague2k/vague.nvim"),
    require("util").pf("unblevable/quick-scope"),
    require("util").pf("akinsho/toggleterm.nvim"),
    require("util").pf("RRethy/vim-illuminate"),
    require("util").pf("norcalli/nvim-colorizer.lua"),
})

vim.cmd("colorscheme vague")
vim.cmd("hi statusline guibg=NONE")

require('toggleterm').setup {
    shade_terminals = false,
    float_opts = { winblend = 0 },
}

local tt = function() vim.cmd(":ToggleTerm<CR>") end
vim.keymap.set({ 'n', 't' }, '<leader>tt', tt)
vim.keymap.set({ 't' }, '<C-\\>', '<C-\\><C-n>')

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
