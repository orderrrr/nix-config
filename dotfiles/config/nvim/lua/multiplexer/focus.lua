-- Focused mode module (save/restore window layouts)
local state = require('multiplexer.state')

local M = {}

-- Convert window tree to buffer-based structure
local function tree_to_struct(tree, win_to_buf, current_win)
  if tree[1] == 'leaf' then
    local winid = tree[2]
    return {
      type = 'leaf',
      buffer = win_to_buf[winid],
      is_current = (winid == current_win),
    }
  else
    local children = {}
    for _, child in ipairs(tree[2]) do
      table.insert(children, tree_to_struct(child, win_to_buf, current_win))
    end
    return {
      type = tree[1], -- 'row' or 'col'
      children = children,
    }
  end
end

-- Extract all buffers from a layout structure
local function extract_buffers_from_struct(struct, result)
  result = result or {}
  if struct.type == 'leaf' then
    if struct.buffer then
      table.insert(result, { buf = struct.buffer, is_current = struct.is_current })
    end
  else
    for _, child in ipairs(struct.children) do
      extract_buffers_from_struct(child, result)
    end
  end
  return result
end

-- Save current window layout
local function save_layout(tabpage)
  local current_win = vim.api.nvim_get_current_win()
  local layout_tree = vim.fn.winlayout(vim.api.nvim_tabpage_get_number(tabpage))

  local win_to_buf = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    win_to_buf[win] = vim.api.nvim_win_get_buf(win)
  end

  local structure = tree_to_struct(layout_tree, win_to_buf, current_win)
  local buffers = extract_buffers_from_struct(structure)

  return {
    structure = structure,
    buffers = buffers, -- Now properly populated!
  }
end

-- Restore window tree from structure
local function restore_tree(struct, first_win)
  if struct.type == 'leaf' then
    vim.api.nvim_set_current_win(first_win)
    if struct.buffer and vim.api.nvim_buf_is_valid(struct.buffer) then
      vim.api.nvim_win_set_buf(first_win, struct.buffer)
    end
    return struct.is_current and first_win or nil
  else
    local target = nil

    -- Restore first child
    local child_target = restore_tree(struct.children[1], first_win)
    if child_target then target = child_target end

    -- Split for remaining children
    for i = 2, #struct.children do
      vim.api.nvim_set_current_win(first_win)

      if struct.type == 'col' then
        vim.cmd('vsplit')
      else
        vim.cmd('split')
      end

      local new_win = vim.api.nvim_get_current_win()
      child_target = restore_tree(struct.children[i], new_win)
      if child_target then target = child_target end
    end

    return target
  end
end

-- Restore layout from saved structure
local function restore_layout(saved)
  if not saved or not saved.structure then return end

  vim.cmd('only')

  local target = restore_tree(saved.structure, vim.api.nvim_get_current_win())

  vim.cmd('wincmd =')

  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
  end
end

-- Toggle focused mode for current tab
function M.toggle()
  local tabpage = vim.api.nvim_get_current_tabpage()

  if not state.is_focused(tabpage) then
    -- Enter focused mode
    local wins = vim.api.nvim_tabpage_list_wins(tabpage)
    if #wins == 1 then
      vim.notify('Already in single pane view', vim.log.levels.INFO)
      return
    end

    local layout = save_layout(tabpage)
    state.save_focused_layout(tabpage, layout)
    vim.cmd('only')
    vim.o.laststatus = 3
    vim.cmd('redrawstatus')
    vim.notify('Focused mode enabled', vim.log.levels.INFO)
  else
    -- Exit focused mode
    local saved_layout = state.clear_focused_layout(tabpage)

    restore_layout(saved_layout)

    vim.o.laststatus = 3
    vim.cmd('redrawstatus')
    vim.notify('Focused mode disabled', vim.log.levels.INFO)
  end
end

-- Check if tab is in focused mode
function M.is_focused(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()
  return state.is_focused(tabpage)
end

-- Get saved buffers for focused tab (for UI display)
function M.get_saved_buffers(tabpage)
  local layout = state.get_focused_layout(tabpage)
  if layout and layout.buffers then
    return layout.buffers
  end
  return nil
end

return M
