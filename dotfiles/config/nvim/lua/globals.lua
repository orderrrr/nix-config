vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.swapfile = false
vim.g.maplocalleader = ' '
vim.g.mapleader = ' '
vim.o.signcolumn = 'yes'
vim.o.laststatus = 3
vim.o.winborder = 'rounded'
vim.opt.expandtab = true -- tabs suck
-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.scrolloff = 5

-- Merge command-line with statusline
vim.o.cmdheight = 0

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.wrap = false

vim.cmd [[autocmd BufNewFile,BufRead *.json set filetype=json]]

-- require("colors.compline")
