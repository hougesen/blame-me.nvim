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
    end_line = 20,
    id = 1,
    virt_text = { {
      text or '',
      '',
    } },
    virt_text_pos = 'eol',
  }

  return vim.api.nvim_buf_set_extmark(0, ns_id, row, col, opts)
end

return M
