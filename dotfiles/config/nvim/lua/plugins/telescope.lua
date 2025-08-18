vim.pack.add({
    require("util").pf("nvim-lua/plenary.nvim"),
    require("util").pf("nvim-telescope/telescope.nvim"),
})

local builtin = require('telescope.builtin')
local ivy = require('telescope.themes').get_ivy({})

local with_ivy = function(cmd)
    return function()
        cmd(ivy)
    end
end

require('telescope').load_extension('fzf')
require('telescope').load_extension('lsp_handlers')
require('telescope').load_extension('ui-select')

vim.keymap.set('n', '<leader>ff', with_ivy(builtin.find_files))
vim.keymap.set('n', '<leader>fg', with_ivy(builtin.live_grep))
vim.keymap.set('n', '<leader><leader>', with_ivy(builtin.buffers))
vim.keymap.set('n', '<leader>fh', with_ivy(builtin.help_tags))
vim.keymap.set('n', '<leader>qf', with_ivy(builtin.quickfix))
vim.keymap.set('n', 'gr', with_ivy(builtin.lsp_references))
vim.keymap.set('n', '<leader>jf', function()
    with_ivy(builtin.lsp_document_symbols)
end)
