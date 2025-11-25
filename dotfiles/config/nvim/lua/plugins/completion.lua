local ls = require "luasnip"
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local d = ls.dynamic_node
local function uuid()
	local handle = io.popen "uuidgen | tr -d '\n'"
	if handle == nil then return "notconfigured" end
	local result = handle:read "*a"
	return sn(nil, i(nil, result:lower()))
end

ls.add_snippets("all", {
	s("uuid", {
		d(1, uuid, {}, {}),
	}),
})

require('luasnip.loaders.from_vscode').lazy_load()

require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = nil,
	},
	disable_inline_completion = true,
});

require('blink.cmp').setup({
	snippets = { preset = 'luasnip' },
	keymap = { preset = 'default' },
	window = {
		autocomplete = {
			selection = "auto_insert",
		},
	},
	completion = {
		menu = {
			draw = {
				columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
			},
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
			},
		},
	},
	signature = { enabled = true },
})
