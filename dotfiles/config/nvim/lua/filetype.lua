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
		vim.system({ 'sh', '-c', expanded }, { text = true }, function(res)
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
		local jid = vim.fn.jobstart({ 'sh', '-c', expanded }, {
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

-- Run ./run.sh in a fixed "stdout" panel at the bottom quarter of the current window
local function open_stdout_panel(height)
	local name = "stdout"
	local buf

	-- Find existing buffer named "stdout"
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == name then
			buf = b
			break
		end
	end

	-- Create buffer if not found
	if not buf then
		buf = vim.api.nvim_create_buf(false, true) -- scratch, unlisted
		vim.api.nvim_buf_set_name(buf, name)
		vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
		vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
		vim.api.nvim_buf_set_option(buf, 'swapfile', false)
		vim.api.nvim_buf_set_option(buf, 'filetype', 'log')
	end

	-- Reuse window if already showing the buffer
	local win
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(w) == buf then
			win = w
			break
		end
	end

	local desired = math.max(3, height)
	if not win then
		vim.cmd(string.format('botright %dsplit', desired))
		win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, buf)
		vim.wo[win].wrap = false
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
		vim.wo[win].cursorline = false
	else
		pcall(vim.api.nvim_win_set_height, win, desired)
	end

	return buf, win
end

local function run_in_stdout_panel()
	local cwd = vim.fn.getcwd()
	local runfile = cwd .. '/run.sh'
	if vim.fn.filereadable(runfile) ~= 1 then
		vim.notify("No run.sh in " .. cwd, vim.log.levels.WARN)
		return
	end

	local curwin = vim.api.nvim_get_current_win()
	local height = math.floor(vim.api.nvim_win_get_height(curwin) / 4)
	local buf, panel_win = open_stdout_panel(height)

	-- Clear buffer and prepare to stream
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	local function append_lines(lines)
		if not lines or #lines == 0 then return end
		-- Filter out a solitary empty string chunk from job callbacks
		local any_nonempty = false
		for _, l in ipairs(lines) do
			if l ~= '' then
				any_nonempty = true; break
			end
		end
		if not any_nonempty and #lines == 1 then return end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(buf) then return end
			vim.api.nvim_buf_set_option(buf, 'modifiable', true)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
			vim.api.nvim_buf_set_option(buf, 'modifiable', false)
			-- Auto-scroll all windows showing the buffer
			local info = vim.fn.getbufinfo(buf)[1]
			if info and info.windows then
				for _, w in ipairs(info.windows) do
					pcall(vim.api.nvim_win_set_cursor, w, { vim.api.nvim_buf_line_count(buf), 0 })
				end
			end
		end)
	end

	local jid = vim.fn.jobstart({ 'bash', './run.sh' }, {
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data, _)
			append_lines(data)
		end,
		on_stderr = function(_, data, _)
			append_lines(data)
		end,
		on_exit = function(_, code, _)
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_set_option(buf, 'modifiable', true)
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '', string.format('[exit %d]', code) })
					vim.api.nvim_buf_set_option(buf, 'modifiable', false)
				end
				local level = (code == 0) and vim.log.levels.INFO or vim.log.levels.WARN
				vim.notify('run.sh finished (exit ' .. tostring(code) .. ')', level)
			end)
		end,
	})

	if jid <= 0 then
		vim.notify('Failed to start run.sh job', vim.log.levels.ERROR)
	end

	-- Restore focus to the original window
	if vim.api.nvim_win_is_valid(curwin) then
		vim.api.nvim_set_current_win(curwin)
	end
end

vim.keymap.set('n', '<leader>mr', run_in_stdout_panel, { silent = true, desc = "Run ./run.sh -> stdout panel" })
