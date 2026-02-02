-- Shared constants for the multiplexer module
local M = {}

-- Pre-computed shell lookup table (faster than table iteration)
M.SHELLS = {
  zsh = true, bash = true, fish = true, sh = true, dash = true,
  ksh = true, tcsh = true, csh = true,
}

return M
