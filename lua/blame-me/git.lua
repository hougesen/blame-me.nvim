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

---@param commit_hash string
---@return string|nil
function M.get_commit_information(commit_hash)
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

  local commits = {}

  local i = 1
  local lines = {}

  for line in handle:lines() do
    if string.len(line) > 0 then
      local start = string.sub(line, 1, 5)

      if start == 'fatal' then
        break
      end

      local commit_hash = M.parse_commit_hash(line)

      if commit_hash == '00000000' then
        --default message for uncomitted messages
        lines[i] = '    * You | Uncommited change'
      else
        local existing_commit = commits[commit_hash]

        if existing_commit ~= nil then
          lines[i] = existing_commit
        else
          local commit_message = M.get_commit_information(commit_hash)

          if commit_message ~= nil and M.is_git_error_message(commit_message) == false then
            commits[commit_hash] = commit_message

            lines[i] = commit_message
          end
        end
      end
    end

    i = i + 1
  end

  handle:close()

  return lines
end

return M
