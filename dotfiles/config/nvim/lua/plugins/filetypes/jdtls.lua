local java_cmds = vim.api.nvim_create_augroup('java_cmds', { clear = true })
local cache_vars = {}

local root_files = {
    '.git',
    'mvnw',
    'gradlew',
    'pom.xml',
    'build.gradle',
}

local features = {
    -- change this to `true` to enable codelens
    codelens = false,

    -- change this to `true` if you have `nvim-dap`,
    -- `java-test` and `java-debug-adapter` installed
    debugger = true,
}

local function get_jdtls_paths()
    if cache_vars.paths then
        return cache_vars.paths
    end

    local path = {}

    path.data_dir = vim.fn.stdpath 'cache' .. '/nvim-jdtls'

    local home = os.getenv 'HOME'
    local jdtls_install = home .. "/.local/share/nvim/mason/packages/jdtls/";

    path.java_agent = jdtls_install .. '/lombok.jar'
    path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

    if vim.fn.has 'mac' == 1 then
        path.platform_config = jdtls_install .. '/config_mac'
    elseif vim.fn.has 'unix' == 1 then
        path.platform_config = jdtls_install .. '/config_linux'
    elseif vim.fn.has 'win32' == 1 then
        path.platform_config = jdtls_install .. '/config_win'
    end

    path.bundles = {}

    ---
    -- Include java-test bundle if present
    ---
    local java_test_path = home .. "/.local/share/nvim/mason/packages/java-test/";

    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar'), '\n')

    if java_test_bundle[1] ~= '' then
        vim.list_extend(path.bundles, java_test_bundle)
    end

    ---
    -- Include java-debug-adapter bundle if present
    ---
    local java_debug_path = home .. "/.local/share/nvim/mason/packages/java-debug-adapter/";

    local java_debug_bundle = vim.split(
        vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n')

    if java_debug_bundle[1] ~= '' then
        vim.list_extend(path.bundles, java_debug_bundle)
    end

    ---
    -- Include vscode-java-decompiler bundle if present
    ---
    local vscode_java_decompiler = home .. "/.local/share/nvim/mason/packages/vscode-java-decompiler/";

    local vscode_java_decompiler_bundle = vim.split(
        vim.fn.glob(vscode_java_decompiler .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'), '\n')

    if vscode_java_decompiler_bundle[1] ~= '' then
        vim.list_extend(path.bundles, vscode_java_decompiler_bundle)
    end


    ---
    -- Useful if you're starting jdtls with a Java version that's
    -- different from the one the project uses.
    ---
    path.runtimes = {
        {
            name = 'JavaSE-21',
            path = '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home/',
        },
        -- {
        --     name = 'JavaSE-24',
        --     path = '/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home/',
        -- },
        {
            name = 'JavaSE-1.8',
            path = '/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home',
        },
    }

    cache_vars.paths = path

    return path
end

local function enable_codelens(bufnr)
    pcall(vim.lsp.codelens.refresh)

    vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        group = java_cmds,
        desc = 'refresh codelens',
        callback = function()
            pcall(vim.lsp.codelens.refresh)
        end,
    })
end

local function enable_debugger(bufnr)
    require('jdtls').setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()

    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<leader>df', function() require('jdtls').test_class({ config = { console = 'console' } }) end,
        opts)
    vim.keymap.set('n', '<leader>dn',
        function() require('jdtls').test_nearest_method({ config = { console = 'console' } }) end, opts)
end

local function jdtls_on_attach(_, bufnr)
    if features.debugger then
        enable_debugger(bufnr)
    end

    if features.codelens then
        enable_codelens(bufnr)
    end

    -- The following mappings are based on the suggested usage of nvim-jdtls
    -- https://github.com/mfussenegger/nvim-jdtls#usage

    local opts = { buffer = bufnr }
    vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
    vim.keymap.set('n', 'crv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
    vim.keymap.set('x', 'crv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
    vim.keymap.set('n', 'crc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
    vim.keymap.set('x', 'crc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
    vim.keymap.set('x', 'crm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)
end

local function jdtls_setup(on_attach, capabilities)
    local jdtls = require 'jdtls'


    local path = get_jdtls_paths()
    local data_dir = path.data_dir .. '/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')


    if cache_vars.capabilities == nil then
        jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

        local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
        cache_vars.capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(),
            ok_cmp and cmp_lsp.default_capabilities() or {})
    end

    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    local cmd = {
        -- 💀
        'java',

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dtest=PostingCommonUtilsTest',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. path.java_agent,
        '-Xms4g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',

        -- 💀
        '-jar',
        path.launcher_jar,

        -- 💀
        '-configuration',
        path.platform_config,

        '--add-modules=ALL-SYSTEM',
        '--add-opens java.base/java.util=ALL-UNNAMED',
        '--add-opens java.base/java.lang=ALL-UNNAMED',
        -- 💀
        '-data',
        data_dir,
    }


    local home = os.getenv 'HOME'

    local lsp_settings = {
        java = {
            -- jdt = {
            --   ls = {
            --     vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m"
            --   }
            -- },
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = 'interactive',
                runtimes = {
                    {
                        name = 'JavaSE-21',
                        path = '/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home/',
                    },
                    -- {
                    --     name = 'JavaSE-24',
                    --     path = '/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home/',
                    -- },
                    {
                        name = 'JavaSE-1.8',
                        path = '/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home',
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            -- inlayHints = {
            --   parameterNames = {
            --     enabled = 'all' -- literals, all, none
            --   }
            -- },
            format = {
                enabled = true,
                settings = {
                    url = home .. '/.m2/VeritranE.xml',
                },
            },
        },
        signatureHelp = {
            enabled = true,
        },
        contentProvider = {
            preferred = 'fernflower',
        },
        extendedClientCapabilities = jdtls.extendedClientCapabilities,
        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
            },
        },
        codeGeneration = {
            toString = {
                template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            },
            useBlocks = true,
        },
    }

    local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    jdtls.start_or_attach({
        cmd = cmd,
        settings = lsp_settings,
        on_attach = function(unknown, bufnr)
            on_attach(unknown, bufnr)
            jdtls_on_attach(unknown, bufnr)
        end,
        -- on_attach = on_attach,
        capabilities = vim.tbl_deep_extend('force', cache_vars.capabilities, capabilities),
        -- capabilities = vim.tbl_deep_extend('force', cache_vars.capabilities, capabilities),
        root_dir = jdtls.setup.find_root(root_files),
        flags = {
            allow_incremental_sync = true,
        },
        init_options = {
            bundles = path.bundles,
            extendedClientCapabilities = extendedClientCapabilities,
        },
    })
end

local jdtls_autocmd = function(on_attach, capabilities)
    vim.api.nvim_create_autocmd('FileType', {
        group = java_cmds,
        pattern = 'java',
        desc = 'Setup jdtls',
        callback = function()
            jdtls_setup(on_attach, capabilities)
        end,
    })
end

return jdtls_autocmd
