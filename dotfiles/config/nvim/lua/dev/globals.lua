-- IDE-specific global settings (shared settings are in base/init.lua)

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- UI settings
vim.o.wrap = false
vim.o.scrolloff = 5
vim.o.cmdheight = 0
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- JSON filetype detection
vim.cmd [[autocmd BufNewFile,BufRead *.json set filetype=json]]

-- require("colors.compline")
