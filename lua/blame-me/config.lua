local M = {}

---@param opts unknown
function M.set(opts)
  local config = {
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

  if opts.show_on ~= nil then
    config.show_on = opts.show_on
  end

  if opts.hide_on ~= nil then
    config.hide_on = opts.hide_on
  end

  if opts.refresh_on ~= nil then
    config.refresh_on = opts.refresh_on
  end

  return config
end

return M
