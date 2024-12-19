require 'globals'

-- LAZY
vim.g.lazyvim_json = "~/.local/share/nvim/lazy-lock.json"
require 'setup_lazy'
require('lazy').setup(
  {
    spec = { import = 'plug' },
    lockfile = os.getenv("HOME") .. "/.local/share/nvim/lazy-lock.json",
    install = {
      colorscheme = { "kanagawa" }
    }
  }
)


local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require('plugins.telescope')
require('plugins.treesitter')
require('plugins.lsp')
-- require('plugins.cmp')
require('keymaps')
require('au')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
