-- Main multiplexer module
local M = {}

-- Expose state manager for external access to events and state
M.state = require('multiplexer.state')

function M.setup(opts)
  -- Load configuration
  local config = require('multiplexer.config')
  config.setup(opts or {})

  -- Setup plugins
  vim.pack.add({
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/thesimonho/kanagawa-paper.nvim',
  })

  -- Setup theme
  local theme_opts = config.options.theme
  require('kanagawa-paper').setup({ transparent = theme_opts.transparent })
  vim.cmd.colorscheme(theme_opts.name)
  vim.cmd('hi statusline guibg=NONE')

  -- Apply editor options
  local editor = config.options.editor
  for key, value in pairs(editor) do
    vim.o[key] = value
  end

  -- Initialize modules
  local session = require('multiplexer.session')
  local terminal = require('multiplexer.terminal')
  local statusline = require('multiplexer.statusline')
  local keymaps = require('multiplexer.keymaps')
  local focus = require('multiplexer.focus')

  session.init()
  focus.setup() -- Setup focus mode autocmds (TabLeave safety net)
  statusline.setup()
  keymaps.setup()
  terminal.setup_cache_autocmds() -- Setup terminal cwd cache for faster pane creation

  -- Create user commands
  vim.api.nvim_create_user_command('SessionName', function(cmd_opts)
    session.set_name(cmd_opts.args)
  end, { nargs = 1 })

  -- Debug command to inspect state
  vim.api.nvim_create_user_command('MuxState', function()
    local state = require('multiplexer.state')
    local dump = state.debug_dump()
    print(vim.inspect(dump))
  end, {})

  -- Open terminal on startup
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      session.get_name(1)
      terminal.open() -- terminal.open handles startinsert
    end,
  })
end

return M
