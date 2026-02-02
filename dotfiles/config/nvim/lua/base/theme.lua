-- Shared theme setup for both dev and multiplexer modes
local M = {}

function M.setup()
  -- Auto-dark-mode configuration
  require("auto-dark-mode").setup({
    set_dark_mode = function()
      vim.cmd.colorscheme("compline")
    end,
    set_light_mode = function()
      vim.cmd.colorscheme("compline-light")
    end,
    fallback = "dark"
  })

  -- Transparent statusline background
  vim.cmd('hi statusline guibg=NONE')
end

return M
