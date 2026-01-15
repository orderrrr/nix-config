require("oil").setup({
  columns = {
    "icon",
    "permissions",
    "size",
    "mtime",
  },
  delete_to_trash = false,
})

vim.keymap.set('n', '<leader>o', ':Oil<CR>');
