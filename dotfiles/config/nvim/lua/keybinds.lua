local util = require("util")

vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y');
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_');
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy');

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p');
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P');

vim.keymap.set('n', '<leader>so', ':update<CR> :so<CR>');
vim.keymap.set('n', '<leader>w', ':write<CR>');
vim.keymap.set('n', '<leader>q', ':quit<CR>');

vim.keymap.set('n', 'S', ":%s//g<Left><Left>")
vim.keymap.set('v', 'S', ":s//g<Left><Left>")
vim.keymap.set('n', '<A-S>', ":%g//d<Left><Left>")
vim.keymap.set('v', '<A-S>', ":g//d<Left><Left>")

vim.keymap.set('n', '<A-D>', ":%v//d<Left><Left>")
vim.keymap.set('v', '<A-D>', ":v//d<Left><Left>")

vim.keymap.set('n', '<leader>nb', ':enew<CR>')

vim.keymap.set('n', '<C-Tab>', '>>', { noremap = true, silent = true, desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', '<<', { noremap = true, silent = true, desc = 'Unindent line' })
vim.keymap.set('v', '<C-Tab>', '>gv', { noremap = true, silent = true, desc = 'Indent selection (keep selection)' })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true, desc = 'Unindent selection (keep selection)' })

vim.keymap.set('v', '<leader>Cy', util.copy_with_numbers, { silent = true, desc = "Copy selection with numbers" })
