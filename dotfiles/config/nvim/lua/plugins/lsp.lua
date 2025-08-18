vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client ~= nil and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end
})

vim.cmd("set completeopt+=noselect")

vim.pack.add({
    require("util").pf("nvim-treesitter/nvim-treesitter"),
    require("util").pf("neovim/nvim-lspconfig"),
    require("util").pf("mason-org/mason.nvim"),
    require("util").pf("mason-org/mason-lspconfig.nvim"),
    require("util").pf("ziglang/zig.vim"),
})

require('nvim-treesitter.install').update({ with_sync = true })()

require("nvim-treesitter.configs").setup({
    modules = {},
    ignore_install = {},
    parser_install_dir = nil,
    ensure_installed = { "lua", "java", "zig" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true, },
    indent = { enable = true, },
});

local nvim_lsp = require('lspconfig')

nvim_lsp.lua_ls.setup({ settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } } });

require("mason").setup()
require("mason-lspconfig").setup {
    automatic_enable = { "lua_ls", "zls" }
}

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format);
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)

vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
