local M = {}

function M.pf(name)
	-- Check if the first 4 characters are "http"
	if string.sub(name, 1, 4) ~= "http" then
		name = "https://github.com/" .. name
	end
	return { src = name }
end

function M.copy_with_numbers()
	-- Get the start and end lines of the current visual selection
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")

	-- Get the lines from the buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Create a new list with line numbers prepended
	local numbered_lines = {}
	for i, line in ipairs(lines) do
		-- The number is the 1-based index `i`
		table.insert(numbered_lines, tostring(i) .. " " .. line)
	end

	-- Combine the lines into a single string
	local content = table.concat(numbered_lines, "\n")

	-- Copy the content to the system clipboard register '+'
	vim.fn.setreg('+', content)

	-- Print a confirmation message
	vim.notify("Copied " .. #lines .. " lines to clipboard with numbers.", vim.log.levels.INFO)
end

return M
