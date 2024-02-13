local editor = require 'blame-me.editor'

local M = {}

---check if message is created by this plugin
---@param message string
---@return boolean
function M.is_git_error_message(message)
  return message:sub(5, 6) == '*'
end

---parse commit hash from line
---@param line string
---@return string
function M.parse_commit_hash(line)
  local hash, _ = line:sub(1, 8):gsub('^^', '')

  return hash
end

---check if commit hash is from an actual commit
---@param commit_hash string
---@return boolean
function M.is_modified_line(commit_hash)
  return commit_hash == '00000000'
end

---get commit from cache if possible, otherwise get using git show
---@param commit_hash string
---@param commits table<string, string>
---@return string|nil
function M.get_commit_information(commit_hash, commits)
  if M.is_modified_line(commit_hash) then
    --default message for uncommitted messages
    return '    * You | Uncommitted change'
  end

  local existing_commit = commits[commit_hash]

  if existing_commit ~= nil then
    return existing_commit
  end

  local cmd =
    string.format('%s %s', 'git show --quiet   --pretty=format:"    * %an, %ar | %s" 2> /dev/null', commit_hash)

  local status, handle, error_msg = pcall(io.popen, cmd)

  if status == false then
    return nil
  end

  if handle == nil then
    return nil
  end

  if error_msg ~= nil then
    return nil
  end

  local commit_info = handle:read()

  handle:close()

  if commit_info ~= nil and M.is_git_error_message(commit_info) == false then
    commits[commit_hash] = commit_info
  end

  return commit_info
end

---get git blame of file
---@param path string
---@param ns_id integer
---@param set_signs boolean
---@return table<string, string>|nil
function M.get_git_blame(path, ns_id, set_signs)
  if path == nil or string.len(path) == 0 then
    return nil
  end

  local command = string.format('git blame %s 2> /dev/null', path)

  local status, handle, error_message = pcall(io.popen, command)

  if status == false then
    return nil
  end

  if handle == nil then
    return nil
  end

  if error_message ~= nil then
    return nil
  end

  local i = 1

  ---@type table<string, string>
  local line_commit_map = {}

  for line in handle:lines() do
    if string.len(line) > 0 then
      local start = string.sub(line, 1, 5)

      if start == 'fatal' then
        break
      end

      local commit_hash = M.parse_commit_hash(line)

      line_commit_map[i] = commit_hash

      if set_signs == true then
        if M.is_modified_line(commit_hash) then
          -- TODO: handle error cases
          pcall(function()
            editor.set_modified_sign(ns_id, i)
          end)
        else
          -- TODO: handle error cases
          pcall(function()
            editor.remove_modified_sign(ns_id, i)
          end)
        end
      end
    end

    i = i + 1
  end

  handle:close()

  return line_commit_map
end

return M
