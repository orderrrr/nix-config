require('luasnip.loaders.from_vscode').lazy_load()
require('plugins.snippets')

require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = nil,
	},
	disable_inline_completion = true,
});

require('blink.cmp').setup({
	snippets = { preset = 'luasnip' },
	keymap = { preset = 'default' },
	-- window = {
	-- 	completion = {
	-- 		selection = "auto_insert",
	-- 	},
	-- },
	completion = {
		list = {
			selection = {
				preselect = true,
				auto_insert = true,
			},
		},
		accept = { auto_brackets = { enabled = true } },
		menu = {
			border = "rounded",
			auto_show = true,
			draw = {
				columns = {
					{ "label",     "label_description", gap = 1 },
					{ "kind_icon", "kind" },
				},
			},
		},
		documentation = {
			auto_show = true,
			window = {
				border = "single",
			},
		},
		ghost_text = {
			enabled = false,
		},
	},
	fuzzy = {
		implementation = 'prefer_rust',
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = 'normal'
	},
	sources = {
		default = { 'supermaven', 'lsp', 'path', 'snippets', 'buffer' },
		providers = {
			supermaven = {
				name = 'supermaven',
				module = 'blink.compat.source',
				score_offset = 1000,
			},
		},
	},

	cmdline = {
		sources = function()
			local type = vim.fn.getcmdtype()
			if type == "/" or type == "?" then
				return { "buffer" }
			elseif type == ":" then
				return { "cmdline" }
			end
			return {}
		end,
	},

	signature = { enabled = true, window = { border = "rounded" } },
})
