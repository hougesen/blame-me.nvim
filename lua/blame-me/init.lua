local editor = require 'blame-me.editor'
local git = require 'blame-me.git'

local ns_id = vim.api.nvim_create_namespace 'blame-me'

local M = {}

local state = {}

local mark_line_number = nil

local mark_is_shown = false

---@param current_file string
local function refresh_current_buffer(current_file)
  if editor.is_explorer() then
    return
  end

  state[current_file] = git.get_git_blame(current_file)
end

---@param current_file string
---@param line_number integer
---@return string|nil
local function get_from_state(current_file, line_number)
  local file_in_state = state[current_file]

  if file_in_state == nil then
    return nil
  end

  local line_info = file_in_state[line_number]

  if type(line_info) ~= 'string' then
    return nil
  end

  return line_info
end

---@param commit_info string
---@param line_number number
---@return boolean
local function update_current_annotation(commit_info, line_number)
  if type(commit_info) ~= 'string' or git.is_git_error_message(commit_info) then
    return false
  end

  if string.match(commit_info, 'fatal: not a git repository (or any of the parent directories): .git') then
    return false
  end

  editor.set_mark(ns_id, commit_info, line_number - 1, 0)

  mark_is_shown = true
  mark_line_number = line_number

  return true
end

local function on_cursor_move()
  local cursor = vim.api.nvim_win_get_cursor(0)

  if mark_is_shown and editor.get_line_number() ~= mark_line_number then
    editor.delete_mark(ns_id)

    mark_is_shown = false
  end
end

local function on_cursor_hold()
  local current_file = editor.get_current_file_path()

  if current_file == nil then
    return
  end

  if current_file == '' then
    return
  end

  local line_number = editor.get_line_number()

  local commit_info = get_from_state(current_file, line_number)

  if commit_info == nil or update_current_annotation(commit_info, line_number) == false then
    refresh_current_buffer(current_file)

    local updated_commit_info = get_from_state(current_file, line_number)

    if updated_commit_info ~= nil then
      update_current_annotation(updated_commit_info, line_number)
    end
  end
end

local function on_buff_change()
  local current_file = editor.get_current_file_path()

  if current_file == nil then
    return
  end

  refresh_current_buffer(current_file)
end

function M.setup()
  local group = vim.api.nvim_create_augroup('blame_me', { clear = true })

  local cursor_move_config = {
    callback = on_cursor_move,
    group = group,
  }

  vim.api.nvim_create_autocmd('CursorMoved', cursor_move_config)
  vim.api.nvim_create_autocmd('CursorMovedI', cursor_move_config)

  local cursor_hold_config = {
    callback = on_cursor_hold,
    group = group,
  }

  vim.api.nvim_create_autocmd('CursorHold', cursor_hold_config)
  vim.api.nvim_create_autocmd('CursorHoldI', cursor_hold_config)

  local refresh_opts = {
    callback = on_buff_change,
    group = group,
  }

  vim.api.nvim_create_autocmd('BufWritePost', refresh_opts)
end

return M
