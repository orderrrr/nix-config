vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end
vim.g.colors_name = 'compline-light'

require('themes.compline').setup({ transparent_background = true, light_mode = true })
