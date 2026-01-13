-- Keymaps module
local config = require('multiplexer.config')
local session = require('multiplexer.session')
local terminal = require('multiplexer.terminal')
local focus = require('multiplexer.focus')
local ui = require('multiplexer.ui')

local M = {}

-- Enter terminal mode if in a terminal buffer
local function enter_terminal_if_needed()
  vim.schedule(function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd('startinsert')
    end
  end)
end

-- Navigate with wrapping to adjacent sessions
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
        vim.cmd('wincmd $')
      end
    elseif dir == 'l' then
      -- Go to next session, focus first window
      local tab_count = vim.fn.tabpagenr('$')
      if tab_count > 1 then
        vim.cmd('tabnext')
        vim.cmd('wincmd t')
      end
    end
  end
end

-- Smart split: open new terminal when splitting from a terminal
local function smart_split(direction)
  local cmd = direction == 'v' and 'vsplit' or 'split'
  if vim.bo.buftype == 'terminal' then
    local cwd = terminal.get_cwd()
    vim.cmd(cmd)
    terminal.open(cwd)
    vim.cmd('startinsert')
  else
    vim.cmd(cmd)
  end
end

-- Close pane with confirmation if running process
local function close_pane()
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Check if terminal has a running process
  if terminal.has_running_process(bufnr) then
    local info = terminal.get_info(bufnr)
    local proc = info and info.proc or 'process'
    local confirm = vim.fn.confirm('Kill "' .. proc .. '"?', '&Yes\n&No', 2)
    if confirm ~= 1 then return end
  end

  local win_count = vim.fn.winnr('$')
  local tab_count = vim.fn.tabpagenr('$')
  if win_count == 1 and tab_count == 1 then
    vim.cmd('qa')
  else
    vim.cmd('close')
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

    -- Resize
    local resize = config.options.resize
    vim.keymap.set(mode, '<A-H>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      vim.cmd('vertical resize -' .. resize.vertical)
      enter_terminal_if_needed()
    end, { desc = 'Resize left' })
    
    vim.keymap.set(mode, '<A-J>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      vim.cmd('resize -' .. resize.horizontal)
      enter_terminal_if_needed()
    end, { desc = 'Resize down' })
    
    vim.keymap.set(mode, '<A-K>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      vim.cmd('resize +' .. resize.horizontal)
      enter_terminal_if_needed()
    end, { desc = 'Resize up' })
    
    vim.keymap.set(mode, '<A-L>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      vim.cmd('vertical resize +' .. resize.vertical)
      enter_terminal_if_needed()
    end, { desc = 'Resize right' })

    -- New panes
    vim.keymap.set(mode, '<A-n>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      local cwd = terminal.get_cwd()
      vim.cmd('vsplit')
      terminal.open(cwd)
      vim.schedule(function() vim.cmd('startinsert') end)
    end, { desc = 'New vertical pane' })
    
    vim.keymap.set(mode, '<A-N>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      local cwd = terminal.get_cwd()
      vim.cmd('split')
      terminal.open(cwd)
      vim.schedule(function() vim.cmd('startinsert') end)
    end, { desc = 'New horizontal pane' })

    -- Close pane
    vim.keymap.set(mode, '<A-x>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      close_pane()
    end, { desc = 'Close pane' })

    -- Session management
    vim.keymap.set(mode, '<A-c>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      local cwd = terminal.get_cwd()
      vim.cmd('tabnew')
      session.get_name()
      terminal.open(cwd)
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
        if name then session.set_name(name) end
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

    -- Session picker
    vim.keymap.set(mode, '<A-s>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      ui.show_session_picker(function(tabnr)
        vim.cmd('tabnext ' .. tabnr)
        enter_terminal_if_needed()
      end)
    end, { desc = 'Pick session' })

    -- Focused mode
    vim.keymap.set(mode, '<A-f>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      focus.toggle()
      enter_terminal_if_needed()
    end, { desc = 'Toggle focused mode' })

    -- Help
    vim.keymap.set(mode, '<A-/>', function()
      if mode == 't' then vim.cmd('stopinsert') end
      ui.show_help()
    end, { desc = 'Show help' })
  end
end

return M
