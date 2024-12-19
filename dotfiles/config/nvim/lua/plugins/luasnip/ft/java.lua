local ls = require "luasnip"
local ts = require "vim.treesitter"
local q = vim.treesitter.query

local callbacks = require("plugins.luasnip.util").callbacks

-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local d = ls.dynamic_node

local function var(_, snip)
    local capture = snip.captures[1]
    local pos = snip.env.POS

    vim.api.nvim_buf_set_text(0, pos[1], pos[2], pos[1], pos[2], { capture })

    local bufnr = vim.api.nvim_get_current_buf()
    local languagle_tree = ts.get_parser(bufnr, "java")
    local syntax_tree = languagle_tree:parse()
    local root = syntax_tree[1]:root()

    local query = q.parse("java", "(type_identifier) @object")
    local cursor = vim.api.nvim_win_get_cursor(0)[1]

    local type = ""
    for _, captures, _ in query:iter_matches(root, bufnr, cursor - 1, cursor + 1) do
        type = ts.get_node_text(captures[1], bufnr)
    end

    if type == "" then
        local test = vim.lsp.get_active_clients()
        if test == nil or test == {} then return sn(nil, {}) end

        -- TODO MORE TESTING

        local result =
            vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", require("vim.lsp.util").make_position_params())

        ---@diagnostic disable-next-line: param-type-mismatch
        local label = vim.tbl_get(result, #result, "result", "signatures", 1, "label")

        if label ~= nil then type = label:match ": (.*)" end
    end

    if type == "" then return sn(nil, {}) end

    vim.api.nvim_buf_set_text(0, pos[1], pos[2], pos[1], pos[2] + #capture, { "" })

    return sn(nil, {
        t(type .. " "),
        i(1, "var"),
        t(" = " .. capture .. ";"),
    })
end

ls.add_snippets("java", {
    s({ trig = "(%S.*).var", regTrig = true }, (d(1, var, {}, {})), {
        callbacks = callbacks,
    }),

    s({ trig = "if", regTrig = true }, {
        t "if (",
        i(1, "cond"),
        t({ ") {", "\t" }),
        i(0),
        t({ "", "}" })
    }),
})
