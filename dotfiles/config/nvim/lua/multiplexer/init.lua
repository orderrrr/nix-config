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
  })

  -- Setup theme
  require("themes.compline").setup()
  vim.cmd('hi statusline guibg=NONE')

  -- Apply editor options
  local editor = config.options.editor
  for key, value in pairs(editor) do
    vim.o[key] = value
  end

  -- Enable mouse move events for scroll-to-focus functionality
  vim.o.mousemoveevent = true

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

  -- Focus window under mouse on scroll, then pass scroll to terminal if applicable
  local function focus_and_scroll(scroll_key)
    return function()
      local mouse_pos = vim.fn.getmousepos()
      local target_win = mouse_pos.winid

      if target_win and target_win ~= 0 and vim.api.nvim_win_is_valid(target_win) then
        local current_win = vim.api.nvim_get_current_win()

        if target_win ~= current_win then
          -- Switch to the target window
          vim.api.nvim_set_current_win(target_win)
        end

        -- Check if target is a terminal and enter terminal mode
        local bufnr = vim.api.nvim_win_get_buf(target_win)
        if vim.bo[bufnr].buftype == 'terminal' then
          local job_id = vim.b[bufnr].terminal_job_id
          if job_id and vim.fn.jobwait({ job_id }, 0)[1] == -1 then
            -- Enter terminal mode and send scroll to the terminal
            vim.cmd('startinsert')
            -- Send mouse wheel escape sequence (SGR encoding for smooth scrolling)
            -- Format: CSI < button ; x ; y M (press) / m (release)
            -- Button 64 = scroll up, 65 = scroll down
            local button = scroll_key == 'ScrollWheelUp' and 64 or 65
            local scroll_seq = string.format('\x1b[<%d;%d;%dM', button, mouse_pos.column, mouse_pos.line)
            vim.api.nvim_chan_send(job_id, scroll_seq)
            return
          end
        end
      end

      -- For non-terminal buffers, use default scroll behavior
      local count = vim.v.count1
      if scroll_key == 'ScrollWheelUp' then
        vim.cmd('normal! ' .. count .. '\\<C-y>')
      else
        vim.cmd('normal! ' .. count .. '\\<C-e>')
      end
    end
  end

  -- Map scroll events in all modes
  for _, mode in ipairs({ 'n', 'i', 't' }) do
    vim.keymap.set(mode, '<ScrollWheelUp>', focus_and_scroll('ScrollWheelUp'), { silent = true })
    vim.keymap.set(mode, '<ScrollWheelDown>', focus_and_scroll('ScrollWheelDown'), { silent = true })
  end
end

return M
