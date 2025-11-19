-- Create an autogroup for build configurations
local build_group = vim.api.nvim_create_augroup('BuildConfigs', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'zig',
	group = build_group,
	callback = function()
		vim.opt_local.makeprg = 'zig build -fincremental'
		vim.opt_local.errorformat = '%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m,%-G%.%#'
	end
})

vim.keymap.set('n', '<leader>mm', function()
	vim.cmd('silent! make!')
	vim.cmd('silent! cwindow')
end, { silent = true, desc = "Run :make and toggle quickfix on results" })

-- Simple Quickfix Toggle Function
local function toggle_quickfix()
	-- Get all window info
	local windows = vim.fn.getwininfo()
	local qf_open = false

	-- Loop through windows to see if the quickfix is open
	for _, win in ipairs(windows) do
		if win.quickfix == 1 then
			qf_open = true
			break
		end
	end

	-- Toggle based on whether it's open or not
	if qf_open then
		vim.cmd('cclose')
	else
		-- Optional: Check if the quickfix list has items before opening
		if not vim.tbl_isempty(vim.fn.getqflist()) then
			vim.cmd('copen')
		else
			vim.notify("Quickfix list is empty", vim.log.levels.INFO)
		end
	end
end

vim.keymap.set('n', '<leader>mo', toggle_quickfix)

-- Run ./run.sh in CWD
vim.keymap.set('n', '<leader>mr', function()
	local cwd = vim.fn.getcwd()
	local runfile = cwd .. '/run.sh'
	if vim.fn.filereadable(runfile) == 1 then
		-- Open a terminal and run the script
		vim.cmd('terminal bash ./run.sh')
	else
		vim.notify("No run.sh in " .. cwd, vim.log.levels.WARN)
	end
end, { silent = true, desc = "Run ./run.sh in current dir" })
