vim.cmd('set completeopt+=noselect')

require('nvim-treesitter.install').update({ with_sync = true })()
require("sclang-format").setup()
require('nvim-treesitter.configs').setup({
	modules = {},
	ignore_install = {},
	parser_install_dir = nil,
	ensure_installed = {},
	sync_install = false,
	auto_install = true,
	highlight = { enable = true, },
	indent = { enable = true, },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn", -- set to `false` to disable one of the mappings
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
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

vim.lsp.config('lua_ls',
	{ settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true), }, }, }, });

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
		'glsl_analyzer',
		'xml_formatter',
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
vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition)
vim.keymap.set('n', '<leader>ss', function() require('snacks').picker.lsp_symbols() end)
vim.keymap.set('n', '<leader>sS', function() require('snacks').picker.lsp_workspace_symbols() end)

vim.keymap.set('n', '<leader>ca', require('actions-preview').code_actions)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition)


-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()

local on_attach = function(_, _)
end

require('plugins.filetypes.jdtls')(on_attach, capabilities)
require("flutter-tools").setup {
	debugger = {
		enabled = true,
		run_via_dap = true,
		register_configurations = function(_)
			require('dap').configurations.dart = {
				{
					type = 'dart',
					request = 'launch',
					name = 'Launch Flutter App',
					program = '${workspaceFolder}/lib/main.dart', -- Adjust if your entry point is different
					cwd = '${workspaceFolder}',
				},
			}
		end,
	},
}

require 'treesitter-context'.setup {
	enable = true,          -- Enable this plugin (Can be enabled/disabled later via commands)
	multiwindow = true,     -- Enable multiwindow support.
	max_lines = 6,          -- How many lines the window should span. Values <= 0 mean no limit.
	min_window_height = 0,  -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	line_numbers = true,
	multiline_threshold = 1, -- Maximum number of lines to show for a single context
	trim_scope = 'outer',   -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	mode = 'cursor',        -- Line used to calculate context. Choices: 'cursor', 'topline'
	-- Separator between context and content. Should be a single character string, like '-'.
	-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	separator = nil,
	zindex = 20,    -- The Z-index of the context window
	on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}

-- vim.fn.sign_define('DapBreakpoint', {text = '', texthl = 'DapBreakpoint', linehl = '', numhl = ''}) -- Example icon
--
-- local signs = { Error = " ", Warn = " clam ", Hint = " ", Info = " " } -- Example using Nerd Font symbols
-- for type, icon in pairs(signs) do
--   local hl = 'LspDiagnosticsSign' .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
