local pf = require('util').pf

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
