-- Base configuration shared by both IDE and Multiplexer modes
local M = {}

function M.setup()
  -- Leader keys (shared by both modes)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Enable true color support
  vim.o.termguicolors = true

  -- Minimal shared options that both modes want
  vim.o.swapfile = false
  vim.o.undofile = true
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300

  -- Case-insensitive searching UNLESS \C or capital in search
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Set completeopt to have a better completion experience
  vim.o.completeopt = 'menu,menuone,noselect'

  -- Enable break indent
  vim.o.breakindent = true

  -- Always show signcolumn (prevents text shifting)
  vim.o.signcolumn = 'yes'

  -- Global statusline
  vim.o.laststatus = 3

  -- Rounded window borders
  vim.o.winborder = 'rounded'

  -- Tab settings (both use 2 spaces)
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2
  vim.opt.expandtab = true

  require("base.keybinds")
end

return M
