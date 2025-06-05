return {
    {
        'rmagatti/auto-session',
        config = function()
            require('auto-session').setup({
                log_level = 'error',
                auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
                auto_session_use_git_branch = true,

                -- Auto save session when switching
                auto_save_enabled = true,
                auto_restore_enabled = true,

                -- Session lens for telescope integration
                session_lens = {
                    load_on_setup = true,
                    theme_conf = { border = true },
                    previewer = false,
                },

                -- Hooks for project switching
                pre_save_cmds = {
                    "silent! lua vim.notify('Saving session...')"
                },

                post_restore_cmds = {
                    "silent! lua vim.notify('Session restored!')"
                }
            })
        end
    },
    {
        'ahmedkhalf/project.nvim',
        config = function()
            require('project_nvim').setup({
                scope_chdir = 'global',
            })
            require('telescope').load_extension('projects')
        end
    },
}
