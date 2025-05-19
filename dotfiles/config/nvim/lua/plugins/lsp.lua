return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim',          config = true },
      { 'williamboman/mason-lspconfig.nvim' },
      -- Detect tabstop and shiftwidth automatically
      { 'tpope/vim-sleuth' },
      { 'rcarriga/nvim-notify',             opts = {} },
      -- {
      --   'alnav3/sonarlint.nvim',
      --   lazy = true,
      --   ft = { "java" },
      --   config = function()
      --     require('sonarlint').setup({
      --       server = {
      --         cmd = {
      --           'sonarlint-language-server',
      --           -- Ensure that sonarlint-language-server uses stdio channel
      --           '-stdio',
      --           '-analyzers',
      --           -- paths to the analyzers you need, using those for python and java in this example
      --           vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
      --           vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
      --           vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
      --         }
      --       },
      --       filetypes = {
      --         -- Tested and working
      --         'python',
      --         'cpp',
      --         'java',
      --       }
      --     })
      --   end
      -- },
      {
        "aznhe21/actions-preview.nvim",
        config = function()
          vim.keymap.set({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions)
        end,
      },
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              winblend = 0, -- note: not winblend!
              relative = "editor"
            }
          }
        }
      },
      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      local function extend_tbl(default, opts)
        opts = opts or {}
        return default and vim.tbl_deep_extend("force", default, opts) or opts
      end

      -- [[ Configure LSP ]]
      --  This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end

          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            local opts = {
              focusable = false,
              close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
              border = 'rounded',
              source = 'always',
              prefix = ' ',
              scope = 'cursor',
            }
            vim.diagnostic.open_float(nil, opts)
          end
        })

        local ivy = require('telescope.themes').get_ivy({})

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        -- nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('tr', function() require('telescope.builtin').resume() end, '[T]elescope [R]esume')

        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        nmap('gr', function() require('telescope.builtin').lsp_references(ivy) end, '[G]oto [R]eferences')
        nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
        nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
        nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols(ivy) end, '[D]ocument [S]ymbols')
        nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols(ivy) end,
          '[W]orkspace [S]ymbols')

        nmap('<leader>jf', function()
          if vim.bo.filetype == 'java' then
            require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy({ symbols = 'method' }))
          else
            require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_ivy({ symbols = 'function' }))
          end
        end, '[J]ump to [F]unction')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
      end

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. They will be passed to
      --  the `settings` field of the server config. You must look up that documentation yourself.
      --
      --  If you want to override the default filetypes that your language server will attach to you can
      --  define the property 'filetypes' to the map in question.
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- tsserver = {},
        -- html = { filetypes = { 'html', 'twig', 'hbs'} },

        -- glslls = {},
        zls = {},

        jsonls = {},
        sqlls = {},
        cssls = {},
        -- pyright = {},
        pylsp = {},
        lemminx = {},
        html = {},
        svelte = {},
        rust_analyzer = {},
        wgsl_analyzer = {},
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      -- Setup neovim lua configuration
      require('neodev').setup()
      require("mason").setup()

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

      local nerd_font = {
        ActiveLSP = "",
        ActiveTS = "",
        ArrowLeft = "",
        ArrowRight = "",
        Bookmarks = "",
        BufferClose = "󰅖",
        DapBreakpoint = "",
        DapBreakpointCondition = "",
        DapBreakpointRejected = "",
        DapLogPoint = ".>",
        DapStopped = "󰁕",
        Debugger = "",
        DefaultFile = "󰈙",
        Diagnostic = "󰒡",
        DiagnosticError = "",
        DiagnosticHint = "󰌵",
        DiagnosticInfo = "󰋼",
        DiagnosticWarn = "",
        Ellipsis = "…",
        FileNew = "",
        FileModified = "",
        FileReadOnly = "",
        FoldClosed = "",
        FoldOpened = "",
        FoldSeparator = " ",
        FolderClosed = "",
        FolderEmpty = "",
        FolderOpen = "",
        Git = "󰊢",
        GitAdd = "",
        GitBranch = "",
        GitChange = "",
        GitConflict = "",
        GitDelete = "",
        GitIgnored = "◌",
        GitRenamed = "➜",
        GitSign = "▎",
        GitStaged = "✓",
        GitUnstaged = "✗",
        GitUntracked = "★",
        LSPLoaded = "", -- TODO: Remove unused icon in AstroNvim v4
        LSPLoading1 = "",
        LSPLoading2 = "󰀚",
        LSPLoading3 = "",
        MacroRecording = "",
        Package = "󰏖",
        Paste = "󰅌",
        Refresh = "",
        Search = "",
        Selected = "❯",
        Session = "󱂬",
        Sort = "󰒺",
        Spellcheck = "󰓆",
        Tab = "󰓩",
        TabClose = "󰅙",
        Terminal = "",
        Window = "",
        WordFile = "󰈭",
      }

      -- [LSPCONFIG]
      local function get_icon(kind, padding)
        local icon = nerd_font[kind]
        return icon and icon .. string.rep(" ", padding or 0) or ""
      end
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = get_icon("DiagnosticError"),
            [vim.diagnostic.severity.WARN]  = get_icon("DiagnosticWarn"),
            [vim.diagnostic.severity.INFO]  = get_icon("DiagnosticInfo"),
            [vim.diagnostic.severity.HINT]  = get_icon("DiagnosticHint"),
          },
          texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
          },
        }
      })

      for _, sign in ipairs {
        { name = "DapStopped",             text = get_icon("DapStopped"),             texthl = "DiagnosticWarn" },
        { name = "DapBreakpoint",          text = get_icon("DapBreakpoint"),          texthl = "DiagnosticInfo" },
        { name = "DapBreakpointRejected",  text = get_icon("DapBreakpointRejected"),  texthl = "DiagnosticError" },
        { name = "DapBreakpointCondition", text = get_icon("DapBreakpointCondition"), texthl = "DiagnosticInfo" },
        { name = "DapLogPoint",            text = get_icon("DapLogPoint"),            texthl = "DiagnosticInfo" },
      } do
        vim.fn.sign_define(sign.name, sign)
      end

      local default_diagnostics = {
        virtual_text = true,
        signs = { active = signs },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focused = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      }
      local diagnostics = {
        -- diagnostics off
        [0] = extend_tbl(
          default_diagnostics,
          { underline = false, virtual_text = false, signs = false, update_in_insert = false }
        ),
        -- status only
        extend_tbl(default_diagnostics, { virtual_text = false, signs = false }),
        -- virtual text off, signs on
        extend_tbl(default_diagnostics, { virtual_text = false }),
        -- all diagnostics on
        default_diagnostics,
      }

      vim.diagnostic.config({
        diagnostics = diagnostics[vim.g.diagnostics_mode],
        virtual_text = false,
        signs = { active = signs },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = true,
          header = '',
          prefix = '',
        },
      })

      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = {
          exclude = { "jdtls" }
        }
      }

      require('lspconfig').fennel_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        handlers = vim.lsp.handlers,
      })

      require 'lspconfig'.futhark_lsp.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        handlers = vim.lsp.handlers,
        filetypes = { "fut" },
      }

      require("flutter-tools").setup({
        lsp = {
          color = { -- show the derived colours for dart variables
            enabled = true, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
            background = false, -- highlight the background
            background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
            foreground = false, -- highlight the foreground
            virtual_text = true, -- show the highlight using virtual text
            virtual_text_str = "■", -- the virtual text character to highlight
          },
          on_attach = on_attach,
          capabilities = function(config)
            return vim.tbl_deep_extend(
              'force',
              config,
              capabilities
            )
          end,
        }
      })

      require("lspconfig").clangd.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--offset-encoding=utf-16",
        },
      }

      require('plugins.filetypes.sql')
      require('plugins.filetypes.jdtls')(on_attach, capabilities)
      require('plugins.filetypes.hlsl')

      vim.api.nvim_exec_autocmds("FileType", {})
    end

  },
  -- Useful status updates for LSP
  -- FIXME(not sure if needed)
  {
    'onsails/lspkind.nvim',
    opts = {
      mode = 'symbol',
      symbol_map = {
        Text = '󰉿',
        Method = '󰆧',
        Function = '󰊕',
        Constructor = '',
        Field = '󰜢',
        Variable = '󰀫',
        Class = '󰠱',
        Interface = '',
        Module = '',
        Property = '󰜢',
        Unit = '󰑭',
        Value = '󰎠',
        Enum = '',
        Keyword = '󰌋',
        Snippet = '',
        Color = '󰏘',
        File = '󰈙',
        Reference = '󰈇',
        Folder = '󰉋',
        EnumMember = '',
        Constant = '󰏿',
        Struct = '󰙅',
        Event = '',
        Operator = '󰆕',
        TypeParameter = '',
      },
      menu = {},
    },
    enabled = true,
    config = function(_, opts)
      require('lspkind').init(opts)
    end,
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  },
  { 'mfussenegger/nvim-jdtls' },
}
-- vim: ts=2 sts=2 sw=2 et
