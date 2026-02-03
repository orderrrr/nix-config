-- Main multiplexer module
local M = {}

-- Expose state manager for external access to events and state
M.state = require('multiplexer.state')

function M.setup(opts)
  -- Load configuration
  local config = require('multiplexer.config')
  config.setup(opts or {})

  -- Setup shared plugins
  local base = require('base')
  vim.pack.add(base.shared_plugins)

  -- Setup base configuration (keybinds, theme, etc.)
  -- Note: This must be called BEFORE applying multiplexer-specific options
  -- because base.setup() sets some options (like signcolumn) that we want to override
  base.setup()

  -- Apply multiplexer-specific editor options AFTER base.setup()
  -- This ensures settings like signcolumn='no' and cmdheight=0 take precedence
  local editor = config.options.editor
  for key, value in pairs(editor) do
    vim.o[key] = value
  end

  -- Enable mouse move events for scroll-to-focus functionality
  vim.o.mousemoveevent = true
  -- Enable full mouse support so terminals handle scroll natively
  vim.o.mouse = 'a'

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

  -- Auto-enter terminal mode when entering a terminal window (mouse click, scroll, etc.)
  -- This ensures scrolling and input are passed to the terminal, not handled by nvim
  vim.api.nvim_create_autocmd('WinEnter', {
    callback = function()
      -- Use schedule to ensure buffer state is updated after window switch
      vim.schedule(function()
        local buftype = vim.bo.buftype
        if buftype == 'terminal' then
          -- Only enter insert mode if the terminal job is still running
          local job_id = vim.b.terminal_job_id
          if job_id and vim.fn.jobwait({ job_id }, 0)[1] == -1 then
            vim.cmd('startinsert')
          end
        end
      end)
    end,
  })

end

return M
