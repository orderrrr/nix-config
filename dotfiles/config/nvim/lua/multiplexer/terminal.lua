-- Terminal utilities module
local config = require('multiplexer.config')
local state = require('multiplexer.state')

local M = {}

-- Get child process PID
local function get_child_pid(parent_pid)
  local child = vim.fn.system('pgrep -P ' .. parent_pid .. ' | tail -1'):gsub('%s+', '')
  return child ~= '' and child or nil
end

-- Get process name by PID
local function get_proc_name(pid)
  local proc = vim.fn.system('ps -o comm= -p ' .. pid):gsub('%s+', '')
  return proc:match('[^/]+$') or proc -- basename
end

-- Get cwd by PID
local function get_proc_cwd(pid)
  local cwd = vim.fn.system('lsof -a -d cwd -p ' .. pid .. " | tail -1 | awk '{print $NF}'"):gsub('%s+', '')
  return cwd ~= '' and cwd or nil
end

-- Get terminal info (process name and cwd)
function M.get_info(bufnr)
  if vim.bo[bufnr].buftype ~= 'terminal' then
    return nil
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return nil end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return nil end

  -- Check cached info in state manager
  local cached = state.get_terminal_info(bufnr)
  if cached then
    return { proc = cached.proc, cwd = cached.cwd }
  end

  -- Fetch fresh info
  local child_pid = get_child_pid(pid)
  local target_pid = child_pid or pid

  local proc = get_proc_name(target_pid)
  local cwd = get_proc_cwd(target_pid)
  if cwd then
    cwd = cwd:gsub(vim.env.HOME, '~') -- shorten home dir
  else
    cwd = ''
  end

  local info = { proc = proc, cwd = cwd }

  -- Update cache in state manager
  state.update_terminal_info(bufnr, {
    proc = proc,
    cwd = cwd,
    pid = tonumber(target_pid) or 0,
  })

  return info
end

-- Get current terminal's working directory
function M.get_cwd(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype ~= 'terminal' then
    return nil
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return nil end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return nil end

  -- Get child process
  local child_pid = get_child_pid(pid)
  local target_pid = child_pid or pid

  -- Get cwd
  local cwd = get_proc_cwd(target_pid)

  if cwd and vim.fn.isdirectory(cwd) == 1 then
    return cwd
  end

  return nil
end

-- Open a new terminal with optional cwd
function M.open(cwd)
  if cwd and vim.fn.isdirectory(cwd) == 1 then
    vim.cmd('lcd ' .. vim.fn.fnameescape(cwd))
  end
  vim.cmd('terminal')

  -- Register the new terminal buffer with state manager
  vim.schedule(function()
    local bufnr = vim.api.nvim_get_current_buf()
    state.register_buffer(bufnr)
  end)
end

-- Check if buffer has a running process (not just shell)
function M.has_running_process(bufnr)
  if vim.bo[bufnr].buftype ~= 'terminal' then
    return false
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return false end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return false end

  local child_pid = get_child_pid(pid)
  if not child_pid then return false end

  local proc = get_proc_name(child_pid)
  local shells = { zsh = true, bash = true, fish = true, sh = true, dash = true }
  return not shells[proc] and proc ~= ''
end

return M
