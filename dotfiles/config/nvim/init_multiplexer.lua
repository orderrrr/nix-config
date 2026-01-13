-- Neovim Multiplexer
-- A minimal terminal multiplexer configuration for Neovim

-- Set leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable termguicolors
vim.o.termguicolors = true

-- Setup multiplexer
require('multiplexer').setup({
  -- You can customize configuration here
  -- See lua/multiplexer/config.lua for all options
})
