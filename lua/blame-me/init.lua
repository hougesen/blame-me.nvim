local ns_id = vim.api.nvim_create_namespace 'blame-me'

local M = {}

---@return string|nil
function M.get_current_file_path()
  return vim.api.nvim_buf_get_name(0)
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
function M.get_git_blame(path)
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
  end

  handle:close()

  return lines
end

function M.set_mark(text, row, col)
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

function M.BlameMe()
  local current_file = M.get_current_file_path()

  if current_file == nil then
    return
  end

  local line_information = M.get_git_blame(current_file)

  if line_information == nil then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)

  local line_number = cursor[1]

  local commit_info = line_information[line_number]

  if type(commit_info) ~= 'string' then
    commit_info = ''
  end

  M.set_mark(commit_info, line_number - 1, 0)
end

function M.setup(opts)
  if opts == nil then
    return
  end

  local autocmds_events = opts['autocmds_events']

  if autocmds_events == nil then
    return
  end
  local group = vim.api.nvim_create_augroup('blame_me', { clear = true })

  local cmd_opts = {
    callback = M.BlameMe,
    group = group,
  }

  for _, event in ipairs(autocmds_events) do
    vim.api.nvim_create_autocmd(event, cmd_opts)
  end
end

return M
