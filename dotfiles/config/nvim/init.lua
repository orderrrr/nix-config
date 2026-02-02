-- Main entry point - routes to either dev (IDE) or multiplexer mode based on env var
local mode = vim.env.NVIM_MODE or "dev"

if mode == "multiplexer" then
  require('multiplexer').setup()
else
  require('dev')
end
