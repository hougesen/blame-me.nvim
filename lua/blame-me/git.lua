local M = {}

---@param line string
---@return string
function M.parse_commit_hash(line)
  local hash, _ = line:sub(1, 8):gsub('^^', '')

  return hash
end

---@param commit_hash string
---@return string|nil
function M.get_commit_information(commit_hash)
  local cmd = string.format('%s %s', 'git show --quiet   --pretty=format:"    * %an, %ar | %s"', commit_hash)

  local handle = io.popen(cmd)

  if handle == nil then
    return nil
  end

  local commit_info = handle:read()

  handle:close()

  return commit_info
end

---@param path string
---@return table|nil
function M.get_git_blame(path, line_number)
  local command = string.format('git blame %s', path)

  local handle = io.popen(command)

  if handle == nil then
    return nil
  end

  local commits = {}

  local i = 1
  local lines = {}

  for line in handle:lines() do
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

        if commit_message ~= nil then
          commits[commit_hash] = commit_message

          lines[i] = commit_message
        else
          --default message when reading commit fails
          lines[i] = string.format('    Error getting commit information @%s', commit_message)
        end
      end
    end

    i = i + 1

    if i > line_number then
      break
    end
  end

  handle:close()

  return lines
end

return M
