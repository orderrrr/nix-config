-- Session management module (thin wrapper around state manager)
local state = require('multiplexer.state')

local M = {}

-- Get session name for a tab
function M.get_name(tabnr)
  return state.get_session_name(tabnr)
end

-- Set session name
function M.set_name(name)
  return state.set_session_name(name)
end

-- Initialize (delegates to state manager)
function M.init()
  state.init()
end

return M
