-- Statusline module
local config = require('multiplexer.config')
local session = require('multiplexer.session')
local terminal = require('multiplexer.terminal')
local focus = require('multiplexer.focus')

local M = {}

-- Mode configuration
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

-- Setup highlight groups
function M.setup_highlights()
  local set = vim.api.nvim_set_hl
  local colors = config.options.statusline
  
  -- Mode highlights
  set(0, 'MuxMode', vim.tbl_extend('force', colors.mode.normal, { bold = true }))
  set(0, 'MuxModeInsert', vim.tbl_extend('force', colors.mode.insert, { bold = true }))
  set(0, 'MuxModeTerminal', vim.tbl_extend('force', colors.mode.terminal, { bold = true }))

  -- Session highlights
  for i, color in ipairs(colors.session_colors) do
    set(0, 'MuxSession' .. i, { fg = color.dim, bg = 'NONE' })
    set(0, 'MuxSessionActive' .. i, { fg = color.active, bg = 'NONE', bold = true })
  end

  -- Focus mode highlights
  set(0, 'MuxFocus', { fg = colors.session_colors[1].dim, bg = 'NONE' })
  set(0, 'MuxFocusActive', { fg = colors.session_colors[1].active, bg = 'NONE', bold = true })
end

-- Get highlight group for session
local function get_session_hl(index, is_active)
  local color_count = #config.options.statusline.session_colors
  local color_idx = ((index - 1) % color_count) + 1
  if is_active then
    return 'MuxSessionActive' .. color_idx
  else
    return 'MuxSession' .. color_idx
  end
end

-- Render statusline
function M.render()
  local mode = vim.fn.mode()
  local cfg = mode_config[mode] or { text = '???', hl = 'MuxMode' }
  local tab_count = vim.fn.tabpagenr('$')
  local current_tab = vim.fn.tabpagenr()

  -- Left: mode indicator
  local left = '%#' .. cfg.hl .. '# ' .. cfg.text .. ' '

  -- Focus indicator (always present, before sessions)
  local focus_active = focus.is_active()
  local focus_hl = focus_active and 'MuxFocusActive' or 'MuxFocus'
  local focus_str = focus_active 
    and '%#' .. focus_hl .. '# [f] ' 
    or '%#' .. focus_hl .. '#  f  '

  -- Middle: sessions (skip the focus tab if active, it's shown as 'f')
  local sessions_str = ''
  for i = 1, tab_count do
    -- When focus is active, first tab is the focus tab - skip it
    if not (focus_active and i == 1) then
      local name = session.get_name(i)
      local is_current = (i == current_tab) and not focus_active
      local hl = get_session_hl(i, is_current)
      if is_current then
        sessions_str = sessions_str .. '%#' .. hl .. '# [' .. name .. '] '
      else
        sessions_str = sessions_str .. '%#' .. hl .. '#  ' .. name .. '  '
      end
    end
  end

  -- Right: terminal info
  local right = ''
  local bufnr = vim.api.nvim_get_current_buf()
  local info = terminal.get_info(bufnr)
  if info and info.cwd ~= '' then
    right = '%#MuxSession1#%=' .. info.cwd
    if info.proc ~= '' then
      right = right .. ' %#MuxSessionActive1#' .. info.proc .. ' '
    end
  end

  return left .. focus_str .. sessions_str .. right
end

-- Initialize statusline
function M.setup()
  M.setup_highlights()
  
  -- Re-setup highlights on colorscheme change
  vim.api.nvim_create_autocmd('ColorScheme', { 
    callback = M.setup_highlights 
  })
  
  -- Set statusline to use our render function
  _G.mux_statusline = M.render
  vim.o.statusline = '%{%v:lua.mux_statusline()%}'
end

return M
