vim.cmd('set completeopt+=noselect')

local pf = require('util').pf

vim.pack.add({
	pf('nvim-treesitter/nvim-treesitter'),
	pf('nvim-treesitter/playground'),
	pf('neovim/nvim-lspconfig'),
	pf('mason-org/mason.nvim'),
	pf('mason-org/mason-lspconfig.nvim'),
	pf('ziglang/zig.vim'),
	pf('aznhe21/actions-preview.nvim'),
	pf('mfussenegger/nvim-jdtls'),
	pf('nvim-treesitter/nvim-treesitter-context'),
})

require('nvim-treesitter.install').update({ with_sync = true })()

require('nvim-treesitter.configs').setup({
	modules = {},
	ignore_install = {},
	parser_install_dir = nil,
	ensure_installed = {},
	sync_install = false,
	auto_install = true,
	highlight = { enable = true, },
	indent = { enable = true, },
	playground = {
		enable = true,
		disable = {},
		updatetime = 25,
		persist_queries = false,
		keybindings = {
			toggle_query_editor = 'o',
			toggle_hl_groups = 'i',
			toggle_injected_languages = 't',
			toggle_anonymous_nodes = 'a',
			toggle_language_display = 'I',
			focus_language = 'f',
			unfocus_language = 'F',
			update = 'R',
			goto_node = '<cr>',
			show_help = '?',
		},
	}
});

local nvim_lsp = require('lspconfig')
nvim_lsp.lua_ls.setup({ settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file('', true) } } } });

require('mason').setup()
require('mason-lspconfig').setup {
	automatic_enable = {
		'lua_ls',
		'zls',
		'slangd',
		'cpplint',
		'clangd',
		'lemminx',
		'jsonls',
		'ansiblels',
		'yamlls',
		'rust_analyzer',
		'fish_lsp',
		'nil_ls',
		'pyright',
	}
}

vim.keymap.set({ 'n', 'v' }, '<leader>lf', vim.lsp.buf.format);
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)

-- SNACKS
vim.keymap.set('n', 'gd', function() require('snacks').picker.lsp_definitions() end)
vim.keymap.set('n', 'gD', function() require('snacks').picker.lsp_declarations() end)
vim.keymap.set('n', 'gr', function() require('snacks').picker.lsp_references() end)
vim.keymap.set('n', 'gI', function() require('snacks').picker.lsp_implementations() end)
vim.keymap.set('n', 'gy', function() require('snacks').picker.lsp_type_definitions() end)
vim.keymap.set('n', '<leader>ss', function() require('snacks').picker.lsp_symbols() end)
vim.keymap.set('n', '<leader>sS', function() require('snacks').picker.lsp_workspace_symbols() end)

vim.keymap.set('n', '<leader>ca', require('actions-preview').code_actions)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition)

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()

local on_attach = function(_, bufnr)
end

require('plugins.filetypes.jdtls')(on_attach, capabilities)

require 'treesitter-context'.setup {
	enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
	multiwindow = false,      -- Enable multiwindow support.
	max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
	min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	line_numbers = true,
	multiline_threshold = 20, -- Maximum number of lines to show for a single context
	trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
	-- Separator between context and content. Should be a single character string, like '-'.
	-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	separator = nil,
	zindex = 20,     -- The Z-index of the context window
	on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
