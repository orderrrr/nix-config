vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y', { desc = 'Copy to clipboard' });
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_', { desc = 'Copy to clipboard (end of line)' });
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy', { desc = 'Copy line to clipboard' });

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' });
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P', { desc = 'Paste before from clipboard' });
