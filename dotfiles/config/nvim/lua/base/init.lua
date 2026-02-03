-- Base configuration shared by both IDE and Multiplexer modes
local M = {}

-- Shared plugins used by both modes
M.shared_plugins = {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/f-person/auto-dark-mode.nvim',
}

function M.setup()
  -- Leader keys (shared by both modes)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Enable true color support
  vim.o.termguicolors = true

  -- Ghostty OSC passthrough configuration
  -- This allows Ghostty shell integration features (password lock icon,
  -- command progress bars) to work when running inside Neovim's :terminal
  if vim.env.GHOSTTY_RESOURCES_DIR or vim.env.TERM == 'xterm-ghostty' then
    -- Enable OSC 52 clipboard integration (optional but recommended)
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = function() return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') } end,
        ['*'] = function() return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') } end,
      },
    }
  end

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
  require("base.theme").setup()
end

return M
