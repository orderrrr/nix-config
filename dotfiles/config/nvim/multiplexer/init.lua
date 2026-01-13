vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugins
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/thesimonho/kanagawa-paper.nvim',
})

-- Theme
require('kanagawa-paper').setup({ transparent = false })
vim.cmd.colorscheme('kanagawa-paper')
vim.cmd('hi statusline guibg=NONE')

vim.o.number = false
vim.o.relativenumber = false
vim.o.termguicolors = true
vim.o.signcolumn = 'no'
vim.o.scrolloff = 5
vim.o.laststatus = 3
vim.o.showtabline = 0
vim.o.showmode = false
vim.o.cmdheight = 0

-- Session management (tabs as sessions)
-- Names stored as tab-local variables so they stay with the tab when indices shift

-- Focused mode state (per-tab)
local focused_mode = {}

local function random_name()
  local chars = 'abcdefghijklmnopqrstuvwxyz'
  local name = ''
  for _ = 1, 4 do
    local idx = math.random(1, #chars)
    name = name .. chars:sub(idx, idx)
  end
  return name
end

local function get_session_name(tabnr)
  tabnr = tabnr or vim.fn.tabpagenr()
  local tabpage = vim.api.nvim_list_tabpages()[tabnr]
  if not tabpage then return random_name() end
  local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabpage, 'session_name')
  if not ok or not name then
    name = random_name()
    vim.api.nvim_tabpage_set_var(tabpage, 'session_name', name)
  end
  return name
end

local function session_name_exists(name, exclude_tabpage)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if tabpage ~= exclude_tabpage then
      local ok, existing = pcall(vim.api.nvim_tabpage_get_var, tabpage, 'session_name')
      if ok and existing == name then
        return true
      end
    end
  end
  return false
end

local function set_session_name(name)
  local tabpage = vim.api.nvim_get_current_tabpage()
  if session_name_exists(name, tabpage) then
    vim.notify('Session name "' .. name .. '" already exists', vim.log.levels.WARN)
    return false
  end
  vim.api.nvim_tabpage_set_var(tabpage, 'session_name', name)
  vim.cmd('redrawstatus')
  return true
end

-- Statusline highlights
local session_colors = {
  { active = '#b8c4b8', dim = '#5a6258' },  -- green
  { active = '#DBCDB3', dim = '#6d6558' },  -- yellow
  { active = '#b4bcc4', dim = '#5a5e62' },  -- blue
  { active = '#c0b8bc', dim = '#605c5e' },  -- magenta
  { active = '#b0bcc8', dim = '#585e64' },  -- cyan
  { active = '#CDACAC', dim = '#665656' },  -- red
}

local function setup_statusline_hl()
  local set = vim.api.nvim_set_hl
  set(0, 'MuxMode', { fg = '#1a1d21', bg = '#b8c4b8', bold = true })
  set(0, 'MuxModeInsert', { fg = '#1a1d21', bg = '#DBCDB3', bold = true })
  set(0, 'MuxModeTerminal', { fg = '#1a1d21', bg = '#b4bcc4', bold = true })

  for i, color in ipairs(session_colors) do
    set(0, 'MuxSession' .. i, { fg = color.dim, bg = 'NONE' })
    set(0, 'MuxSessionActive' .. i, { fg = color.active, bg = 'NONE', bold = true })
  end
end

vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_statusline_hl })
setup_statusline_hl()

local function get_session_hl(index, is_active)
  local color_idx = ((index - 1) % #session_colors) + 1
  if is_active then
    return 'MuxSessionActive' .. color_idx
  else
    return 'MuxSession' .. color_idx
  end
end

local mode_config = {
  n = { text = 'NOR', hl = 'MuxMode' },
  i = { text = 'INS', hl = 'MuxModeInsert' },
  v = { text = 'VIS', hl = 'MuxMode' },
  V = { text = 'V-L', hl = 'MuxMode' },
  [''] = { text = 'V-B', hl = 'MuxMode' },
  c = { text = 'CMD', hl = 'MuxMode' },
  t = { text = 'TRM', hl = 'MuxModeTerminal' },
  R = { text = 'REP', hl = 'MuxModeInsert' },
}

-- Terminal info cache (to avoid expensive shell calls on every redraw)
local term_info_cache = {}

local function get_term_info(bufnr)
  if vim.bo[bufnr].buftype ~= 'terminal' then
    return nil
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return nil end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return nil end

  -- Check cache (refresh every 2 seconds)
  local cache = term_info_cache[bufnr]
  local now = vim.loop.now()
  if cache and (now - cache.time) < 2000 then
    return cache.info
  end

  -- Get child process (the actual running command)
  local child_pid = vim.fn.system('pgrep -P ' .. pid .. ' | tail -1'):gsub('%s+', '')
  local target_pid = child_pid ~= '' and child_pid or pid

  -- Get process name
  local proc = vim.fn.system('ps -o comm= -p ' .. target_pid):gsub('%s+', '')
  proc = proc:match('[^/]+$') or proc  -- basename

  -- Get cwd
  local cwd = vim.fn.system('lsof -a -d cwd -p ' .. target_pid .. " | tail -1 | awk '{print $NF}'"):gsub('%s+', '')
  cwd = cwd:gsub(vim.env.HOME, '~')  -- shorten home dir

  local info = { proc = proc, cwd = cwd }
  term_info_cache[bufnr] = { time = now, info = info }
  return info
end

local function statusline()
  local mode = vim.fn.mode()
  local cfg = mode_config[mode] or { text = '???', hl = 'MuxMode' }
  local tab_count = vim.fn.tabpagenr('$')
  local current_tab = vim.fn.tabpagenr()

  local left = '%#' .. cfg.hl .. '# ' .. cfg.text .. ' '

  local sessions_str = ''
  for i = 1, tab_count do
    local name = get_session_name(i)
    local hl = get_session_hl(i, i == current_tab)
    if i == current_tab then
      sessions_str = sessions_str .. '%#' .. hl .. '# [' .. name .. '] '
    else
      sessions_str = sessions_str .. '%#' .. hl .. '#  ' .. name .. '  '
    end
  end

  -- Right side: terminal info
  local right = ''
  local bufnr = vim.api.nvim_get_current_buf()
  local info = get_term_info(bufnr)
  if info and info.cwd ~= '' then
    right = '%#MuxSession1#%=' .. info.cwd
    if info.proc ~= '' then
      right = right .. ' %#MuxSessionActive1#' .. info.proc .. ' '
    end
  end

  return left .. sessions_str .. right
end

_G.mux_statusline = statusline
vim.o.statusline = '%{%v:lua.mux_statusline()%}'

-- Commands
vim.api.nvim_create_user_command('SessionName', function(opts)
  set_session_name(opts.args)
end, { nargs = 1 })

-- Get current terminal's working directory
local function get_current_term_cwd()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= 'terminal' then
    return nil
  end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return nil end

  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == 0 then return nil end

  -- Get child process (the actual running command)
  local child_pid = vim.fn.system('pgrep -P ' .. pid .. ' | tail -1'):gsub('%s+', '')
  local target_pid = child_pid ~= '' and child_pid or pid

  -- Get cwd
  local cwd = vim.fn.system('lsof -a -d cwd -p ' .. target_pid .. " | tail -1 | awk '{print $NF}'"):gsub('%s+', '')
  
  if cwd ~= '' and vim.fn.isdirectory(cwd) == 1 then
    return cwd
  end
  
  return nil
end

-- Open a new terminal, optionally inheriting cwd from current terminal
local function open_terminal()
  local cwd = get_current_term_cwd()
  
  if cwd then
    -- Change local directory for this window, then open terminal
    vim.cmd('lcd ' .. vim.fn.fnameescape(cwd))
  end
  
  vim.cmd('terminal')
end

-- Open terminal on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    math.randomseed(os.time())
    get_session_name(1)
    open_terminal()
    vim.cmd('startinsert')
  end,
})

-- Exit terminal mode
vim.keymap.set('t', '<A-Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Smart splits: open new terminal when splitting from a terminal
local function smart_split(direction)
  local cmd = direction == 'v' and 'vsplit' or 'split'
  if vim.bo.buftype == 'terminal' then
    vim.cmd(cmd)
    open_terminal()
    vim.cmd('startinsert')
  else
    vim.cmd(cmd)
  end
end

vim.keymap.set('n', '<C-w>v', function() smart_split('v') end, { desc = 'Vertical split' })
vim.keymap.set('n', '<C-w>s', function() smart_split('s') end, { desc = 'Horizontal split' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Alt+hjkl navigation (works in terminal mode too, wraps sessions on h/l)
local function nav_wrap(dir)
  local win_before = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. dir)
  local win_after = vim.api.nvim_get_current_win()

  -- If we didn't move, we're at the edge
  if win_before == win_after then
    if dir == 'h' then
      -- Go to prev session, focus last window
      local tab_count = vim.fn.tabpagenr('$')
      if tab_count > 1 then
        vim.cmd('tabprev')
        vim.cmd('wincmd $')  -- go to last window
      end
    elseif dir == 'l' then
      -- Go to next session, focus first window
      local tab_count = vim.fn.tabpagenr('$')
      if tab_count > 1 then
        vim.cmd('tabnext')
        vim.cmd('wincmd t')  -- go to first window
      end
    end
  end
end

local function enter_terminal_if_needed()
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd('startinsert')
    end
  end)
end

for _, mode in ipairs({ 'n', 't' }) do
  local prefix = mode == 't' and '<C-\\><C-n>' or ''
  vim.keymap.set(mode, '<A-h>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    nav_wrap('h')
    enter_terminal_if_needed()
  end, { desc = 'Move left (wrap session)' })
  vim.keymap.set(mode, '<A-j>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('wincmd j')
    enter_terminal_if_needed()
  end, { desc = 'Move down' })
  vim.keymap.set(mode, '<A-k>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('wincmd k')
    enter_terminal_if_needed()
  end, { desc = 'Move up' })
  vim.keymap.set(mode, '<A-l>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    nav_wrap('l')
    enter_terminal_if_needed()
  end, { desc = 'Move right (wrap session)' })

  -- Alt+Shift+hjkl to resize
  vim.keymap.set(mode, '<A-H>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('vertical resize -3')
    enter_terminal_if_needed()
  end, { desc = 'Resize left' })
  vim.keymap.set(mode, '<A-J>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('resize -3')
    enter_terminal_if_needed()
  end, { desc = 'Resize down' })
  vim.keymap.set(mode, '<A-K>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('resize +3')
    enter_terminal_if_needed()
  end, { desc = 'Resize up' })
  vim.keymap.set(mode, '<A-L>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('vertical resize +3')
    enter_terminal_if_needed()
  end, { desc = 'Resize right' })

  -- Alt+n for new vertical pane, Alt+Shift+n for horizontal
  vim.keymap.set(mode, '<A-n>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('vsplit')
    open_terminal()
    vim.schedule(function() vim.cmd('startinsert') end)
  end, { desc = 'New vertical pane' })
  vim.keymap.set(mode, '<A-N>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('split')
    open_terminal()
    vim.schedule(function() vim.cmd('startinsert') end)
  end, { desc = 'New horizontal pane' })

  -- Alt+x to close pane
  vim.keymap.set(mode, '<A-x>', function()
    if mode == 't' then vim.cmd('stopinsert') end

    -- Check if terminal has a process that might not want to be killed
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].buftype == 'terminal' then
      local job_id = vim.b[bufnr].terminal_job_id
      if job_id then
        local pid = vim.fn.jobpid(job_id)
        if pid and pid > 0 then
          local child = vim.fn.system('pgrep -P ' .. pid .. ' | tail -1'):gsub('%s+', '')
          if child ~= '' then
            local proc = vim.fn.system('ps -o comm= -p ' .. child):gsub('%s+', '')
            proc = proc:match('[^/]+$') or proc
            local shells = { zsh = true, bash = true, fish = true, sh = true, dash = true }
            if not shells[proc] and proc ~= '' then
              local confirm = vim.fn.confirm('Kill "' .. proc .. '"?', '&Yes\n&No', 2)
              if confirm ~= 1 then return end
            end
          end
        end
      end
    end

    local win_count = vim.fn.winnr('$')
    local tab_count = vim.fn.tabpagenr('$')
    if win_count == 1 and tab_count == 1 then
      vim.cmd('qa')
    else
      vim.cmd('close')
      vim.schedule(function()
        if vim.bo.buftype == 'terminal' then
          vim.cmd('startinsert')
        end
      end)
    end
  end, { desc = 'Close pane' })
end

-- Session keybinds (all Alt, work in normal + terminal)
vim.keymap.set({ 'v', 'n' }, '<leader>y', '"+y');
vim.keymap.set({ 'v', 'n' }, '<leader>Y', '"+yg_');
vim.keymap.set({ 'v', 'n' }, '<leader>yy', '"+yy');

vim.keymap.set({ 'v', 'n' }, '<leader>p', '"+p');
vim.keymap.set({ 'v', 'n' }, '<leader>P', '"+P');

for _, mode in ipairs({ 'n', 't' }) do
  vim.keymap.set(mode, '<A-c>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('tabnew')
    get_session_name()
    open_terminal()
    vim.schedule(function() vim.cmd('startinsert') end)
  end, { desc = 'New session' })

  vim.keymap.set(mode, '<A-]>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('tabnext')
    enter_terminal_if_needed()
  end, { desc = 'Next session' })

  vim.keymap.set(mode, '<A-[>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.cmd('tabprev')
    enter_terminal_if_needed()
  end, { desc = 'Previous session' })

  vim.keymap.set(mode, '<A-r>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    vim.ui.input({ prompt = 'Session name: ' }, function(name)
      if name then set_session_name(name) end
    end)
  end, { desc = 'Rename session' })

  vim.keymap.set(mode, '<A-X>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    local tab_count = vim.fn.tabpagenr('$')
    if tab_count == 1 then
      vim.notify('Cannot close the last session', vim.log.levels.WARN)
      return
    end
    vim.cmd('tabclose')
    enter_terminal_if_needed()
  end, { desc = 'Close session' })
end

-- Session picker with telescope
local function get_tab_buffers_info(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  local seen = {}
  local lines = {}
  local term_count = 0

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

  if #lines == 0 then
    table.insert(lines, '  (empty)')
  end

  return lines, term_count
end

local function session_picker()
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
      name = get_session_name(i),
      display = string.format('%s (%d terminals)', get_session_name(i), term_count),
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
        vim.cmd('tabnext ' .. selection.value.tabnr)
        enter_terminal_if_needed()
      end)
      return true
    end,
  }):find()
end

for _, mode in ipairs({ 'n', 't' }) do
  vim.keymap.set(mode, '<A-s>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    session_picker()
  end, { desc = 'Pick session' })
end

-- Focused mode toggle
local function save_layout(tabpage)
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  
  -- Save all buffers in order
  local buffers = {}
  for _, win in ipairs(wins) do
    table.insert(buffers, {
      buf = vim.api.nvim_win_get_buf(win),
      is_current = (win == current_win),
    })
  end
  
  -- Save the view/session state
  local view_file = vim.fn.tempname()
  vim.cmd('mksession! ' .. vim.fn.fnameescape(view_file))
  
  return {
    buffers = buffers,
    view_file = view_file,
    current_buf = current_buf,
  }
end

local function restore_layout(tabpage, saved)
  if not saved or not saved.view_file then return end
  
  -- Check if session file exists
  if vim.fn.filereadable(saved.view_file) == 0 then
    vim.notify('Could not restore layout', vim.log.levels.WARN)
    return
  end
  
  -- Source the saved session
  vim.cmd('silent! source ' .. vim.fn.fnameescape(saved.view_file))
  
  -- Clean up temp file
  vim.fn.delete(saved.view_file)
  
  -- Try to restore to the current buffer
  if saved.current_buf and vim.api.nvim_buf_is_valid(saved.current_buf) then
    -- Find window with this buffer and focus it
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_buf(win) == saved.current_buf then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end
end

local function toggle_focused_mode()
  local tabpage = vim.api.nvim_get_current_tabpage()
  
  if not focused_mode[tabpage] then
    -- Enter focused mode: save layout and hide other windows
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
    if #wins == 1 then
      vim.notify('Already in single pane view', vim.log.levels.INFO)
      return
    end
    
    focused_mode[tabpage] = save_layout(tabpage)
    
    -- Hide all windows except current
    vim.cmd('only')
    vim.notify('Focused mode enabled', vim.log.levels.INFO)
  else
    -- Exit focused mode: restore layout
    local saved_layout = focused_mode[tabpage]
    focused_mode[tabpage] = nil
    
    restore_layout(tabpage, saved_layout)
    
    vim.notify('Focused mode disabled', vim.log.levels.INFO)
    enter_terminal_if_needed()
  end
end

for _, mode in ipairs({ 'n', 't' }) do
  vim.keymap.set(mode, '<A-f>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    toggle_focused_mode()
    enter_terminal_if_needed()
  end, { desc = 'Toggle focused mode' })
end

-- Help window
local function show_help()
  local sections = {
    { title = 'Navigation', keys = {
      { 'Alt+h/j/k/l', 'Move between panes' },
      { 'Alt+h/l', 'Wrap to prev/next session' },
      { 'Alt+[ / ]', 'Prev/next session' },
      { 'Alt+s', 'Session picker' },
      { 'Alt+Esc', 'Exit terminal mode' },
    }},
    { title = 'Panes', keys = {
      { 'Alt+n', 'New vertical pane' },
      { 'Alt+N', 'New horizontal pane' },
      { 'Alt+x', 'Close pane' },
      { 'Alt+f', 'Toggle focused mode' },
    }},
    { title = 'Resize', keys = {
      { 'Alt+H/J/K/L', 'Resize pane' },
    }},
    { title = 'Sessions', keys = {
      { 'Alt+c', 'New session' },
      { 'Alt+r', 'Rename session' },
      { 'Alt+X', 'Close session' },
    }},
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
  width = width + 4  -- padding
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

for _, mode in ipairs({ 'n', 't' }) do
  vim.keymap.set(mode, '<A-/>', function()
    if mode == 't' then vim.cmd('stopinsert') end
    show_help()
  end, { desc = 'Show help' })
end
