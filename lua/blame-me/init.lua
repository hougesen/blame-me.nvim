local editor = require 'blame-me.editor'
local git = require 'blame-me.git'

local ns_id = vim.api.nvim_create_namespace 'blame-me'

local M = {}

function M.BlameMe()
  local current_file = editor.get_current_file_path()

  if current_file == nil then
    return
  end

  local line_number = editor.get_line_number()

  local line_information = git.get_git_blame(current_file, line_number)

  if line_information == nil then
    return
  end

  local commit_info = line_information[line_number]

  if type(commit_info) ~= 'string' or git.is_git_error_message(commit_info) then
    commit_info = ''
  end

  editor.set_mark(ns_id, commit_info, line_number - 1, 0)
end

function M.setup(opts)
  if opts == nil then
    return
  end

  local autocmd_events = opts['autocmd_events']

  if autocmd_events == nil then
    return
  end

  local group = vim.api.nvim_create_augroup('blame_me', { clear = true })

  local cmd_opts = {
    callback = M.BlameMe,
    group = group,
  }

  for _, event in ipairs(autocmd_events) do
    vim.api.nvim_create_autocmd(event, cmd_opts)
  end
end

return M
