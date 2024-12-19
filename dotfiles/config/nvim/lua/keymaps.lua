-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
-- vim.keymap.set('n', '<leader>nt', ":Neotree filesystem reveal left<CR>", { desc = "Open Neotree" })
vim.keymap.set('n', '<leader>ff', vim.lsp.buf.format, { desc = "Format File" })
vim.keymap.set('v', '<leader>ff', vim.lsp.buf.format, { desc = "Format File" })
vim.keymap.set('n', 'S', ":%s//g<Left><Left>", { desc = "縷  Sed in scope of file" })
vim.keymap.set('v', 'S', ":s//g<Left><Left>", { desc = "縷  Sed in scope of file" })
vim.keymap.set('n', '<A-S>', ":%g//d<Left><Left>", { desc = "縷  Delete lines in file containing" })
vim.keymap.set('v', '<A-S>', ":g//d<Left><Left>", { desc = "縷  Delete lines in file containing" })
vim.keymap.set('n', "<leader>ip", ":diffpu<CR>", { desc = "diff push" })
vim.keymap.set('n', "<leader>ig", ":diffg<CR>", { desc = "diff get" })

vim.keymap.set('n', "<leader>ti", ":tabnew<CR>", { desc = "tabnew" });
vim.keymap.set('n', "<leader>tn", ":tabnext<CR>", { desc = "tabnext" });
vim.keymap.set('n', "<leader>tp", ":tabprevious<CR>", { desc = "tabprevious" });


-- vim: ts=2 sts=2 sw=2 et
