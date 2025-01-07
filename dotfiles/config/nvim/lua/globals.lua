vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.foldmethod = 'manual'
vim.o.foldcolumn = '0'

vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.scrolloff = 5

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

if vim.g.neovide then
    vim.o.guifont = 'Dank Mono:h14' -- text below applies for VimScript
    vim.g.neovide_padding_top = 5
    vim.g.neovide_padding_bottom = 5
    vim.g.neovide_padding_right = 5
    vim.g.neovide_padding_left = 5
end

vim.cmd ':set nowrap'

-- vim: ts=2 sts=2 sw=2 et

vim.g.neovide_input_use_logo = 1
vim.cmd [[map <D-v> "+p<CR>
map! <D-v> <C-R>+
tmap <D-v> <C-R>+
vmap <D-c> "+y<CR>]]

vim.keymap.set({ "n", "v" }, "<leader>y", vim.cmd('"*y'), { desc = "Copy text to clipboard" })

-- vim.cmd [[
-- augroup remember_folds
--   autocmd!
--   au BufWinLeave ?* mkview! .fold
--   au BufWinEnter ?* silent! loadview .fold
-- augroup END
-- ]]
