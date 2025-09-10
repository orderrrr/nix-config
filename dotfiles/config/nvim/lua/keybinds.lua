vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y');
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_');
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy');

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p');
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P');

vim.keymap.set('n', '<leader>o', ':update<CR> :so<CR>');
vim.keymap.set('n', '<leader>w', ':write<CR>');
vim.keymap.set('n', '<leader>q', ':quit<CR>');

vim.keymap.set('n', 'S', ":%s//g<Left><Left>")
vim.keymap.set('v', 'S', ":s//g<Left><Left>")
vim.keymap.set('n', '<A-S>', ":%g//d<Left><Left>")
vim.keymap.set('v', '<A-S>', ":g//d<Left><Left>")

vim.keymap.set('n', '<leader>nb', ':enew<CR>')
