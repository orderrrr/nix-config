-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.enable_tab_bar = false
-- config.color_scheme = "Catppuccin Mocha" -- or Macchiato, Frappe, Latte
config.window_decorations = "RESIZE"
config.font_size = 18.0

config.window_background_opacity = 1.0
config.macos_window_background_blur = 999
config.force_reverse_video_cursor = true
-- config.color_scheme = "Catppuccin Mocha"

config.force_reverse_video_cursor = true

local colors, meta = wezterm.color.load_base16_scheme("/Users/nmcintosh/.config/wezterm/base_16.yaml"); -- TODO: don't hard code file path

config.colors = colors

-- and finally, return the configuration to wezterm
return config
