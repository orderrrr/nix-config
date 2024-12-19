M = {}

M.update_hl = function(group, tbl)
  local hl_id = vim.api.nvim_get_hl_id_by_name(group)
  local old_hl = vim.api.nvim_get_hl(hl_id)
  local new_hl = vim.tbl_extend("force", old_hl, tbl)
  vim.api.nvim_set_hl(0, group, new_hl)
end

return M

-- vim: ts=2 sts=2 sw=2 et
