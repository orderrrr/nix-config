-- IDE/Dev mode setup - just requires compartmentalized config files

-- Load shared plugins first (required by base.setup())
local base = require('base')
vim.pack.add(base.shared_plugins)

-- Now setup base configuration
base.setup()

-- Load dev-specific modules
require('dev.globals')
require('dev.filetype')
require('dev.keybinds')
require('dev.plugins')
