local config = function()
  -- [[ Configure Telescope ]]
  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    defaults = {
      layout_config = {
        vertical = { width = 0.5 }
      },
      mappings = {
        i = {
          ['<C-u>'] = false,
          ['<C-d>'] = false,
        },
      },
    },
    pickers = {},
    extensions = {
      fzf = {},
      ["ui-select"] = {},
    }
  }


  local ivy = require('telescope.themes').get_ivy({})

  -- Enable telescope fzf native, if installed
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('lsp_handlers')
  require('telescope').load_extension('ui-select')

  -- See `:help telescope.builtin`
  vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').oldfiles(ivy) end,
    { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', function() require('telescope.builtin').buffers(ivy) end,
    { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>b', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })
  vim.keymap.set('n', '<leader>gf', function() require('telescope.builtin').git_files(ivy) end,
    { desc = 'Search [G]it [F]iles' })
  vim.keymap.set('n', '<leader>sf', function() require('telescope.builtin').find_files(ivy) end,
    { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', function() require('telescope.builtin').help_tags(ivy) end,
    { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', function() require('telescope.builtin').grep_string(ivy) end,
    { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', function() require('telescope.builtin').live_grep(ivy) end,
    { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').diagnostics(ivy) end,
    { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', "<leader>lD", function() require("telescope.builtin").diagnostics(ivy) end,
    { desc = "List diagnostics" })
  vim.keymap.set('n', "<leader>lDD",
    function() require("telescope.builtin").diagnostics(require('telescope.themes').get_ivy({ severity = "ERROR" })) end,
    { desc = "List errors" })
end

return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'gbrlsnchs/telescope-lsp-handlers.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  config = config
}
--
-- vim: ts=2 sts=2 sw=2 et
