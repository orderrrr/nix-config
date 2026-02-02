-- Session management module
local state = require('multiplexer.state')
local focus = require('multiplexer.focus')

local M = {}

local cmd = vim.cmd
local fn = vim.fn

--------------------------------------------------------------------------------
-- Internal helpers
--------------------------------------------------------------------------------

-- Exit focus mode if active before session operations
local function ensure_not_focused()
  focus.exit_if_active()
end

--------------------------------------------------------------------------------
-- Session info
--------------------------------------------------------------------------------

-- Get session name for a tab
function M.get_name(tabnr)
  return state.get_session_name(tabnr)
end

-- Set session name
function M.set_name(name)
  return state.set_session_name(name)
end

--------------------------------------------------------------------------------
-- Session operations (handle focus mode internally)
--------------------------------------------------------------------------------

-- Go to next session
function M.next()
  ensure_not_focused()
  cmd('tabnext')
end

-- Go to previous session
function M.prev()
  ensure_not_focused()
  cmd('tabprev')
end

-- Create a new session, returns the new tab
function M.new()
  ensure_not_focused()
  cmd('tabnew')
  M.get_name() -- Generate name for new session
  return vim.api.nvim_get_current_tabpage()
end

-- Close current session
-- Returns false if this is the last session
function M.close()
  ensure_not_focused()
  local tab_count = fn.tabpagenr('$')
  if tab_count == 1 then
    return false
  end
  cmd('tabclose')
  return true
end

-- Go to a specific session by tab number
function M.goto_tab(tabnr)
  ensure_not_focused()
  cmd('tabnext ' .. tabnr)
end

-- Initialize (delegates to state manager)
function M.init()
  state.init()
end

return M
