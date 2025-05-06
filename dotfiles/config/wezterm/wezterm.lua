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
-- config.color_scheme = 'Kanagawa (Gogh)'

config.colors = {
    foreground = "#c5c9c5",
    background = "#181616",

    cursor_bg = "#C8C093",
    cursor_fg = "#C8C093",
    cursor_border = "#C8C093",

    selection_fg = "#C8C093",
    selection_bg = "#2D4F67",

    scrollbar_thumb = "#16161D",
    split = "#16161D",

    ansi = {
        "#0D0C0C",
        "#C4746E",
        "#8A9A7B",
        "#C4B28A",
        "#8BA4B0",
        "#A292A3",
        "#8EA4A2",
        "#C8C093",
    },
    brights = {
        "#A6A69C",
        "#E46876",
        "#87A987",
        "#E6C384",
        "#7FB4CA",
        "#938AA9",
        "#7AA89F",
        "#C5C9C5",
    },
}

config.force_reverse_video_cursor = true

-- local colors, _ = wezterm.color.load_base16_scheme("/Users/nmcintosh/.config/wezterm/base_16.yaml"); -- TODO: don't hard code file path
-- config.colors = colors
--
-- config.colors.brights = {
--     "#6b4d54",  -- Darker version of "#816b6e" (dark red)
--     "#6b5a5c",  -- Darker version of "#827b72" (red)
--     "#5d6d5d",  -- Darker version of "#878378" (green)
--     "#5d7a6d",  -- Darker version of "#718084" (light green)
--     "#5d6d75",  -- Darker version of "#667379" (cyan)
--     "#6d5a6d",  -- Darker version of "#837d87" (blue)
--     "#6d5a5c",  -- Darker version of "#756f6b" (magenta)
--     "#9c9c9c"   -- Darker version of "#d0d0d0" (white)
-- }

-- and finally, return the configuration to wezterm
return config
