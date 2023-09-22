local M = {}

---@return string|nil
function M.get_current_file_path()
  return vim.api.nvim_buf_get_name(0)
end

---@return number
function M.get_line_number()
  local cursor = vim.api.nvim_win_get_cursor(0)

  if cursor == nil then
    return 0
  end

  local line_number = cursor[1]

  if type(line_number) ~= 'number' then
    return 0
  end

  return line_number
end

function M.set_mark(ns_id, text, row, col)
  local opts = {
    id = 1,
    virt_text = { {
      text,
      '',
    } },
    virt_text_pos = 'eol',
  }

  return vim.api.nvim_buf_set_extmark(0, ns_id, math.max(row, 0), math.max(col, 0), opts)
end

function M.delete_mark(ns_id)
  mark_line_number = nil
  return vim.api.nvim_buf_del_extmark(0, ns_id, 1)
end

---@return boolean
function M.is_explorer()
  local current_type = vim.api.nvim_buf_get_option(0, 'filetype')

  if current_type == 'netrw' then
    return true
  end

  return false
end

return M
