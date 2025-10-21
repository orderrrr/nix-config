local pf = require('util').pf

vim.pack.add({
    pf("nvim-lua/plenary.nvim"),
    pf("nvim-telescope/telescope-ui-select.nvim"),
    pf("gbrlsnchs/telescope-lsp-handlers.nvim"),
    pf('aaronhallaert/advanced-git-search.nvim'),
    pf("nvim-telescope/telescope.nvim"),
})

require('telescope').load_extension('lsp_handlers')
require('telescope').load_extension('ui-select')
require("telescope").load_extension("advanced_git_search")

require('telescope').setup({
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
        advanced_git_search = {},
        fzf = {},
        ["ui-select"] = {},
    }
})

local builtin = require('telescope.builtin')

local with_ivy = function(cmd, opts)
    local ivy = require('telescope.themes').get_ivy(opts)
    return function()
        cmd(ivy)
    end
end

local function buffers_and_files(opts)
    opts = opts or {}

    -- Get buffers first (same logic as builtin.buffers)
    local bufnrs = vim.tbl_filter(function(bufnr)
        if 1 ~= vim.fn.buflisted(bufnr) then
            return false
        end
        if opts.show_all_buffers == false and not vim.api.nvim_buf_is_loaded(bufnr) then
            return false
        end
        if opts.ignore_current_buffer and bufnr == vim.api.nvim_get_current_buf() then
            return false
        end
        return true
    end, vim.api.nvim_list_bufs())

    -- Create buffer entries
    local buffers = {}
    for i, bufnr in ipairs(bufnrs) do
        local flag = bufnr == vim.fn.bufnr "" and "%" or (bufnr == vim.fn.bufnr "#" and "#" or " ")
        local element = {
            bufnr = bufnr,
            flag = flag,
            info = vim.fn.getbufinfo(bufnr)[1],
            is_buffer = true,
        }
        table.insert(buffers, element)
    end

    -- Get find command for files
    local find_command = (function()
        if opts.find_command then
            if type(opts.find_command) == "function" then
                return opts.find_command(opts)
            end
            return opts.find_command
        elseif 1 == vim.fn.executable "rg" then
            return { "rg", "--files", "--color", "never" }
        elseif 1 == vim.fn.executable "fd" then
            return { "fd", "--type", "f", "--color", "never" }
        elseif 1 == vim.fn.executable "fdfind" then
            return { "fdfind", "--type", "f", "--color", "never" }
        elseif 1 == vim.fn.executable "find" and vim.fn.has "win32" == 0 then
            return { "find", ".", "-type", "f" }
        end
    end)()

    -- Custom entry maker that handles both buffers and files
    local entry_maker = function(entry)
        if entry.is_buffer then
            -- Use buffer entry maker logic
            local bufname = entry.info.name ~= "" and entry.info.name or "[No Name]"
            -- Show relative path for buffers too
            local display_name = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"
            local display = string.format("%s %s", entry.flag, display_name)

            return {
                value = entry,
                display = display,
                ordinal = display,
                bufnr = entry.bufnr,
                filename = bufname,
            }
        else
            -- Use file entry maker logic - show full relative path
            local path = entry
            local display = vim.fn.fnamemodify(path, ":~:.") -- Show relative path from cwd

            return {
                value = path,
                display = display,
                ordinal = display, -- Use full path for searching too
                filename = path,
                path = path,
            }
        end
    end

    -- Custom finder that combines buffers and files
    local finder = require('telescope.finders').new_dynamic({
        fn = function(prompt)
            local results = {}

            -- Always include buffers at the top
            for _, buffer in ipairs(buffers) do
                table.insert(results, buffer)
            end

            -- Add file results
            if find_command then
                local handle = io.popen(table.concat(find_command, " "))
                if handle then
                    for line in handle:lines() do
                        -- Skip files that are already open as buffers
                        local is_open_buffer = false
                        for _, buf in ipairs(buffers) do
                            if buf.info.name == vim.fn.fnamemodify(line, ":p") then
                                is_open_buffer = true
                                break
                            end
                        end

                        if not is_open_buffer then
                            table.insert(results, line)
                        end
                    end
                    handle:close()
                end
            end

            return results
        end,
        entry_maker = entry_maker,
    })

    require('telescope.pickers').new(opts, {
        prompt_title = "Buffers & Files",
        finder = finder,
        previewer = require('telescope.config').values.grep_previewer(opts),
        sorter = require('telescope.config').values.generic_sorter(opts),
        attach_mappings = function(_, map)
            map({ "i", "n" }, "<M-d>", require('telescope.actions').delete_buffer)
            return true
        end,
    }):find()
end

vim.keymap.set('n', '<leader>ff', with_ivy(builtin.find_files))
vim.keymap.set('n', '<leader>fg', with_ivy(builtin.live_grep))
vim.keymap.set('n', '<leader><leader>', with_ivy(buffers_and_files))
vim.keymap.set('n', '<leader>fh', with_ivy(builtin.help_tags))
vim.keymap.set('n', '<leader>qf', with_ivy(builtin.quickfix))
vim.keymap.set('n', 'gr', with_ivy(builtin.lsp_references))
vim.keymap.set('n', '<leader>jf', with_ivy(builtin.lsp_document_symbols, { symbols = 'function' }))
vim.keymap.set('n', '<leader>jm', with_ivy(builtin.lsp_document_symbols, { symbols = 'method' }))
vim.keymap.set('n', '<leader>jj', with_ivy(builtin.lsp_document_symbols))
vim.keymap.set('n', "<leader>lD", with_ivy(builtin.diagnostics))
vim.keymap.set('n', "<leader>lDD", with_ivy(builtin.diagnostics, { severity = "ERROR" }))
