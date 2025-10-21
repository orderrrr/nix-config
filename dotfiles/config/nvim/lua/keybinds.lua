vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y');
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_');
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy');

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p');
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P');

vim.keymap.set('n', '<leader>o', ':update<CR> :so<CR>');
vim.keymap.set('n', '<leader>w', ':write<CR>');
vim.keymap.set('n', '<leader>q', ':quit<CR>');

vim.keymap.set('n', 'S', ":%s//g<Left><Left>")
vim.keymap.set('v', 'S', ":s//g<Left><Left>")
vim.keymap.set('n', '<A-S>', ":%g//d<Left><Left>")
vim.keymap.set('v', '<A-S>', ":g//d<Left><Left>")

vim.keymap.set('n', '<A-D>', ":%v//d<Left><Left>")
vim.keymap.set('v', '<A-D>', ":v//d<Left><Left>")

vim.keymap.set('n', '<leader>nb', ':enew<CR>')

vim.keymap.set('n', '<C-Tab>', '>>', { noremap = true, silent = true, desc = 'Indent line' })
vim.keymap.set('n', '<S-Tab>', '<<', { noremap = true, silent = true, desc = 'Unindent line' })
vim.keymap.set('v', '<C-Tab>', '>gv', { noremap = true, silent = true, desc = 'Indent selection (keep selection)' })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true, desc = 'Unindent selection (keep selection)' })

vim.keymap.set({ 'n', 'v' }, '<leader>uu', function()
	-- Select enclosing variable_declaration that contains a struct_declaration,
	-- include the closing line properly, then run the Ex chain.
	local function get_node_at_cursor()
		local cur = vim.api.nvim_win_get_cursor(0)
		local row, col = cur[1] - 1, cur[2]
		local ok, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { row, col } })
		if ok then return node end
		return nil
	end

	local function var_decl_with_struct(node)
		while node do
			if node:type() == "variable_declaration" then
				for i = 0, node:named_child_count() - 1 do
					local ch = node:named_child(i)
					if ch and ch:type() == "struct_declaration" then
						return node
					end
				end
			end
			node = node:parent()
		end
		return nil
	end

	local function convert_struct_with_ex()
		local node = get_node_at_cursor()
		if not node then
			vim.notify("No TS node at cursor", vim.log.levels.WARN)
			return
		end

		local var = var_decl_with_struct(node)
		if not var then
			vim.notify("No enclosing variable_declaration with struct_declaration", vim.log.levels.WARN)
			return
		end

		-- Extract the identifier (const name)
		local name
		for i = 0, var:named_child_count() - 1 do
			local ch = var:named_child(i)
			if ch:type() == "identifier" then
				name = vim.treesitter.get_node_text(ch, 0)
				break
			end
		end
		if not name or name == "" then
			local sr = var:range()
			local line = vim.api.nvim_buf_get_lines(0, sr, sr + 1, false)[1] or ""
			name = line:match("const%s+([%w_]+)%s*=")
		end
		if not name or name == "" then
			vim.notify("Could not determine const name", vim.log.levels.WARN)
			return
		end

		-- Strip prefixes
		name = name:gsub("^struct_sdl_", "")
		name = name:gsub("^struct_", "")
		name = name:gsub("^SDL_", "")

		-- Compute inclusive last line of the declaration
		local sr, _, er, ec = var:range()            -- er, ec are end-exclusive
		local last_line = (ec == 0) and (er - 1) or er -- include the semicolon line
		if last_line < sr then last_line = sr end    -- safety

		-- Set visual marks to cover the entire declaration
		vim.fn.setpos("'<", { 0, sr + 1, 1, 0 })
		vim.fn.setpos("'>", { 0, last_line + 1, 9999, 0 })

		-- Provide name to Vimscript for expression replacement
		vim.g.zig_type_name = name

		-- Run your chain; use 'e' so missing patterns don’t error
		vim.cmd([[
    '<,'>s/struct_sdl_//gie
    '<,'>s/SDL_//ge
    '<,'>s/@import("std").mem.//ge
    '<,'>s/};/\= "\rfn to(self: @This()) type {\rreturn to(self, c.SDL_" . g:zig_type_name . ");\r}\r};"/e
    '<,'>s/Uint/u/ge
    '<,'>s/\[\*c\]/*/ge
    '<,'>s/extern struct/struct/ge
  ]])
	end

	convert_struct_with_ex()
end, { desc = "ZIG Replace SDL with better format" });
