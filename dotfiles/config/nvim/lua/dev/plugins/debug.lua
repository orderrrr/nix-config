require("dapui").setup()

vim.keymap.set('n', '<leader>do', require('dapui').toggle)
vim.keymap.set('n', '<leader>dt', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<leader>dn', require('dap').continue)

local dap = require('dap')

-- Resolve the codelldb adapter installed by mason
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
local codelldb_path = mason_path .. "adapter/codelldb"

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = codelldb_path,
		args = { "--port", "${port}" },
	},
}

local function zig_default_program()
  local bin_dir = vim.fn.getcwd() .. "/zig-out/bin"
  local progs = vim.fn.glob(bin_dir .. "/*", 0, 1)
  if #progs == 1 then
    return progs[1]
  end
  return vim.fn.input("Path to executable: ", bin_dir .. "/", "file")
end

dap.configurations.zig = {
  {
    name = "Launch (CodeLLDB)",
    type = "codelldb",
    request = "launch",
    program = zig_default_program,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
    runInTerminal = false, -- set true if you need interactive stdin
  },
}
