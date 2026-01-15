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
  local search_colors = config.options.search

  -- Search highlights (distinct from neovim default)
  set(0, 'Search', { fg = search_colors.fg, bg = search_colors.bg })
  set(0, 'IncSearch', { fg = search_colors.fg, bg = search_colors.bg, bold = true })
  set(0, 'CurSearch', { fg = search_colors.fg, bg = search_colors.bg, bold = true, underline = true })

  -- Mode highlights
  set(0, 'MuxMode', vim.tbl_extend('force', colors.mode.normal, { bold = true }))
  set(0, 'MuxModeInsert', vim.tbl_extend('force', colors.mode.insert, { bold = true }))
  set(0, 'MuxModeTerminal', vim.tbl_extend('force', colors.mode.terminal, { bold = true }))

  -- Session highlights (normal - transparent bg)
  for i, color in ipairs(colors.session_colors) do
    set(0, 'MuxSession' .. i, { fg = color.dim, bg = 'NONE' })
    set(0, 'MuxSessionActive' .. i, { fg = color.active, bg = 'NONE', bold = true })
  end

  -- Session highlights (non-terminal mode - with background)
  local non_term_bg = colors.non_terminal_bg
  for i, color in ipairs(colors.session_colors) do
    set(0, 'MuxSessionNT' .. i, { fg = color.dim, bg = non_term_bg })
    set(0, 'MuxSessionActiveNT' .. i, { fg = color.active, bg = non_term_bg, bold = true })
  end

  -- Focus mode highlights
  set(0, 'MuxFocus', { fg = colors.session_colors[1].dim, bg = 'NONE' })
  set(0, 'MuxFocusActive', { fg = colors.session_colors[1].active, bg = 'NONE', bold = true })
  set(0, 'MuxFocusNT', { fg = colors.session_colors[1].dim, bg = non_term_bg })
  set(0, 'MuxFocusActiveNT', { fg = colors.session_colors[1].active, bg = non_term_bg, bold = true })

  -- Non-terminal mode statusline fill
  set(0, 'MuxStatusNT', { bg = non_term_bg })
end

-- Get highlight group for session
local function get_session_hl(index, is_active, is_terminal_mode)
  local color_count = #config.options.statusline.session_colors
  local color_idx = ((index - 1) % color_count) + 1
  local suffix = is_terminal_mode and '' or 'NT'
  if is_active then
    return 'MuxSessionActive' .. suffix .. color_idx
  else
    return 'MuxSession' .. suffix .. color_idx
  end
end

-- Render statusline
function M.render()
  local mode = vim.fn.mode()
  local cfg = mode_config[mode] or { text = '???', hl = 'MuxMode' }
  local tab_count = vim.fn.tabpagenr('$')
  local current_tab = vim.fn.tabpagenr()
  local is_terminal_mode = (mode == 't')

  -- Left: mode indicator
  local left = '%#' .. cfg.hl .. '# ' .. cfg.text .. ' '

  -- Focus indicator (always present, before sessions)
  local focus_active = focus.is_active()
  local focus_hl_suffix = is_terminal_mode and '' or 'NT'
  local focus_hl = focus_active and ('MuxFocusActive' .. focus_hl_suffix) or ('MuxFocus' .. focus_hl_suffix)
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
      local hl = get_session_hl(i, is_current, is_terminal_mode)
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
  local right_hl_suffix = is_terminal_mode and '' or 'NT'
  if info and info.cwd ~= '' then
    right = '%#MuxSession' .. right_hl_suffix .. '1#%=' .. info.cwd
    if info.proc ~= '' then
      right = right .. ' %#MuxSessionActive' .. right_hl_suffix .. '1#' .. info.proc .. ' '
    end
  else
    -- Fill the rest with non-terminal background when not in terminal mode
    if not is_terminal_mode then
      right = '%#MuxStatusNT#%='
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
