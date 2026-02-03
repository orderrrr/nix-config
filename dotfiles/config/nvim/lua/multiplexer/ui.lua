-- UI components module (help window, session picker)
local config = require('multiplexer.config')
local state = require('multiplexer.state')
local session = require('multiplexer.session')
local focus = require('multiplexer.focus')

local M = {}

-- Get all panes across all sessions for the picker
local function get_all_pane_entries()
  local entries = {}
  local tabpages = vim.api.nvim_list_tabpages()

  for tab_idx, tabpage in ipairs(tabpages) do
    local session_name = session.get_name(tab_idx)
    local windows = vim.api.nvim_tabpage_list_wins(tabpage)

    for _, winid in ipairs(windows) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if vim.api.nvim_buf_is_valid(bufnr) then
        local buftype = vim.bo[bufnr].buftype
        local bufname = vim.fn.bufname(bufnr)
        local pane_name

        if buftype == 'terminal' then
          pane_name = vim.b[bufnr].term_title or 'terminal'
        elseif buftype == '' and bufname ~= '' then
          pane_name = vim.fn.fnamemodify(bufname, ':t')
        else
          pane_name = '[No Name]'
        end

        -- Get searchable content from buffer (first 20 lines for performance)
        local search_content = ''
        local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 20, false)
        if ok and lines then
          search_content = table.concat(lines, ' ')
          -- Limit length to avoid performance issues
          if #search_content > 1000 then
            search_content = search_content:sub(1, 1000)
          end
        end

        table.insert(entries, {
          tabnr = tab_idx,
          tabpage = tabpage,
          winid = winid,
          bufnr = bufnr,
          session_name = session_name,
          pane_name = pane_name,
          buftype = buftype,
          display = string.format('[%s] %s#%d', session_name, pane_name, bufnr),
          -- Include buffer content in ordinal for searching
          ordinal = session_name .. ' ' .. pane_name .. ' ' .. search_content,
        })
      end
    end
  end

  return entries
end

-- Get buffer info for a tab (for session picker) - kept for backwards compatibility
local function get_tab_buffers_info(tabnr)
  local tabpage = vim.api.nvim_list_tabpages()[tabnr]
  if not tabpage then
    return { '  (invalid tab)' }, 0
  end

  local lines = {}
  local term_count = 0
  local seen = {}

  -- Helper to add buffer to results
  local function add_buffer(bufnr)
    if seen[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    seen[bufnr] = true

    local buftype = vim.bo[bufnr].buftype
    local bufname = vim.fn.bufname(bufnr)

    if buftype == 'terminal' then
      term_count = term_count + 1
      local term_title = vim.b[bufnr].term_title or 'terminal'
      table.insert(lines, '  ' .. term_title)
    elseif buftype == '' and bufname ~= '' then
      table.insert(lines, '  ' .. bufname)
    end
  end

  -- If in focused mode, use saved buffers
  local saved_buffers = focus.get_saved_buffers(tabpage)
  if saved_buffers then
    for _, buf_info in ipairs(saved_buffers) do
      add_buffer(buf_info.buf)
    end
  end

  -- Use state manager for session buffers
  local session_buffers = state.get_session_buffers(tabpage)
  for _, buf_info in ipairs(session_buffers) do
    add_buffer(buf_info.bufnr)
  end

  -- Always also check visible buffers in the tab (most reliable)
  local ok, buflist = pcall(vim.fn.tabpagebuflist, tabnr)
  if ok and buflist then
    for _, bufnr in ipairs(buflist) do
      add_buffer(bufnr)
    end
  end

  if #lines == 0 then
    table.insert(lines, '  (empty)')
  end

  return lines, term_count
end

-- Show session picker with telescope (now shows individual panes)
function M.show_session_picker(on_select_callback)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')

  local entries = get_all_pane_entries()

  pickers.new({}, {
    prompt_title = 'Panes',
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Buffer Preview',
      get_buffer_by_name = function(self, entry)
        return entry.value.bufnr
      end,
      define_preview = function(self, entry)
        local bufnr = entry.value.bufnr
        local buftype = entry.value.buftype

        if not vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { '(Invalid buffer)' })
          return
        end

        -- For terminal buffers, show the terminal title and some info
        if buftype == 'terminal' then
          local term_title = vim.b[bufnr].term_title or 'terminal'
          local lines = { 'Terminal: ' .. term_title, '' }
          -- Get last 50 lines of terminal content if available
          local buf_lines = vim.api.nvim_buf_get_lines(bufnr, -50, -1, false)
          vim.list_extend(lines, buf_lines)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        else
          -- For regular buffers, show the file content
          local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          if #buf_lines == 0 then
            buf_lines = { '(Empty buffer)' }
          end
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, buf_lines)
        end

        -- Set buffer options for better preview experience
        vim.bo[self.state.bufnr].filetype = vim.bo[bufnr].filetype
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if on_select_callback then
          on_select_callback(selection.value.tabnr, selection.value.winid)
        end
      end)
      return true
    end,
  }):find()
end

-- Show help window
function M.show_help()
  local sections = {
    {
      title = 'Navigation',
      keys = {
        { 'Alt+h/j/k/l', 'Move between panes' },
        { 'Alt+h/l',     'Wrap to prev/next session' },
        { 'Alt+[ / ]',   'Prev/next session' },
        { 'Alt+s',       'Pane picker' },
        { 'Alt+Esc',     'Exit terminal mode' },
      }
    },
    {
      title = 'Panes',
      keys = {
        { 'Alt+n', 'New vertical pane' },
        { 'Alt+N', 'New horizontal pane' },
        { 'Alt+x', 'Close pane' },
        { 'Alt+f', 'Toggle focused mode' },
      }
    },
    {
      title = 'Resize',
      keys = {
        { 'Alt+H/J/K/L', 'Resize pane' },
      }
    },
    {
      title = 'Sessions',
      keys = {
        { 'Alt+c', 'New session' },
        { 'Alt+r', 'Rename session' },
        { 'Alt+X', 'Close session' },
      }
    },
  }

  local lines = {}
  local highlights = {}

  table.insert(lines, '')
  table.insert(lines, '   Multiplexer')
  table.insert(highlights, { line = #lines - 1, col = 3, len = 11, hl = 'MuxSessionActive1' })
  table.insert(lines, '')

  for i, section in ipairs(sections) do
    local color_idx = ((i - 1) % 6) + 1
    table.insert(lines, '   ' .. section.title)
    table.insert(highlights, { line = #lines - 1, col = 3, len = #section.title, hl = 'MuxSessionActive' .. color_idx })
    for _, key in ipairs(section.keys) do
      local line = string.format('   %-14s %s', key[1], key[2])
      table.insert(lines, line)
      table.insert(highlights, { line = #lines - 1, col = 3, len = 14, hl = 'MuxSession' .. color_idx })
    end
    table.insert(lines, '')
  end

  table.insert(lines, '   Press q or Esc to close')
  table.insert(highlights, { line = #lines - 1, col = 3, len = 22, hl = 'MuxSession1' })
  table.insert(lines, '')

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, #line)
  end
  width = width + 4
  local height = #lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl, hl.line, hl.col, hl.col + hl.len)
  end

  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Help ',
    title_pos = 'center',
  })

  vim.wo[win].cursorline = false

  -- Close on any key
  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set('n', '<Esc>', close, { buffer = buf })
  vim.keymap.set('n', 'q', close, { buffer = buf })
  vim.keymap.set('n', '<A-/>', close, { buffer = buf })
  vim.api.nvim_create_autocmd('BufLeave', { buffer = buf, once = true, callback = close })
end

return M
