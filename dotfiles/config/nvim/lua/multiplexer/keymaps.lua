-- Keymaps module
local config = require('multiplexer.config')
local session = require('multiplexer.session')
local terminal = require('multiplexer.terminal')
local focus = require('multiplexer.focus')
local ui = require('multiplexer.ui')
local state = require('multiplexer.state')

local M = {}

-- Pre-computed shell lookup (same as terminal.lua)
local SHELLS = {
  zsh = true, bash = true, fish = true, sh = true, dash = true,
  ksh = true, tcsh = true, csh = true,
}

-- Cached API functions for faster access in hot paths
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local bo = vim.bo

-- Enter terminal mode if in a terminal buffer
-- Deferred to ensure buffer state is updated after navigation
local function enter_terminal_if_needed()
  vim.schedule(function()
    if bo.buftype == 'terminal' then
      cmd('startinsert')
    end
  end)
end

-- Navigate with wrapping to adjacent sessions
-- Does not wrap when in focus mode
local function nav_wrap(dir)
  -- Don't wrap sessions in focus mode
  if focus.is_active() then
    cmd('wincmd ' .. dir)
    return
  end

  local win_before = api.nvim_get_current_win()
  cmd('wincmd ' .. dir)
  local win_after = api.nvim_get_current_win()

  -- If we didn't move, we're at the edge
  if win_before == win_after then
    local tab_count = fn.tabpagenr('$')
    if tab_count > 1 then
      if dir == 'h' then
        cmd('tabprev')
        cmd('wincmd $')
      elseif dir == 'l' then
        cmd('tabnext')
        cmd('wincmd t')
      end
    end
  end
end

-- Smart split: open new terminal when splitting from a terminal
local function smart_split(direction)
  local split_cmd = direction == 'v' and 'rightbelow vsplit' or 'rightbelow split'
  if bo.buftype == 'terminal' then
    local cwd = terminal.get_cwd_fast()
    cmd(split_cmd)
    terminal.open(cwd) -- terminal.open handles startinsert
  else
    cmd(split_cmd)
  end
end

-- Close pane with confirmation if running process
-- Optimized: only check for running processes in terminals, uses pre-loaded state module
local function close_pane()
  local bufnr = api.nvim_get_current_buf()
  local buftype = bo[bufnr].buftype

  -- Only check for running processes in terminal buffers
  if buftype == 'terminal' then
    local has_process = false
    local proc_name = 'process'

    -- Fast check: use cached info first (try terminal module's local cache via get_proc_name)
    local cached_proc = terminal.get_proc_name(bufnr)
    if cached_proc then
      has_process = not SHELLS[cached_proc] and cached_proc ~= ''
      proc_name = cached_proc
    else
      -- Try state manager cache
      local cached_info = state.get_terminal_info(bufnr, 2000)
      if cached_info and cached_info.proc then
        has_process = not SHELLS[cached_info.proc] and cached_info.proc ~= ''
        proc_name = cached_info.proc
      else
        -- Fall back to full check only if no cache
        has_process = terminal.has_running_process(bufnr)
        if has_process then
          local info = terminal.get_info(bufnr)
          proc_name = info and info.proc or 'process'
        end
      end
    end

    if has_process then
      local confirm = fn.confirm('Kill "' .. proc_name .. '"?', '&Yes\n&No', 2)
      if confirm ~= 1 then return end
    end
  end

  local win_count = fn.winnr('$')
  local tab_count = fn.tabpagenr('$')
  if win_count == 1 and tab_count == 1 then
    cmd('qa')
  else
    cmd('close')
    enter_terminal_if_needed()
  end
end

-- Setup all keymaps
function M.setup()
  -- Exit terminal mode
  vim.keymap.set('t', '<A-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Window navigation (normal mode)
  vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
  vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
  vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

  -- Smart splits (normal mode)
  vim.keymap.set('n', '<C-w>v', function() smart_split('v') end, { desc = 'Vertical split' })
  vim.keymap.set('n', '<C-w>s', function() smart_split('s') end, { desc = 'Horizontal split' })

  -- Clipboard keymaps
  vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y', { desc = 'Copy to clipboard' })
  vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_', { desc = 'Copy to clipboard (end of line)' })
  vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy', { desc = 'Copy line to clipboard' })
  vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })
  vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P', { desc = 'Paste before from clipboard' })

  -- Alt keymaps (work in normal and terminal mode)
  for _, mode in ipairs({ 'n', 't' }) do
    -- Navigation with session wrapping
    vim.keymap.set(mode, '<A-h>', function()
      if mode == 't' then cmd('stopinsert') end
      nav_wrap('h')
      enter_terminal_if_needed()
    end, { desc = 'Move left (wrap session)' })
    
    vim.keymap.set(mode, '<A-j>', function()
      if mode == 't' then cmd('stopinsert') end
      cmd('wincmd j')
      enter_terminal_if_needed()
    end, { desc = 'Move down' })
    
    vim.keymap.set(mode, '<A-k>', function()
      if mode == 't' then cmd('stopinsert') end
      cmd('wincmd k')
      enter_terminal_if_needed()
    end, { desc = 'Move up' })
    
    vim.keymap.set(mode, '<A-l>', function()
      if mode == 't' then cmd('stopinsert') end
      nav_wrap('l')
      enter_terminal_if_needed()
    end, { desc = 'Move right (wrap session)' })

    -- Resize
    local resize = config.options.resize
    vim.keymap.set(mode, '<A-H>', function()
      if mode == 't' then cmd('stopinsert') end
      -- Only resize if there are multiple vertical splits
      if fn.winnr('$') > 1 then
        cmd('vertical resize -' .. resize.vertical)
      end
      enter_terminal_if_needed()
    end, { desc = 'Resize left' })
    
    vim.keymap.set(mode, '<A-J>', function()
      if mode == 't' then cmd('stopinsert') end
      -- Only resize if there's a window below
      local current_win = api.nvim_get_current_win()
      cmd('wincmd j')
      if api.nvim_get_current_win() ~= current_win then
        -- We moved, so there's a window below, move back and resize
        cmd('wincmd k')
        cmd('resize -' .. resize.horizontal)
      end
      enter_terminal_if_needed()
    end, { desc = 'Resize down' })
    
    vim.keymap.set(mode, '<A-K>', function()
      if mode == 't' then cmd('stopinsert') end
      -- Only resize if there's a window above
      local current_win = api.nvim_get_current_win()
      cmd('wincmd k')
      if api.nvim_get_current_win() ~= current_win then
        -- We moved, so there's a window above, move back and resize
        cmd('wincmd j')
        cmd('resize +' .. resize.horizontal)
      end
      enter_terminal_if_needed()
    end, { desc = 'Resize up' })
    
    vim.keymap.set(mode, '<A-L>', function()
      if mode == 't' then cmd('stopinsert') end
      -- Only resize if there are multiple vertical splits
      if fn.winnr('$') > 1 then
        cmd('vertical resize +' .. resize.vertical)
      end
      enter_terminal_if_needed()
    end, { desc = 'Resize right' })

    -- New panes (optimized: use fast cwd that prefers cache)
    vim.keymap.set(mode, '<A-n>', function()
      if mode == 't' then cmd('stopinsert') end
      focus.exit_if_active()
      local cwd = terminal.get_cwd_fast()
      cmd('rightbelow vsplit')
      terminal.open(cwd) -- terminal.open handles startinsert
    end, { desc = 'New vertical pane' })
    
    vim.keymap.set(mode, '<A-N>', function()
      if mode == 't' then cmd('stopinsert') end
      focus.exit_if_active()
      local cwd = terminal.get_cwd_fast()
      cmd('rightbelow split')
      terminal.open(cwd) -- terminal.open handles startinsert
    end, { desc = 'New horizontal pane' })

    -- Close pane
    vim.keymap.set(mode, '<A-x>', function()
      if mode == 't' then cmd('stopinsert') end
      close_pane()
    end, { desc = 'Close pane' })

    -- Session management (uses session API which handles focus mode)
    vim.keymap.set(mode, '<A-c>', function()
      if mode == 't' then cmd('stopinsert') end
      local cwd = terminal.get_cwd_fast()
      session.new()
      terminal.open(cwd) -- terminal.open handles startinsert
    end, { desc = 'New session' })

    vim.keymap.set(mode, '<A-]>', function()
      if mode == 't' then cmd('stopinsert') end
      session.next()
      enter_terminal_if_needed()
    end, { desc = 'Next session' })

    vim.keymap.set(mode, '<A-[>', function()
      if mode == 't' then cmd('stopinsert') end
      session.prev()
      enter_terminal_if_needed()
    end, { desc = 'Previous session' })

    vim.keymap.set(mode, '<A-r>', function()
      if mode == 't' then cmd('stopinsert') end
      vim.ui.input({ prompt = 'Session name: ' }, function(name)
        if name then session.set_name(name) end
      end)
    end, { desc = 'Rename session' })

    vim.keymap.set(mode, '<A-X>', function()
      if mode == 't' then cmd('stopinsert') end
      if not session.close() then
        vim.notify('Cannot close the last session', vim.log.levels.WARN)
        return
      end
      enter_terminal_if_needed()
    end, { desc = 'Close session' })

    -- Session picker
    vim.keymap.set(mode, '<A-s>', function()
      if mode == 't' then cmd('stopinsert') end
      focus.exit_if_active()
      ui.show_session_picker(function(tabnr)
        session.goto(tabnr)
        enter_terminal_if_needed()
      end)
    end, { desc = 'Pick session' })

    -- Focused mode
    vim.keymap.set(mode, '<A-f>', function()
      if mode == 't' then cmd('stopinsert') end
      focus.toggle()
      enter_terminal_if_needed()
    end, { desc = 'Toggle focused mode' })

    -- Help
    vim.keymap.set(mode, '<A-/>', function()
      if mode == 't' then cmd('stopinsert') end
      ui.show_help()
    end, { desc = 'Show help' })
  end
end

return M
