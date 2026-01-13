local util = require("util")

vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y');
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_');
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy');

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p');
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P');

vim.keymap.set('n', '<leader>so', ':update<CR> :so<CR>');
vim.keymap.set('n', '<leader>w', ':write<CR>');

vim.keymap.set('n', 'S', ":%s//g<Left><Left>", { desc = "Find and replace in file" })
vim.keymap.set('v', 'S', ":s//g<Left><Left>", { desc = "Find and replace in selection" })
vim.keymap.set('n', '<A-S>', ":%g//d<Left><Left>", { desc = "Find and delete line in file" })
vim.keymap.set('v', '<A-S>', ":g//d<Left><Left>", { desc = "Find and delete line in selection" })
vim.keymap.set('n', '<A-D>', ":%v//d<Left><Left>", { desc = "Find and delete lines not matching" })
vim.keymap.set('v', '<A-D>', ":v//d<Left><Left>", { desc = "Find and delete lines not matching in selection" })

vim.keymap.set('n', '<leader>nb', ':enew<CR>')

vim.keymap.set('n', '<C-Tab>', '>>', { noremap = true, silent = true, desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', '<<', { noremap = true, silent = true, desc = 'Unindent line' })
vim.keymap.set('v', '<C-Tab>', '>gv', { noremap = true, silent = true, desc = 'Indent selection (keep selection)' })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true, desc = 'Unindent selection (keep selection)' })

vim.keymap.set('v', '<leader>Cy', util.copy_with_numbers, { silent = true, desc = "Copy selection with numbers" })

-- harpoon
vim.keymap.set("n", "<leader>a", function()
	vim.cmd("argadd %")
	vim.cmd("argdedup")
end)

vim.keymap.set("n", "<leader>e", function()
	vim.cmd.args()
end)

vim.keymap.set("n", "<C-h>", function()
	vim.cmd('silent! 1argument')
end)

vim.keymap.set("n", "<C-j>", function()
	vim.cmd('silent! 2argument')
end)

vim.keymap.set("n", "<C-k>", function()
	vim.cmd('silent! 3argument')
end)

vim.keymap.set("n", "<C-l>", function()
	vim.cmd('silent! 4argument')
end)

vim.keymap.set("n", "<leader>uu", function()
  vim.pack.update()
end)
