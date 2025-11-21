require('snacks').setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = true },
	picker = { enabled = true },
	notifier = { enabled = false },
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = false },
	terminal = { enabled = true },
});

vim.keymap.set({ 'n', 't' }, '<leader>tt', function() require('snacks').terminal() end)
vim.keymap.set({ 't' }, '<C-\\>', '<C-\\><C-n>')

require("kanagawa-paper").setup({ transparent = false })
vim.cmd.colorscheme("kanagawa-paper")
vim.cmd('hi statusline guibg=NONE')

require('illuminate').configure {
	providers = {
		'lsp',
		'treesitter',
		'regex',
	},
	delay = 50,
	filetypes_denylist = {
		'dirvish',
		'fugitive',
	},
	under_cursor = true,
}

require('ccc').setup({})
