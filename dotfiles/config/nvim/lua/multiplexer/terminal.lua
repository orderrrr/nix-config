-- Terminal utilities module
local config = require('multiplexer.config')
local state = require('multiplexer.state')

local M = {}

-- Use vim.uv (newer API) with fallback to vim.loop
local uv = vim.uv or vim.loop

-- Pre-computed shell lookup table (faster than table iteration)
local SHELLS = {
  zsh = true, bash = true, fish = true, sh = true, dash = true,
  ksh = true, tcsh = true, csh = true,
}

-- Cache for async operations to avoid redundant shell calls
local async_cache = {
  cwd = {}, -- bufnr -> { cwd = string, time = number }
  proc = {}, -- bufnr -> { proc = string, pid = number, time = number }
}

-- Combined shell script to get child PID, process name, and cwd in ONE call
-- This eliminates multiple process spawns
local GET_TERM_INFO_SCRIPT = [[
pid=%d
child=$(pgrep -P $pid 2>/dev/null | tail -1)
target=${child:-$pid}
proc=$(ps -o comm= -p $target 2>/dev/null | xargs basename 2>/dev/null)
cwd=$(lsof -a -d cwd -p $target 2>/dev/null | awk 'NR>1 {print $NF}' | head -1)
echo "$target"
echo "$proc"
echo "$cwd"
]]

-- Get child process PID (sync, used as fallback)
local function get_child_pid(parent_pid)
  local child = vim.fn.system('pgrep -P ' .. parent_pid .. ' 2>/dev/null | tail -1'):gsub('%s+', '')
  return child ~= '' and child or nil
end

-- Get process name by PID (sync, used as fallback)
local function get_proc_name(pid)
  local proc = vim.fn.system('ps -o comm= -p ' .. pid .. ' 2>/dev/null'):gsub('%s+', '')
  return proc:match('[^/]+$') or proc -- basename
end

-- Get cwd by PID (sync, used as fallback)
local function get_proc_cwd(pid)
  local cwd = vim.fn.system('lsof -a -d cwd -p ' .. pid .. " 2>/dev/null | awk 'NR>1 {print $NF}' | head -1"):gsub('%s+', '')
  return cwd ~= '' and cwd or nil
end

-- Async get ALL terminal info in a single shell call (non-blocking)
local function get_term_info_async(bufnr, callback)
  if vim.bo[bufnr].buftype ~= 'terminal' then
    callback(nil)
    return
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then
    callback(nil)
    return
  end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then
    callback(nil)
    return
  end

  -- Single shell call to get everything
  local script = string.format(GET_TERM_INFO_SCRIPT, pid)
  local stdout_lines = {}

  vim.fn.jobstart({ 'sh', '-c', script }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      stdout_lines = data
    end,
    on_exit = function()
      local target_pid = stdout_lines[1] and stdout_lines[1]:gsub('%s+', '')
      local proc = stdout_lines[2] and stdout_lines[2]:gsub('%s+', '')
      local cwd = stdout_lines[3] and stdout_lines[3]:gsub('%s+', '')

      local now = uv.now()

      -- Cache results
      if cwd and cwd ~= '' and vim.fn.isdirectory(cwd) == 1 then
        async_cache.cwd[bufnr] = { cwd = cwd, time = now }
      end
      if proc and proc ~= '' then
        async_cache.proc[bufnr] = {
          proc = proc,
          pid = tonumber(target_pid) or 0,
          time = now,
        }
      end

      callback({
        pid = tonumber(target_pid) or 0,
        proc = proc or '',
        cwd = cwd or '',
      })
    end,
  })
end

-- Get cached cwd (fast path for pane creation)
local function get_cached_cwd(bufnr)
  local cached = async_cache.cwd[bufnr]
  if cached then
    local age = uv.now() - cached.time
    -- Use a shorter TTL for cwd cache (500ms) since it changes frequently
    if age < 500 then
      return cached.cwd
    end
  end
  return nil
end

-- Get cached process info
local function get_cached_proc(bufnr)
  local cached = async_cache.proc[bufnr]
  if cached then
    local age = uv.now() - cached.time
    if age < 2000 then -- 2 second TTL for process info
      return cached
    end
  end
  return nil
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

  -- Check local cache first (fastest)
  local cached_proc = get_cached_proc(bufnr)
  local cached_cwd = get_cached_cwd(bufnr)
  if cached_proc and cached_cwd then
    return { proc = cached_proc.proc, cwd = cached_cwd:gsub(vim.env.HOME, '~') }
  end

  -- Check state manager cache
  local cached = state.get_terminal_info(bufnr)
  if cached then
    return { proc = cached.proc, cwd = cached.cwd }
  end

  -- Fetch fresh info (sync fallback) - combined into fewer calls
  local child_pid = get_child_pid(pid)
  local target_pid = child_pid or pid

  local proc = get_proc_name(target_pid)
  local cwd = get_proc_cwd(target_pid)

  -- Cache immediately
  local now = uv.now()
  if proc and proc ~= '' then
    async_cache.proc[bufnr] = { proc = proc, pid = tonumber(target_pid) or 0, time = now }
  end
  if cwd and cwd ~= '' then
    async_cache.cwd[bufnr] = { cwd = cwd, time = now }
  end

  if cwd then
    cwd = cwd:gsub(vim.env.HOME, '~') -- shorten home dir
  else
    cwd = ''
  end

  local info = { proc = proc, cwd = cwd }

  -- Update state manager cache
  state.update_terminal_info(bufnr, {
    proc = proc,
    cwd = cwd,
    pid = tonumber(target_pid) or 0,
  })

  return info
end

-- Get current terminal's working directory
-- Uses cache first, falls back to sync call if needed
function M.get_cwd(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].buftype ~= 'terminal' then
    return nil
  end

  -- Fast path: check local cache first
  local cached_cwd = get_cached_cwd(bufnr)
  if cached_cwd then
    return cached_cwd
  end

  -- Check state manager cache
  local term_info = state.get_terminal_info(bufnr, 500) -- 500ms TTL
  if term_info and term_info.cwd and term_info.cwd ~= '' then
    local cwd = term_info.cwd:gsub('^~', vim.env.HOME)
    if vim.fn.isdirectory(cwd) == 1 then
      return cwd
    end
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
    -- Cache the result
    async_cache.cwd[bufnr] = { cwd = cwd, time = uv.now() }
    return cwd
  end

  return nil
end

-- Get cwd with fallback to sync call for terminal buffers
-- Returns immediately if cached, otherwise does sync call for terminals
function M.get_cwd_fast(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Try cache first (instant)
  local cached_cwd = get_cached_cwd(bufnr)
  if cached_cwd then
    return cached_cwd
  end

  -- Check state manager cache
  local term_info = state.get_terminal_info(bufnr, 1000)
  if term_info and term_info.cwd and term_info.cwd ~= '' then
    local cwd = term_info.cwd:gsub('^~', vim.env.HOME)
    if vim.fn.isdirectory(cwd) == 1 then
      return cwd
    end
  end

  -- For terminal buffers, do the sync call to get the actual cwd
  -- This is important for correctness when creating new panes
  if vim.bo[bufnr].buftype == 'terminal' then
    local cwd = M.get_cwd(bufnr)
    if cwd then
      return cwd
    end
  end

  -- Fallback to vim's cwd only for non-terminal buffers
  return vim.fn.getcwd()
end

-- Prefetch all terminal info asynchronously (call this to warm the cache)
function M.prefetch_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  get_term_info_async(bufnr, function() end)
end

-- Alias for backward compatibility
M.prefetch_cwd = M.prefetch_info

-- Open a new terminal with optional cwd
function M.open(cwd)
  if cwd and vim.fn.isdirectory(cwd) == 1 then
    vim.cmd('lcd ' .. vim.fn.fnameescape(cwd))
  end
  vim.cmd('terminal')

  -- Register the new terminal buffer with state manager (deferred)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      state.register_buffer(bufnr)
      -- Pre-cache the cwd for this new terminal
      if cwd then
        async_cache.cwd[bufnr] = { cwd = cwd, time = vim.loop.now() }
      end
    end
  end)
end

-- Check if buffer has a running process (not just shell)
-- Optimized: checks cache first, uses pre-computed shell lookup
function M.has_running_process(bufnr)
  if vim.bo[bufnr].buftype ~= 'terminal' then
    return false
  end

  -- Check local cache first
  local cached_proc = get_cached_proc(bufnr)
  if cached_proc and cached_proc.proc then
    return not SHELLS[cached_proc.proc] and cached_proc.proc ~= ''
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return false end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return false end

  local child_pid = get_child_pid(pid)
  if not child_pid then return false end

  local proc = get_proc_name(child_pid)

  -- Cache the result
  async_cache.proc[bufnr] = {
    proc = proc,
    pid = tonumber(child_pid) or 0,
    time = uv.now(),
  }

  return not SHELLS[proc] and proc ~= ''
end

-- Get process name for a terminal buffer (uses cache)
function M.get_proc_name(bufnr)
  local cached = get_cached_proc(bufnr)
  if cached then
    return cached.proc
  end
  return nil
end

-- Clear cache for a buffer (call on buffer delete)
function M.clear_cache(bufnr)
  async_cache.cwd[bufnr] = nil
  async_cache.proc[bufnr] = nil
end

-- Setup autocmds for cache management and prefetching
function M.setup_cache_autocmds()
  local augroup = vim.api.nvim_create_augroup('MultiplexerTerminalCache', { clear = true })

  -- Prefetch terminal info when entering a terminal buffer (background warmup)
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function(ev)
      if vim.bo[ev.buf].buftype == 'terminal' then
        -- Prefetch in background after a short delay
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(ev.buf) then
            M.prefetch_info(ev.buf)
          end
        end, 50) -- 50ms delay to not block UI
      end
    end,
  })

  -- Also prefetch on WinEnter for faster response when switching windows
  vim.api.nvim_create_autocmd('WinEnter', {
    group = augroup,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == 'terminal' then
        -- Check if cache is stale
        local cached = get_cached_cwd(bufnr)
        if not cached then
          M.prefetch_info(bufnr)
        end
      end
    end,
  })

  -- Clean up cache when buffer is deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    group = augroup,
    callback = function(ev)
      M.clear_cache(ev.buf)
    end,
  })
end

return M
