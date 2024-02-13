local M = {}

M.defaults = {
  delay = 1000,
  modes = { 'n' },
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
  signs = true,
}

---@param options unknown
function M.set(options)
  return vim.tbl_deep_extend('force', {}, M.defaults, options or {})
end

return M
