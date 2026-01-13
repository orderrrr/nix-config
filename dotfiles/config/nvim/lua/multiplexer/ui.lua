-- UI components module (help window, session picker)
local config = require('multiplexer.config')
local state = require('multiplexer.state')
local session = require('multiplexer.session')
local focus = require('multiplexer.focus')

local M = {}

-- Get buffer info for a tab (for session picker)
local function get_tab_buffers_info(tabnr)
  local tabpage = vim.api.nvim_list_tabpages()[tabnr]
  if not tabpage then
    return { '  (invalid tab)' }, 0
  end

  local lines = {}
  local term_count = 0

  -- If in focused mode, use saved buffers
  local saved_buffers = focus.get_saved_buffers(tabpage)
  if saved_buffers then
    for _, buf_info in ipairs(saved_buffers) do
      local bufnr = buf_info.buf
      if vim.api.nvim_buf_is_valid(bufnr) then
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
    end
  else
    -- Use state manager for session buffers
    local session_buffers = state.get_session_buffers(tabpage)
    local seen = {}

    for _, buf_info in ipairs(session_buffers) do
      local bufnr = buf_info.bufnr
      if not seen[bufnr] and vim.api.nvim_buf_is_valid(bufnr) then
        seen[bufnr] = true

        if buf_info.type == 'terminal' then
          term_count = term_count + 1
          local term_title = vim.b[bufnr].term_title or 'terminal'
          table.insert(lines, '  ' .. term_title)
        elseif buf_info.type == 'file' then
          local bufname = vim.fn.bufname(bufnr)
          table.insert(lines, '  ' .. bufname)
        end
      end
    end

    -- Fallback: if state doesn't have buffers yet, use visible buffers
    if #lines == 0 then
      local buflist = vim.fn.tabpagebuflist(tabnr)
      for _, bufnr in ipairs(buflist) do
        if not seen[bufnr] then
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
      end
    end
  end

  if #lines == 0 then
    table.insert(lines, '  (empty)')
  end

  return lines, term_count
end

-- Show session picker with telescope
function M.show_session_picker(on_select_callback)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')

  local tab_count = vim.fn.tabpagenr('$')
  local entries = {}
  for i = 1, tab_count do
    local _, term_count = get_tab_buffers_info(i)
    table.insert(entries, {
      tabnr = i,
      name = session.get_name(i),
      display = string.format('%s (%d terminals)', session.get_name(i), term_count),
    })
  end

  pickers.new({}, {
    prompt_title = 'Sessions',
    finder = finders.new_table({
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Buffers',
      define_preview = function(self, entry)
        local lines = { 'Session: ' .. entry.value.name, '' }
        local buf_lines = get_tab_buffers_info(entry.value.tabnr)
        vim.list_extend(lines, buf_lines)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if on_select_callback then
          on_select_callback(selection.value.tabnr)
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
        { 'Alt+s',       'Session picker' },
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
