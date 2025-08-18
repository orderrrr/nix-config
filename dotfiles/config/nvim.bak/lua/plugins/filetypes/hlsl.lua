vim.filetype.add({
    extension = {
        hlsl = "hlsl",
        slang = "shaderslang",
    },
})

-- if not configs.hlsl_tools then
--     local home = os.getenv 'HOME'
--
--     configs.hlsl_tools = {
--         default_config = {
--             cmd = { "/Users/nmcintosh/.vscode/extensions/timgjones.hlsltools-1.1.303/bin/osx-x64/ShaderTools.LanguageServer" },
--             root_dir = require("lspconfig").util.root_pattern(".git"),
--             filetypes = { "hlsl" },
--         }
--     }
-- end
