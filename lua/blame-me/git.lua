local M = {}

---@param message string
---@return boolean
function M.is_git_error_message(message)
  return message:sub(5, 6) == '*'
end

---@param line string
---@return string
function M.parse_commit_hash(line)
  local hash, _ = line:sub(1, 8):gsub('^^', '')

  return hash
end

---@comment get commit from cache if possible, otherwise get using git show
---@param commit_hash string
---@param commits table
---@return string|nil
function M.get_commit_information(commit_hash, commits)
  if commit_hash == '00000000' then
    --default message for uncomitted messages
    return '    * You | Uncommited change'
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

---@param path string
---@return table|nil
function M.get_git_blame(path)
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
  local line_commit_map = {}

  for line in handle:lines() do
    if string.len(line) > 0 then
      local start = string.sub(line, 1, 5)

      if start == 'fatal' then
        break
      end

      local commit_hash = M.parse_commit_hash(line)

      line_commit_map[i] = commit_hash
    end

    i = i + 1
  end

  handle:close()

  return line_commit_map
end

return M
