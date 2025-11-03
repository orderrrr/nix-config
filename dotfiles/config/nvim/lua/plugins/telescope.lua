local pf = require('util').pf

vim.pack.add({
	pf("nvim-lua/plenary.nvim"),
	pf("nvim-telescope/telescope-ui-select.nvim"),
	pf("gbrlsnchs/telescope-lsp-handlers.nvim"),
	pf('aaronhallaert/advanced-git-search.nvim'),
	pf("nvim-telescope/telescope.nvim"),
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

local with_ivy = function(cmd, theme_opts)
  local ivy = require('telescope.themes').get_ivy(theme_opts)
  return function(opts)
    local final_opts = vim.tbl_deep_extend('force', ivy, opts or {})
    cmd(final_opts)
  end
end

vim.keymap.set('n', '<leader>ff', with_ivy(builtin.find_files))
vim.keymap.set('n', '<leader>fg', with_ivy(builtin.live_grep))
vim.keymap.set('n', '<leader><leader>', with_ivy(builtin.buffers))
vim.keymap.set('n', '<leader>fh', with_ivy(builtin.help_tags))
vim.keymap.set('n', '<leader>qf', with_ivy(builtin.quickfix))
vim.keymap.set('n', 'gr', with_ivy(builtin.lsp_references))
vim.keymap.set('n', '<leader>jf', function() with_ivy(builtin.lsp_document_symbols)({ symbols = 'function' }) end)
vim.keymap.set('n', '<leader>jm', function() with_ivy(builtin.lsp_document_symbols)({ symbols = 'method' }) end)
vim.keymap.set('n', '<leader>jj', function() with_ivy(builtin.lsp_document_symbols)({}) end)
vim.keymap.set('n', "<leader>lD", with_ivy(builtin.diagnostics))
vim.keymap.set('n', "<leader>lDD", with_ivy(builtin.diagnostics, { severity = "ERROR" }))
