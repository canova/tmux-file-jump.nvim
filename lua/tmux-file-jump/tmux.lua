local Config = require("tmux-file-jump.config")
local Log = require("tmux-file-jump.log")

local M = {}

-- Strip a list of prefixes from a list of strings.
-- It can be useful when you need to remove some prefixes like "a/" and "b/".
local function strip_prefix_from_list(strings, prefixes)
  local result = {}

  -- Function to strip the first matching prefix
  local function strip_prefix(str, prfxs)
    for _, prefix in ipairs(prfxs) do
      if string.sub(str, 1, string.len(prefix)) == prefix then
        return string.sub(str, string.len(prefix) + 1)
      end
    end
    return str -- Return the original string if no prefix matches
  end

  -- Iterate over each string in the list
  for _, str in ipairs(strings) do
    -- Strip any matching prefix from the current string
    table.insert(result, strip_prefix(str, prefixes))
  end

  return result
end

-- Get the tmux contents and return a list of paths.
function M.get_paths(pattern)
  local is_in_tmux = vim.fn.has_key(vim.fn.environ(), "TMUX")
  if is_in_tmux == 0 then
    Log.warn("Not in a tmux session")
    return {}
  end

  local captured_files = M.capture_panes(pattern)
  if #captured_files == 0 then
    Log.warn("No file paths found")
    return {}
  end

  local list = vim.fn.reverse(vim.fn.uniq(strip_prefix_from_list(captured_files, { "a/", "b/" })))
  return list
end

-- Function to capture tmux panes and extract file paths matching a pattern
function M.capture_panes(pattern)
  local is_in_tmux = vim.fn.has_key(vim.fn.environ(), "TMUX")
  if is_in_tmux == 0 then
    Log.warn("Not in a tmux session")
    return {}
  end

  -- Get the current tmux pane index
  local current_pane = vim.fn.system("tmux display -pt \"${TMUX_PANE:?}\" '#{pane_index}'"):gsub("%s+", "")

  -- List all tmux panes
  local panes = vim.fn.systemlist('tmux list-panes -F "#{pane_index}"')
  local captured = {}

  -- Iterate over all panes and capture content from non-current panes
  for _, pane in ipairs(panes) do
    if pane ~= current_pane then
      local pane_content = vim.fn.system("tmux capture-pane -pJS - -t " .. pane)
      local filtered_content =
        vim.fn.system("echo " .. vim.fn.shellescape(pane_content) .. " | rg -oi '" .. Config.options.regex .. "'")
      for file_path in filtered_content:gmatch("[^\n]+") do
        if file_path:match(pattern) then
          table.insert(captured, file_path)
        end
      end
    end
  end

  return captured
end

return M
