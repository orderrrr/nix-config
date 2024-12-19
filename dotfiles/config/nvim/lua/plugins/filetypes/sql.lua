local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end

    return false
end

vim.api.nvim_create_autocmd({ "FileType" }, {
    callback = function()
        local ftype = { "sql", "mysql", "plsql" }

        if has_value(ftype, vim.bo.filetype) then
            vim.schedule(
                function()
                    require("cmp").setup.buffer {
                        sources = {
                            { name = "copilot",  priority = 03000 },
                            { name = "cmp-dbee", priority = 02000 },
                            { name = "nvim_lsp", priority = 01000 },
                            { name = "luasnip",  priority = 00750 },
                            { name = "buffer",   priority = 00500 },
                            { name = "path",     priority = 00250 },
                        },
                    }
                end
            )
        end
    end,
})
