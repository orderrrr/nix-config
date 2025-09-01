vim.pack.add({
    require("util").pf("nvim-lua/plenary.nvim"),
    require("util").pf("nvim-telescope/telescope-ui-select.nvim"),
    require("util").pf("gbrlsnchs/telescope-lsp-handlers.nvim"),
    require('util').pf('aaronhallaert/advanced-git-search.nvim'),
    require("util").pf("nvim-telescope/telescope.nvim"),
})

require('telescope').load_extension('lsp_handlers')
require('telescope').load_extension('ui-select')
require("telescope").load_extension("advanced_git_search")

require('telescope').setup({
    defaults = {
        layout_config = {
            vertical = { width = 0.5 }
        },
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
    pickers = {},
    extensions = {
        advanced_git_search = {},
        fzf = {},
        ["ui-select"] = {},
    }
})

local builtin = require('telescope.builtin')

local with_ivy = function(cmd, opts)
    local ivy = require('telescope.themes').get_ivy(opts)
    return function()
        cmd(ivy)
    end
end

vim.keymap.set('n', '<leader>ff', with_ivy(builtin.find_files))
vim.keymap.set('n', '<leader>fg', with_ivy(builtin.live_grep))
vim.keymap.set('n', '<leader><leader>', with_ivy(builtin.buffers))
vim.keymap.set('n', '<leader>fh', with_ivy(builtin.help_tags))
vim.keymap.set('n', '<leader>qf', with_ivy(builtin.quickfix))
vim.keymap.set('n', 'gr', with_ivy(builtin.lsp_references))
vim.keymap.set('n', '<leader>jf', with_ivy(builtin.lsp_document_symbols, { symbols = 'function' }))
vim.keymap.set('n', '<leader>jm', with_ivy(builtin.lsp_document_symbols, { symbols = 'method' }))
vim.keymap.set('n', '<leader>jj', with_ivy(builtin.lsp_document_symbols))
vim.keymap.set('n', "<leader>lD", with_ivy(builtin.diagnostics))
vim.keymap.set('n', "<leader>lDD", with_ivy(builtin.diagnostics, { severity = "ERROR" }))
