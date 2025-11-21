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

-- Async make: run &makeprg and load quickfix without blocking
local function async_make()
	local cmd = vim.bo.makeprg
	if cmd == nil or cmd == '' then
		cmd = 'make'
	end
	local expanded = vim.fn.expandcmd(cmd)
	local tmp = vim.fn.tempname()

	local function finish(lines, code)
		vim.schedule(function()
			vim.fn.writefile(lines, tmp)
			vim.cmd('silent! cgetfile ' .. vim.fn.fnameescape(tmp))
			vim.cmd('silent! cwindow')
			if code == 0 then
				vim.notify('Build finished (exit 0)', vim.log.levels.INFO)
			else
				vim.notify('Build finished (exit ' .. tostring(code) .. ')', vim.log.levels.WARN)
			end
		end)
	end

	if vim.system then
		vim.system({'sh','-c', expanded}, { text = true }, function(res)
			local out = (res.stdout or '') .. (res.stderr or '')
			local lines = vim.split(out, '\n', { plain = true })
			finish(lines, res.code or -1)
		end)
	else
		local lines = {}
		local function add_chunk(_, data)
			if type(data) == 'table' then
				for _, l in ipairs(data) do
					if l and #l > 0 then table.insert(lines, l) end
				end
			end
		end
		local jid = vim.fn.jobstart({'sh','-c', expanded}, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = add_chunk,
			on_stderr = add_chunk,
			on_exit = function(_, code) finish(lines, code) end,
		})
		if jid <= 0 then
			vim.notify('Failed to start build job', vim.log.levels.ERROR)
		end
	end
end

vim.keymap.set('n', '<leader>mm', async_make, { silent = true, desc = 'Async make -> quickfix' })

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
