local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end

    return false
end

vim.api.nvim_create_autocmd({ "FileType" }, {
    callback = function()
    end
})
