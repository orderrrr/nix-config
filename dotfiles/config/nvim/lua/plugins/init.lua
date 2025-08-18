local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"
local files = vim.fn.readdir(plugins_dir)

for _, file in ipairs(files) do
    if file:match("%.lua$") and file ~= "init.lua" then
        local module_name = file:gsub("%.lua$", "")
        require("plugins." .. module_name)
    end
end
