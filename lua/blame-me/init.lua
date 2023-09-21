local function get_current_file_path()
  return vim.api.nvim_buf_get_name(0)
end

local function parse_commit_hash(line)
  return string.sub(line, 1, 9):gsub('^^', '')
end

local function get_commit_information(commit_hash)
  local cmd = string.format('%s %s', 'git show --quiet   --pretty=format:"%an, %ar | %s"', commit_hash)

  local handle = io.popen(cmd)

  if handle == nil then
    return nil
  end

  local x = handle:read()
  return x
end

local function get_git_blame(path)
  local command = string.format('git blame %s', path)

  local handle = io.popen(command)

  if handle == nil then
    return nil
  end

  local commits = {}

  -- default message for uncomitted messages
  commits['00000000'] = 'You | Uncommited change'

  local i = 1
  local lines = {}

  for line in handle:lines() do
    local commit_hash = parse_commit_hash(line)

    print(commit_hash)

    local existing_commit = commits[commit_hash]

    if existing_commit ~= nil then
      lines[i] = existing_commit
    else
      local commit_message = get_commit_information(commit_hash)

      if commit_message ~= nil then
        commits[commit_hash] = commit_message

        lines[i] = commit_message
        print(commit_message)
      end
    end

    i = i + 1
  end

  print(lines)

  handle:close()

  return lines
end

function BlameMeCurrentFile()
  local current_file = get_current_file_path()

  get_git_blame(current_file)
end

BlameMeCurrentFile()
