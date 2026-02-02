vim.pack.add({
  "https://github.com/supermaven-inc/supermaven-nvim",
  "https://github.com/NickvanDyke/opencode.nvim",

  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  'https://github.com/thesimonho/kanagawa-paper.nvim',
  'https://github.com/unblevable/quick-scope',
  'https://github.com/RRethy/vim-illuminate',
  'https://github.com/uga-rosa/ccc.nvim',

  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/playground',
  'https://github.com/nvim-treesitter/nvim-treesitter-context',

  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/gbrlsnchs/telescope-lsp-handlers.nvim",

  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/aznhe21/actions-preview.nvim',
  'https://github.com/madskjeldgaard/sclang-format.nvim',

  'https://github.com/ziglang/zig.vim',

  'https://github.com/mfussenegger/nvim-jdtls',

  "https://github.com/nvim-lua/plenary.nvim",
  'https://github.com/stevearc/dressing.nvim',
  "https://github.com/stevearc/oil.nvim",

  'https://github.com/aaronhallaert/advanced-git-search.nvim',
  'https://github.com/folke/snacks.nvim',

  'https://github.com/Saghen/blink.cmp',
  'https://github.com/Saghen/blink.compat',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/rafamadriz/friendly-snippets',

  'https://github.com/nvim-flutter/flutter-tools.nvim',

  'https://github.com/orderrrr/99',

  'https://github.com/f-person/auto-dark-mode.nvim',

  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})

local plugins_dir = vim.fn.stdpath("config") .. "/lua/dev/plugins"
local files = vim.fn.readdir(plugins_dir)

for _, file in ipairs(files) do
  if file:match("%.lua$") and file ~= "init.lua" then
    local module_name = file:gsub("%.lua$", "")
    require("dev.plugins." .. module_name)
  end
end
