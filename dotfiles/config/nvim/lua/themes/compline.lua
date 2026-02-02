local M = {}

M.palette = {
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
}

function M.setup()
  local p = M.palette
  local set = vim.api.nvim_set_hl

  -- Basic UI
  set(0, 'Normal', { fg = p.fg, bg = "none" })
  set(0, 'NormalNC', { fg = p.fg, bg = p.bg })
  set(0, 'Cursor', { bg = p.skin })
  set(0, 'CursorLine', { bg = p.bg })
  set(0, 'CursorLineNr', { fg = p.base4, bold = true })
  set(0, 'LineNr', { fg = p.base5 })
  set(0, 'Visual', { fg = p.fg_alt, bg = p.bg_alt })
  set(0, 'Search', { fg = p.base5, bg = p.yellow })

  -- Syntax
  set(0, 'Comment', { fg = p.base4, italic = true })
  set(0, 'String', { fg = p.green })
  set(0, 'Function', { fg = p.cyan })
  set(0, 'Identifier', { fg = p.base8 })
  set(0, 'Keyword', { fg = p.teal })

  -- Diagnostics
  set(0, 'DiagnosticError', { fg = p.red })
  set(0, 'DiagnosticWarn', { fg = p.base4 })
  set(0, 'DiagnosticInfo', { fg = p.base3 })
  set(0, 'DiagnosticHint', { fg = p.base2 })

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
  set(0, "@comment", { fg = p.base4, italic = true })
  set(0, "@comment.documentation", { fg = p.base4, italic = true })
end

return M
