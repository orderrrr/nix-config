-- Focused mode module
-- Focus mode is a special view that shows a single buffer fullscreen
-- It appears as 'f' in the statusline, always present but either active or inactive
local state = require('multiplexer.state')
local config = require('multiplexer.config')

local M = {}

-- Focus mode state
local focus_state = {
  active = false,          -- Whether we're currently in focus mode
  buffer = nil,            -- The buffer being shown in focus mode
  original_tab = nil,      -- Tab we came from
  original_win = nil,      -- Window we came from
  cursor = nil,            -- Cursor position when entering focus
  view = nil,              -- Window view when entering focus
}

--------------------------------------------------------------------------------
-- Debug Logging
--------------------------------------------------------------------------------

local function debug_log(...)
  if config.options.focus and config.options.focus.debug then
    local args = { ... }
    local msg = table.concat(
      vim.tbl_map(function(v)
        return type(v) == 'table' and vim.inspect(v) or tostring(v)
      end, args),
      ' '
    )
    vim.notify('[Focus Debug] ' .. msg, vim.log.levels.DEBUG)
  end
end

--------------------------------------------------------------------------------
-- Focus Mode Implementation
--------------------------------------------------------------------------------

-- Enter focus mode with current buffer
local function enter_focus()
  if focus_state.active then
    debug_log('Already in focus mode')
    return
  end

  local current_tab = vim.api.nvim_get_current_tabpage()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()

  debug_log('Entering focus mode, buffer:', current_buf)

  -- Save where we came from
  focus_state.original_tab = current_tab
  focus_state.original_win = current_win
  focus_state.buffer = current_buf
  focus_state.cursor = vim.api.nvim_win_get_cursor(current_win)
  focus_state.view = vim.fn.winsaveview()

  -- Mark original tab as having focus active
  state.save_focused_layout(current_tab, { buffer = current_buf })

  -- Create a new tab at the front for focus mode
  vim.cmd('0tabnew')
  
  -- Set the buffer
  local focus_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(focus_win, current_buf)

  -- Restore cursor and view
  pcall(vim.api.nvim_win_set_cursor, focus_win, focus_state.cursor)
  pcall(vim.fn.winrestview, focus_state.view)

  focus_state.active = true

  vim.cmd('redrawstatus')
  debug_log('Entered focus mode')
end

-- Exit focus mode and return to original location
local function exit_focus()
  if not focus_state.active then
    debug_log('Not in focus mode')
    return
  end

  debug_log('Exiting focus mode')

  -- Get current state before leaving
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local cursor_pos = vim.api.nvim_win_get_cursor(current_win)

  -- Check if original tab still exists
  if not vim.api.nvim_tabpage_is_valid(focus_state.original_tab) then
    vim.notify('Original tab no longer exists', vim.log.levels.WARN)
    focus_state.active = false
    focus_state.original_tab = nil
    focus_state.original_win = nil
    focus_state.buffer = nil
    vim.cmd('redrawstatus')
    return
  end

  -- Clear focused state
  state.clear_focused_layout(focus_state.original_tab)

  -- Close the focus tab (current tab)
  local focus_tab = vim.api.nvim_get_current_tabpage()
  
  -- Switch to original tab first
  vim.api.nvim_set_current_tabpage(focus_state.original_tab)

  -- Close the focus tab
  pcall(function()
    local tabnr = vim.api.nvim_tabpage_get_number(focus_tab)
    vim.cmd('tabclose ' .. tabnr)
  end)

  -- Sync cursor back to original window if it has the same buffer
  if focus_state.original_win and vim.api.nvim_win_is_valid(focus_state.original_win) then
    local win_buf = vim.api.nvim_win_get_buf(focus_state.original_win)
    vim.api.nvim_set_current_win(focus_state.original_win)
    if win_buf == current_buf then
      pcall(vim.api.nvim_win_set_cursor, focus_state.original_win, cursor_pos)
    end
  else
    -- Try to find any window with the buffer
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(focus_state.original_tab)) do
      if vim.api.nvim_win_get_buf(win) == current_buf then
        vim.api.nvim_set_current_win(win)
        pcall(vim.api.nvim_win_set_cursor, win, cursor_pos)
        break
      end
    end
  end

  -- Reset state
  focus_state.active = false
  focus_state.original_tab = nil
  focus_state.original_win = nil
  focus_state.buffer = nil
  focus_state.cursor = nil
  focus_state.view = nil

  vim.cmd('redrawstatus')
  debug_log('Exited focus mode')
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Toggle focus mode
function M.toggle()
  if focus_state.active then
    exit_focus()
  else
    enter_focus()
  end
end

-- Check if focus mode is active
function M.is_active()
  return focus_state.active
end

-- Alias for compatibility
function M.is_focused(tabpage)
  -- If tabpage provided, check if it's the one that has focus mode active
  if tabpage then
    return focus_state.active and focus_state.original_tab == tabpage
  end
  return focus_state.active
end

-- Get the buffer currently in focus mode
function M.get_buffer()
  if focus_state.active then
    return focus_state.buffer
  end
  return nil
end

-- Get info about the original location (for UI)
function M.get_original_info()
  if focus_state.active then
    return {
      tab = focus_state.original_tab,
      win = focus_state.original_win,
      buffer = focus_state.buffer,
    }
  end
  return nil
end

-- Get saved buffers (for UI display compatibility)
function M.get_saved_buffers(tabpage)
  if focus_state.active and focus_state.original_tab then
    if vim.api.nvim_tabpage_is_valid(focus_state.original_tab) then
      local buffers = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(focus_state.original_tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        table.insert(buffers, { buf = buf, is_current = (buf == focus_state.buffer) })
      end
      return buffers
    end
  end
  return nil
end

return M
