-- Configuration module
local M = {}

-- Default configuration
M.defaults = {
  -- Theme settings
  theme = {
    name = 'kanagawa-paper',
    transparent = false,
  },

  -- Editor settings
  editor = {
    number = false,
    relativenumber = false,
    signcolumn = 'no',
    scrolloff = 5,
    laststatus = 3,
    showtabline = 0,
    showmode = false,
    cmdheight = 0,
  },

  -- Session name settings
  session = {
    name_length = 4,
  },

  -- Terminal info cache settings
  terminal = {
    cache_ttl = 2000, -- milliseconds
  },

  -- Resize increment
  resize = {
    horizontal = 3,
    vertical = 3,
  },

  -- Focus mode settings
  focus = {
    debug = false, -- Enable debug logging for focus mode operations
  },

  -- Statusline colors
  statusline = {
    mode = {
      normal = { fg = '#1a1d21', bg = '#b8c4b8' },
      insert = { fg = '#1a1d21', bg = '#DBCDB3' },
      terminal = { fg = '#1a1d21', bg = '#b4bcc4' },
    },
    session_colors = {
      { active = '#b8c4b8', dim = '#5a6258' }, -- green
      { active = '#DBCDB3', dim = '#6d6558' }, -- yellow
      { active = '#b4bcc4', dim = '#5a5e62' }, -- blue
      { active = '#c0b8bc', dim = '#605c5e' }, -- magenta
      { active = '#b0bcc8', dim = '#585e64' }, -- cyan
      { active = '#CDACAC', dim = '#665656' }, -- red
    },
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', M.options, opts or {})
end

return M
