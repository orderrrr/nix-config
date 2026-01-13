-- Centralized state manager for buffers, sessions, and their relationships
local config = require('multiplexer.config')

-- Use vim.uv (newer API) with fallback to vim.loop
local uv = vim.uv or vim.loop

local M = {}

---@class BufferInfo
---@field bufnr number Buffer number
---@field session number|nil Tabpage handle that owns this buffer
---@field type 'terminal'|'file'|'other' Buffer type
---@field created_at number Timestamp when registered
---@field terminal_info? { proc: string, cwd: string, pid: number, time: number }

---@class SessionInfo
---@field tabpage number Tabpage handle
---@field name string Session name
---@field buffers number[] List of buffer numbers in this session
---@field focused_layout? table Saved layout when in focused mode
---@field created_at number Timestamp when created

---@class EventCallback
---@field id number Callback ID
---@field fn function Callback function

-- State storage
local state = {
  buffers = {}, ---@type table<number, BufferInfo>
  sessions = {}, ---@type table<number, SessionInfo>
  event_listeners = {}, ---@type table<string, EventCallback[]>
  next_listener_id = 1,
  initialized = false,
}

-- Event types
M.events = {
  BUFFER_CREATED = 'buffer_created',
  BUFFER_DELETED = 'buffer_deleted',
  BUFFER_SESSION_CHANGED = 'buffer_session_changed',
  SESSION_CREATED = 'session_created',
  SESSION_DELETED = 'session_deleted',
  SESSION_RENAMED = 'session_renamed',
  SESSION_FOCUS_ENTERED = 'session_focus_entered',
  SESSION_FOCUS_EXITED = 'session_focus_exited',
}

--------------------------------------------------------------------------------
-- Event System
--------------------------------------------------------------------------------

--- Subscribe to an event
---@param event string Event name from M.events
---@param callback function Callback receiving (event_name, data)
---@return number listener_id ID to unsubscribe
function M.on(event, callback)
  if not state.event_listeners[event] then
    state.event_listeners[event] = {}
  end
  local id = state.next_listener_id
  state.next_listener_id = state.next_listener_id + 1
  table.insert(state.event_listeners[event], { id = id, fn = callback })
  return id
end

--- Unsubscribe from an event
---@param event string Event name
---@param listener_id number ID returned from M.on()
function M.off(event, listener_id)
  local listeners = state.event_listeners[event]
  if not listeners then return end
  for i, listener in ipairs(listeners) do
    if listener.id == listener_id then
      table.remove(listeners, i)
      return
    end
  end
end

--- Emit an event to all listeners
---@param event string Event name
---@param data table Event data
local function emit(event, data)
  local listeners = state.event_listeners[event]
  if not listeners then return end
  for _, listener in ipairs(listeners) do
    local ok, err = pcall(listener.fn, event, data)
    if not ok then
      vim.notify('State event handler error: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

--------------------------------------------------------------------------------
-- Buffer Management
--------------------------------------------------------------------------------

--- Determine buffer type
---@param bufnr number
---@return 'terminal'|'file'|'other'
local function get_buffer_type(bufnr)
  local buftype = vim.bo[bufnr].buftype
  if buftype == 'terminal' then
    return 'terminal'
  elseif buftype == '' and vim.fn.bufname(bufnr) ~= '' then
    return 'file'
  else
    return 'other'
  end
end

--- Register a buffer in the state
---@param bufnr number Buffer number
---@param session? number Tabpage handle (defaults to current)
---@return BufferInfo|nil
function M.register_buffer(bufnr, session)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  -- Don't re-register existing buffers
  if state.buffers[bufnr] then
    return state.buffers[bufnr]
  end

  session = session or vim.api.nvim_get_current_tabpage()

  local info = {
    bufnr = bufnr,
    session = session,
    type = get_buffer_type(bufnr),
    created_at = uv.now(),
  }

  state.buffers[bufnr] = info

  -- Add to session's buffer list (check with hash for O(1) instead of O(n))
  local sess = state.sessions[session]
  if sess then
    -- Check if already in list
    local found = false
    for _, b in ipairs(sess.buffers) do
      if b == bufnr then
        found = true
        break
      end
    end
    if not found then
      table.insert(sess.buffers, bufnr)
    end
  end

  emit(M.events.BUFFER_CREATED, { bufnr = bufnr, info = info })
  return info
end

--- Unregister a buffer from the state
---@param bufnr number
function M.unregister_buffer(bufnr)
  local info = state.buffers[bufnr]
  if not info then return end

  -- Remove from session's buffer list
  if info.session then
    local sess = state.sessions[info.session]
    if sess then
      for i, buf in ipairs(sess.buffers) do
        if buf == bufnr then
          table.remove(sess.buffers, i)
          break
        end
      end
    end
  end

  state.buffers[bufnr] = nil
  emit(M.events.BUFFER_DELETED, { bufnr = bufnr, info = info })
end

--- Get buffer info
---@param bufnr number
---@return BufferInfo|nil
function M.get_buffer(bufnr)
  return state.buffers[bufnr]
end

--- Get all registered buffers
---@return table<number, BufferInfo>
function M.get_all_buffers()
  return state.buffers
end

--- Get buffers for a session
---@param tabpage? number Tabpage handle (defaults to current)
---@return BufferInfo[]
function M.get_session_buffers(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  local result = {}
  local sess = state.sessions[tabpage]
  if sess then
    for _, bufnr in ipairs(sess.buffers) do
      local info = state.buffers[bufnr]
      if info and vim.api.nvim_buf_is_valid(bufnr) then
        table.insert(result, info)
      end
    end
  end
  return result
end

--- Move buffer to a different session
---@param bufnr number
---@param new_session number Tabpage handle
function M.move_buffer_to_session(bufnr, new_session)
  local info = state.buffers[bufnr]
  if not info then return end

  local old_session = info.session

  -- Remove from old session
  if old_session then
    local old_sess = state.sessions[old_session]
    if old_sess then
      for i, buf in ipairs(old_sess.buffers) do
        if buf == bufnr then
          table.remove(old_sess.buffers, i)
          break
        end
      end
    end
  end

  -- Add to new session
  info.session = new_session
  local new_sess = state.sessions[new_session]
  if new_sess then
    local found = false
    for _, b in ipairs(new_sess.buffers) do
      if b == bufnr then
        found = true
        break
      end
    end
    if not found then
      table.insert(new_sess.buffers, bufnr)
    end
  end

  emit(M.events.BUFFER_SESSION_CHANGED, {
    bufnr = bufnr,
    old_session = old_session,
    new_session = new_session,
  })
end

--- Update terminal info for a buffer
---@param bufnr number
---@param info { proc: string, cwd: string, pid?: number }
function M.update_terminal_info(bufnr, info)
  local buf_info = state.buffers[bufnr]
  if buf_info and buf_info.type == 'terminal' then
    buf_info.terminal_info = {
      proc = info.proc,
      cwd = info.cwd,
      pid = info.pid or 0,
      time = uv.now(),
    }
  end
end

--- Get cached terminal info
---@param bufnr number
---@param max_age? number Max age in ms (defaults to config)
---@return { proc: string, cwd: string, pid: number }|nil
function M.get_terminal_info(bufnr, max_age)
  local buf_info = state.buffers[bufnr]
  if not buf_info or buf_info.type ~= 'terminal' then
    return nil
  end

  local term_info = buf_info.terminal_info
  if not term_info then return nil end

  max_age = max_age or config.options.terminal.cache_ttl
  local age = uv.now() - term_info.time
  if age > max_age then
    return nil -- Cache expired
  end

  return term_info
end

--------------------------------------------------------------------------------
-- Session Management
--------------------------------------------------------------------------------

--- Generate random session name
---@return string
local function random_name()
  local chars = 'abcdefghijklmnopqrstuvwxyz'
  local name = ''
  for _ = 1, config.options.session.name_length do
    local idx = math.random(1, #chars)
    name = name .. chars:sub(idx, idx)
  end
  return name
end

--- Check if session name exists
---@param name string
---@param exclude_tabpage? number Tabpage to exclude from check
---@return boolean
local function name_exists(name, exclude_tabpage)
  for tabpage, sess in pairs(state.sessions) do
    if tabpage ~= exclude_tabpage and sess.name == name then
      return true
    end
  end
  return false
end

--- Register a session (tab)
---@param tabpage? number Tabpage handle (defaults to current)
---@param name? string Session name (auto-generated if nil)
---@return SessionInfo
function M.register_session(tabpage, name)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  -- Return existing session
  if state.sessions[tabpage] then
    return state.sessions[tabpage]
  end

  -- Generate unique name
  if not name then
    repeat
      name = random_name()
    until not name_exists(name)
  end

  local info = {
    tabpage = tabpage,
    name = name,
    buffers = {},
    created_at = uv.now(),
  }

  state.sessions[tabpage] = info
  emit(M.events.SESSION_CREATED, { tabpage = tabpage, info = info })
  return info
end

--- Unregister a session
---@param tabpage number
function M.unregister_session(tabpage)
  local info = state.sessions[tabpage]
  if not info then return end

  -- Clear session reference from all its buffers
  for _, bufnr in ipairs(info.buffers) do
    local buf_info = state.buffers[bufnr]
    if buf_info then
      buf_info.session = nil
    end
  end

  state.sessions[tabpage] = nil
  emit(M.events.SESSION_DELETED, { tabpage = tabpage, info = info })
end

--- Get session info
---@param tabpage? number Tabpage handle (defaults to current)
---@return SessionInfo|nil
function M.get_session(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return state.sessions[tabpage]
end

--- Get all sessions
---@return table<number, SessionInfo>
function M.get_all_sessions()
  return state.sessions
end

--- Get session name (registers session if needed)
---@param tabnr? number Tab number (1-based index, not tabpage handle)
---@return string
function M.get_session_name(tabnr)
  local tabpage
  if tabnr then
    local tabpages = vim.api.nvim_list_tabpages()
    tabpage = tabpages[tabnr]
  else
    tabpage = vim.api.nvim_get_current_tabpage()
  end

  if not tabpage then
    return random_name()
  end

  local sess = state.sessions[tabpage]
  if not sess then
    sess = M.register_session(tabpage)
  end
  return sess.name
end

--- Set session name
---@param name string
---@param tabpage? number Tabpage handle (defaults to current)
---@return boolean success
function M.set_session_name(name, tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if name_exists(name, tabpage) then
    vim.notify('Session name "' .. name .. '" already exists', vim.log.levels.WARN)
    return false
  end

  local sess = state.sessions[tabpage]
  if not sess then
    sess = M.register_session(tabpage, name)
    return true
  end

  local old_name = sess.name
  sess.name = name
  emit(M.events.SESSION_RENAMED, {
    tabpage = tabpage,
    old_name = old_name,
    new_name = name,
  })
  vim.cmd('redrawstatus')
  return true
end

--- Get session by name
---@param name string
---@return SessionInfo|nil
function M.get_session_by_name(name)
  for _, sess in pairs(state.sessions) do
    if sess.name == name then
      return sess
    end
  end
  return nil
end

--------------------------------------------------------------------------------
-- Focus Mode State
--------------------------------------------------------------------------------

--- Save focused layout for a session
---@param tabpage number
---@param layout table Layout structure
function M.save_focused_layout(tabpage, layout)
  local sess = state.sessions[tabpage]
  if sess then
    sess.focused_layout = layout
    emit(M.events.SESSION_FOCUS_ENTERED, { tabpage = tabpage, layout = layout })
  end
end

--- Get saved focused layout
---@param tabpage number
---@return table|nil
function M.get_focused_layout(tabpage)
  local sess = state.sessions[tabpage]
  return sess and sess.focused_layout
end

--- Clear focused layout (exit focus mode)
---@param tabpage number
---@return table|nil layout The cleared layout
function M.clear_focused_layout(tabpage)
  local sess = state.sessions[tabpage]
  if not sess then return nil end

  local layout = sess.focused_layout
  sess.focused_layout = nil

  if layout then
    emit(M.events.SESSION_FOCUS_EXITED, { tabpage = tabpage, layout = layout })
  end
  return layout
end

--- Check if session is in focused mode
---@param tabpage? number
---@return boolean
function M.is_focused(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  local sess = state.sessions[tabpage]
  return sess and sess.focused_layout ~= nil
end

--------------------------------------------------------------------------------
-- Lifecycle Hooks
--------------------------------------------------------------------------------

--- Setup autocmds for automatic buffer/session tracking
function M.setup_lifecycle_hooks()
  local augroup = vim.api.nvim_create_augroup('MultiplexerState', { clear = true })

  -- Track new buffers
  vim.api.nvim_create_autocmd('BufNew', {
    group = augroup,
    callback = function(ev)
      -- Defer registration to allow buffer properties to be set
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then
          M.register_buffer(ev.buf)
        end
      end)
    end,
  })

  -- Clean up deleted buffers
  vim.api.nvim_create_autocmd('BufDelete', {
    group = augroup,
    callback = function(ev)
      M.unregister_buffer(ev.buf)
    end,
  })

  -- Track terminal job exits
  vim.api.nvim_create_autocmd('TermClose', {
    group = augroup,
    callback = function(ev)
      -- Terminal closed, info will be stale
      local buf_info = state.buffers[ev.buf]
      if buf_info then
        buf_info.terminal_info = nil
      end
    end,
  })

  -- Track new tabs (sessions)
  vim.api.nvim_create_autocmd('TabNew', {
    group = augroup,
    callback = function()
      vim.schedule(function()
        local tabpage = vim.api.nvim_get_current_tabpage()
        M.register_session(tabpage)
      end)
    end,
  })

  -- Clean up closed tabs
  vim.api.nvim_create_autocmd('TabClosed', {
    group = augroup,
    callback = function()
      -- Find and clean up any sessions for tabs that no longer exist
      local valid_tabs = {}
      for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
        valid_tabs[tp] = true
      end

      for tabpage in pairs(state.sessions) do
        if not valid_tabs[tabpage] then
          M.unregister_session(tabpage)
        end
      end
    end,
  })

  -- Track buffer entering windows (for session association)
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = augroup,
    callback = function(ev)
      local bufnr = ev.buf
      local tabpage = vim.api.nvim_get_current_tabpage()

      -- Ensure buffer is registered
      local buf_info = state.buffers[bufnr]
      if not buf_info then
        M.register_buffer(bufnr, tabpage)
      elseif buf_info.session ~= tabpage then
        -- Buffer moved to different session
        M.move_buffer_to_session(bufnr, tabpage)
      end
    end,
  })
end

--- Initialize state manager and sync with existing buffers/tabs
function M.init()
  if state.initialized then return end

  math.randomseed(os.time())

  -- Register existing tabs as sessions
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    M.register_session(tabpage)
  end

  -- Register existing buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      -- Find which tab this buffer belongs to
      local session = nil
      for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
          if vim.api.nvim_win_get_buf(win) == bufnr then
            session = tabpage
            break
          end
        end
        if session then break end
      end
      M.register_buffer(bufnr, session)
    end
  end

  M.setup_lifecycle_hooks()
  state.initialized = true
end

--- Debug: dump current state
---@return table
function M.debug_dump()
  return vim.deepcopy(state)
end

return M
