return {
    'echasnovski/mini.nvim',
    version = false,
    lazy = false,
    config = function()
        require('mini.ai').setup()
        require('mini.statusline').setup()
        require('mini.base16').setup({
            palette = {
                base00 = '#d0d0d0', -- Background (same as white)
                base01 = '#c1c1c1', -- Slightly darker highlight
                base02 = '#b2b2b2', -- Muted selection background
                base03 = '#909090', -- Comments
                base04 = '#707070', -- Medium gray foreground
                base05 = '#454545', -- Main text
                base06 = '#353535', -- Darker foreground
                base07 = '#252525', -- Darkest foreground
                base08 = '#816b6e', -- Desaturated rose
                base09 = '#827b72', -- Muted tan
                base0A = '#878378', -- Soft taupe
                base0B = '#6c756a', -- Sage green
                base0C = '#718084', -- Muted steel blue
                base0D = '#667379', -- Slate blue
                base0E = '#837d87', -- Soft mauve
                base0F = '#756f6b', -- Muted taupe
            }
        })
    end,
}
