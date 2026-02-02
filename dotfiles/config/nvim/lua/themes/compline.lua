local M = {}

M.palettes = {
  dark = {
    bg        = "#1a1d21",
    bg_alt    = "#22262b",
    base0     = "#0f1114",
    base1     = "#171a1e",
    base2     = "#1f2228",
    base3     = "#282c34",
    base4     = "#3d424a",
    base5     = "#515761",
    base6     = "#676d77",
    base7     = "#8b919a",
    base8     = "#e0dcd4",
    fg        = "#f0efeb",
    fg_alt    = "#ccc4b4",

    grey      = "#3d424a",
    red       = "#CDACAC",
    orange    = "#ccc4b4",
    green     = "#b8c4b8",
    blue      = "#b4bcc4",
    yellow    = "#d4ccb4",
    violet    = "#8b919a",
    teal      = "#b4c4bc",
    dark_blue = "#9ca4ac",
    magenta   = "#8b919a",
    cyan      = "#b4c0c8",
    dark_cyan = "#98a4ac",
    skin      = '#DBCDB3',
    mauve     = '#c0b8bc',
  },
  light = {
    bg        = "#f0efeb",
    bg_alt    = "#e0dcd4",
    base0     = "#f5f4f2",
    base1     = "#efeeed",
    base2     = "#e5e3e0",
    base3     = "#d8d6d3",
    base4     = "#b8b5b0",
    base5     = "#9a9791",
    base6     = "#7d7a75",
    base7     = "#5f5c58",
    base8     = "#2d2a27",
    fg        = "#1a1d21",
    fg_alt    = "#4A4D51",

    grey      = "#b8b5b0",
    red       = "#8B6666",
    orange    = "#7A6D5A",
    green     = "#5A6B5A",
    blue      = "#5A6B7A",
    yellow    = "#8B7E52",
    violet    = "#7d7a75",
    teal      = "#4D6B6B",
    dark_blue = "#4A5A6A",
    magenta   = "#7d7a75",
    cyan      = "#4A5B66",
    dark_cyan = "#3D4E5A",
    skin      = "#5f5c58",
    mauve     = "#6A5A60",
  },
}

function M.setup(opts)
  opts = opts or {}
  local light_mode = opts.light_mode or false
  local transparent = opts.transparent_background
  if transparent == nil then transparent = true end

  local p = light_mode and M.palettes.light or M.palettes.dark
  local set = vim.api.nvim_set_hl

  local bg = transparent and "none" or p.bg
  local pmenu_bg = bg
  local pmenu_sel_bg = p.base3
  local pmenu_sbar_bg = transparent and "none" or p.base2
  local pmenu_thumb_bg = transparent and "none" or p.base4

  -- Basic UI
  set(0, 'Normal', { fg = p.fg, bg = bg })
  set(0, 'NormalNC', { fg = p.fg, bg = bg })
  set(0, 'Cursor', { bg = p.skin })
  set(0, 'CursorLine', { bg = light_mode and p.base2 or bg })
  set(0, 'CursorLineNr', { fg = light_mode and p.base8 or p.base4, bold = true })
  set(0, 'LineNr', { fg = light_mode and p.base5 or p.base5 })
  set(0, 'Visual', { fg = p.fg_alt, bg = p.bg_alt })
  set(0, 'Search', { fg = p.base5, bg = p.yellow })

  -- Floating windows & popups
  set(0, 'NormalFloat', { fg = p.fg, bg = bg })
  set(0, 'FloatBorder', { fg = p.base5, bg = bg })
  set(0, 'FloatTitle', { fg = p.fg_alt, bg = bg })
  set(0, 'Pmenu', { fg = p.fg, bg = pmenu_bg })
  set(0, 'PmenuSel', { fg = p.fg, bg = pmenu_sel_bg })
  set(0, 'PmenuSbar', { bg = pmenu_sbar_bg })
  set(0, 'PmenuThumb', { bg = pmenu_thumb_bg })

  -- Window chrome
  set(0, 'SignColumn', { fg = p.base4, bg = bg })
  set(0, 'FoldColumn', { fg = p.base4, bg = bg })
  set(0, 'VertSplit', { fg = p.base4, bg = bg })
  set(0, 'WinSeparator', { fg = p.base4, bg = bg })
  set(0, 'StatusLine', { fg = p.fg, bg = bg })
  set(0, 'StatusLineNC', { fg = p.base5, bg = bg })
  set(0, 'WinBar', { fg = p.fg, bg = bg })
  set(0, 'WinBarNC', { fg = p.base5, bg = bg })
  set(0, 'TabLine', { fg = p.base5, bg = bg })
  set(0, 'TabLineFill', { bg = bg })
  set(0, 'TabLineSel', { fg = p.fg, bg = bg, bold = true })
  set(0, 'EndOfBuffer', { fg = bg, bg = bg })
  set(0, 'NonText', { fg = p.base4 })
  set(0, 'SpecialKey', { fg = p.base4 })
  set(0, 'Folded', { fg = p.base5, bg = bg })
  set(0, 'ColorColumn', { bg = p.base1 })
  set(0, 'CursorColumn', { bg = p.base1 })

  -- Syntax
  set(0, 'Comment', { fg = light_mode and p.base6 or p.base4, italic = true })
  set(0, 'String', { fg = p.green })
  set(0, 'Function', { fg = p.cyan })
  set(0, 'Identifier', { fg = p.base8 })
  set(0, 'Keyword', { fg = p.teal })
  set(0, 'Operator', { fg = p.base6 })
  set(0, 'Type', { fg = p.blue })

  -- Messages
  set(0, 'MoreMsg', { fg = p.fg_alt })
  set(0, 'ModeMsg', { fg = p.fg_alt })
  set(0, 'WarningMsg', { fg = p.yellow })
  set(0, 'ErrorMsg', { fg = p.red })
  set(0, 'Question', { fg = p.fg_alt })

  -- Diagnostics
  set(0, 'DiagnosticError', { fg = p.red })
  set(0, 'DiagnosticWarn', { fg = light_mode and p.yellow or p.base4 })
  set(0, 'DiagnosticInfo', { fg = light_mode and p.green or p.base3 })
  set(0, 'DiagnosticHint', { fg = light_mode and p.base6 or p.base2 })

  -- Treesitter
  set(0, "@variable", { fg = p.base8 })
  set(0, "@variable.builtin", { fg = p.cyan })
  set(0, "@variable.parameter", { fg = p.base8 })
  set(0, "@variable.parameter.builtin", { fg = p.cyan })
  set(0, "@variable.member", { fg = p.cyan })
  set(0, "@constant", { fg = p.base7 })
  set(0, "@constant.builtin", { fg = p.cyan })
  set(0, "@constant.macro", { fg = p.cyan })
  set(0, "@module", { fg = p.red })
  set(0, "@module.builtin", { fg = p.red })
  set(0, "@label", { link = "Label" })
  set(0, "@string", { link = "String" })
  set(0, "@string.regexp", { fg = p.mauve })
  set(0, "@string.escape", { fg = p.mauve })
  set(0, "@string.special", { link = "String" })
  set(0, "@string.special.symbol", { link = "Identifier" })
  set(0, "@character", { link = "Character" })
  set(0, "@character.special", { link = "Character" })
  set(0, "@boolean", { link = "Boolean" })
  set(0, "@number", { link = "Number" })
  set(0, "@number.float", { link = "Number" })
  set(0, "@float", { link = "Number" })
  set(0, "@type", { fg = p.blue })
  set(0, "@type.builtin", { fg = p.dark_blue })
  set(0, "@attribute", { fg = p.blue })
  set(0, "@attribute.builtin", { fg = p.blue })
  set(0, "@property", { fg = p.blue })
  set(0, "@function", { fg = p.cyan })
  set(0, "@function.builtin", { fg = p.cyan })
  set(0, "@function.macro", { link = "Function" })
  set(0, "@function.method", { fg = p.dark_cyan })
  set(0, "@function.method.call", { fg = p.dark_cyan })
  set(0, "@constructor", { fg = p.dark_cyan })
  set(0, "@operator", { link = "Operator" })
  set(0, "@keyword", { link = "Keyword" })
  set(0, "@keyword.operator", { fg = p.base6 })
  set(0, "@keyword.import", { fg = p.teal })
  set(0, "@keyword.storage", { fg = p.teal })
  set(0, "@keyword.repeat", { fg = p.teal })
  set(0, "@keyword.return", { fg = p.teal })
  set(0, "@keyword.debug", { fg = p.teal })
  set(0, "@keyword.exception", { fg = p.teal })
  set(0, "@keyword.conditional", { fg = p.teal })
  set(0, "@keyword.conditional.ternary", { fg = p.teal })
  set(0, "@keyword.directive", { fg = p.teal })
  set(0, "@keyword.directive.define", { fg = p.teal })
  set(0, "@comment", { fg = light_mode and p.base6 or p.base4, italic = true })
  set(0, "@comment.documentation", { fg = light_mode and p.base6 or p.base4, italic = true })

  -- Filetypes
  set(0, "Directory", { fg = p.blue })

  -- Markdown
  set(0, "@markup.raw", { fg = p.base7 })
  set(0, "@markup.raw.markdown_inline", { fg = p.base7 })
  set(0, "markdownCode", { fg = p.base7 })
end

return M
