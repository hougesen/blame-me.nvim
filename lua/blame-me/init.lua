local editor = require 'blame-me.editor'
local git = require 'blame-me.git'

local M = {}

local uv = vim.uv or vim.loop

---@type integer
local ns_id = vim.api.nvim_create_namespace 'blame-me'

---@type table<string, table<string, string>>
local files = {}

---@type table<string, string>
local commits = {}

---@type integer|nil
local mark_line_number = nil

local mark_is_shown = false

---refresh git blame of file
---@param current_file string
local function refresh_file_git_blame(current_file)
  if editor.is_explorer() then
    return
  end

  if editor.is_directory(current_file) then
    return
  end

  files[current_file] = git.get_git_blame(current_file, ns_id)
end

---get commit info of line
---@param current_file string
---@param line_number integer
---@return string|nil
local function get_line_info(current_file, line_number)
  local file_in_state = files[current_file]

  if file_in_state == nil then
    return nil
  end

  local line_commit_hash = file_in_state[line_number]

  return git.get_commit_information(line_commit_hash, commits)
end

local timer_line = -1
local timer = uv.new_timer()

---update commit_info mark
---@param commit_info string
---@param line_number number
---@param delay  number
---@return boolean
local function update_current_annotation(commit_info, line_number, delay)
  if type(commit_info) ~= 'string' or git.is_git_error_message(commit_info) then
    return false
  end

  if string.match(commit_info, 'fatal: not a git repository (or any of the parent directories): .git') then
    return false
  end

  timer_line = line_number

  timer:start(
    delay,
    1000,
    vim.schedule_wrap(function()
      timer:stop()

      if line_number == timer_line then
        editor.set_commit_info_mark(ns_id, commit_info, line_number - 1, 0)

        mark_is_shown = true
        mark_line_number = line_number
      end
    end)
  )

  return true
end

---deletes old commit info marks
local function delete_existing_mark()
  if mark_is_shown and editor.get_line_number() ~= mark_line_number then
    editor.delete_commit_info_mark(ns_id)

    mark_is_shown = false
  end
end

---refreshes commit info of line
---@param delay number
---@param mode table
local function show_current_line(delay, modes)
  local current_file = editor.get_current_file_path()

  if current_file == nil then
    return
  end

  if current_file == '' then
    return
  end

  local cur_mode = editor.get_current_mode()

  if modes[cur_mode] ~= true then
    return
  end

  local line_number = editor.get_line_number()

  local commit_info = get_line_info(current_file, line_number)

  if commit_info == nil or update_current_annotation(commit_info, line_number, delay) == false then
    refresh_file_git_blame(current_file)

    local updated_commit_info = get_line_info(current_file, line_number)

    if updated_commit_info ~= nil then
      update_current_annotation(updated_commit_info, line_number, delay)
    end
  end
end

---refreshes file git blame
local function update_commits()
  local current_file = editor.get_current_file_path()

  if current_file == nil then
    return
  end

  refresh_file_git_blame(current_file)
end

function M.setup(opts)
  local conf = require('blame-me.config').set(opts or {})

  local group = vim.api.nvim_create_augroup('blame_me', { clear = true })

  local hide_opts = {
    callback = delete_existing_mark,
    group = group,
  }

  for _, ev in pairs(conf.hide_on) do
    vim.api.nvim_create_autocmd(ev, hide_opts)
  end

  local enabled_modes = {}

  for _, mode in pairs(conf.modes) do
    enabled_modes[mode] = true
  end

  local show_opts = {
    callback = function()
      show_current_line(conf.delay, enabled_modes)
    end,
    group = group,
  }

  for _, ev in pairs(conf.show_on) do
    vim.api.nvim_create_autocmd(ev, show_opts)
  end

  local refresh_opts = {
    callback = update_commits,
    group = group,
  }

  for _, ev in pairs(conf.refresh_on) do
    vim.api.nvim_create_autocmd(ev, refresh_opts)
  end
end

return M
