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
                base01 = '#c2c2c2', -- Slightly darker highlight
                base02 = '#b4b4b4', -- Muted selection background
                base03 = '#929292', -- Comments
                base04 = '#727272', -- Medium gray foreground
                base05 = '#474747', -- Main text
                base06 = '#373737', -- Darker foreground
                base07 = '#272727', -- Darkest foreground
                base08 = '#837878', -- Extremely desaturated rose
                base09 = '#838078', -- Extremely desaturated tan
                base0A = '#878580', -- Extremely desaturated taupe
                base0B = '#788078', -- Extremely desaturated sage
                base0C = '#788285', -- Extremely desaturated steel blue
                base0D = '#797f83', -- Extremely desaturated slate blue
                base0E = '#827e85', -- Extremely desaturated mauve
                base0F = '#807c78', -- Extremely desaturated taupe
            }
        })
    end,
}
