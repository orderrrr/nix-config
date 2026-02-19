local pf = require('dev.util').pf

vim.g.opencode_opts = {}

-- Required for `vim.g.opencode_opts.auto_reload`.
vim.o.autoread = true

local opencode = require("opencode")

local function ask()
  opencode.ask("@this: ", { submit = true })
end

local function ask_diagnostics()
  opencode.ask("@this, @diagnostics: ", { submit = true })
end

local function add()
  opencode.prompt("@this")
end

local function new() opencode.command("session_new") end
local function interrupt() opencode.command("session_interrupt") end
local function command(cmd) return function() opencode.command(cmd) end end

vim.keymap.set({ "n", "x" }, "<leader>oa", ask, { desc = "Ask about this" })
vim.keymap.set({ "n", "x" }, "<leader>os", opencode.select, { desc = "Select prompt" })
vim.keymap.set({ "n", "x" }, "<leader>o+", add, { desc = "Add this" })
vim.keymap.set({ "n", "x" }, "<leader>od", ask_diagnostics, { desc = "Ask about this with diagnostics" })
vim.keymap.set("n", "<leader>ot", opencode.toggle, { desc = "Toggle embedded" })
vim.keymap.set("n", "<leader>oc", opencode.command, { desc = "Select command" })
vim.keymap.set("n", "<leader>on", new, { desc = "New session" })
vim.keymap.set("n", "<leader>oi", interrupt, { desc = "Interrupt session" })
vim.keymap.set("n", "<leader>oA", command("agent_cycle"), { desc = "Cycle selected agent" })
vim.keymap.set("n", "<S-C-u>", command("messages_half_page_up"), { desc = "Messages half page up" })
vim.keymap.set("n", "<S-C-d>", command("messages_half_page_down"), { desc = "Messages half page down" })

local _99 = require("99")

local cwd = vim.uv.cwd()
local basename = vim.fs.basename(cwd)

_99.setup({
  provider = _99.Providers.ClaudeCodeProvider,
  model = "claude-sonnet-4-6",
  -- model = "opencode/minimax-m2.5",
  show_in_flight_requests = true,
  logger = {
    level = _99.DEBUG,
    path = "/tmp/" .. basename .. ".99.debug",
    print_on_error = true,
  },
  tmp_dir = "./tmp",
  completion = {
    custom_rules = {}, -- "scratch/custom_rules/"
    source = "blink",
  },
  md_files = {
    "AGENT.md",
  },
})

local Worker = _99.Extensions.Worker
vim.keymap.set("v", "<leader>9v", function() _99.visual() end)
vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end)
vim.keymap.set("n", "<leader>9s", function() _99.search() end)
vim.keymap.set("n", "<leader>9w", function() Worker.set_work() end)
vim.keymap.set("n", "<leader>9W", function() Worker.work() end)
vim.keymap.set("n", "<leader>9r", function() Worker.last_search_results() end)
