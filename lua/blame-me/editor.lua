local M = {}

---get name/path of active buffer
---@return string|nil
function M.get_current_file_path()
  return vim.api.nvim_buf_get_name(0)
end

---get current line number of active buffer
---@return integer
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

---set commit info ext mark
---@param ns_id integer
---@param text string
---@param row integer
---@param col integer
---@return unknown
function M.set_commit_info_mark(ns_id, text, row, col)
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

---delete the commit info ext mark
---@param ns_id integer
---@return unknown
function M.delete_commit_info_mark(ns_id)
  return vim.api.nvim_buf_del_extmark(0, ns_id, 1)
end

---set modified sign in left col
---@param ns_id integer
---@param row integer
---@return unknown
function M.set_modified_sign(ns_id, row)
  local opts = {
    id = 1 + row,
    sign_text = 'M',
    sign_hl_group = 'DiffText',
  }

  return vim.api.nvim_buf_set_extmark(0, ns_id, math.max(row - 1, 0), 0, opts)
end

---delete modified sign in left col
---@param ns_id integer
---@param row integer
---@return unknown
function M.remove_modified_sign(ns_id, row)
  return vim.api.nvim_buf_del_extmark(0, ns_id, 1 + row)
end

---check if current buffer is explorer
---@return boolean
function M.is_explorer()
  local current_type = vim.api.nvim_buf_get_option(0, 'filetype')

  if current_type == 'netrw' then
    return true
  end

  return false
end

---check if path is directory
---@param path string
---@return boolean
function M.is_directory(path)
  return vim.fn.isdirectory(path) ~= 0
end

return M
