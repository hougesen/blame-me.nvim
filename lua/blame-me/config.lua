local M = {}

M.defaults = {
  delay = 1000,
  show_on = {
    'CursorHold',
    'CursorHoldI',
  },
  hide_on = {
    'CursorMoved',
    'CursorMovedI',
  },
  refresh_on = {
    'BufWritePost',
    'BufEnter',
  },
}

---@param options unknown
---@return table
function M.set(options)
  return vim.tbl_deep_extend('force', {}, M.defaults, options or {})
end

return M
