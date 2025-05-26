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

  local captured_paths = M.capture_panes(pattern)
  if #captured_paths == 0 then
    Log.warn("No file paths found")
    return {}
  end

  local unique_paths = vim.fn.uniq(strip_prefix_from_list(captured_paths, { "a/", "b/" }))
  if type(unique_paths) ~= "table" then
    return {}
  end
  return vim.fn.reverse(unique_paths)
end

-- Function to capture tmux panes and extract file paths matching a pattern
function M.capture_panes(pattern)
  local is_in_tmux = vim.fn.has_key(vim.fn.environ(), "TMUX")
  if is_in_tmux == 0 then
    Log.warn("Not in a tmux session")
    return {}
  end

  if vim.fn.executable("rg") == 0 then
    vim.notify("ripgrep (rg) is required but not found.", vim.log.levels.ERROR)
    return {}
  end

  -- Get the current tmux pane index
  local current_pane = vim.fn.system("tmux display -pt \"${TMUX_PANE:?}\" '#{pane_index}'"):gsub("%s+", "")

  -- List all tmux panes
  local panes = vim.fn.systemlist('tmux list-panes -F "#{pane_index}"')
  local captured = {}

  -- Escape the regex pattern for rg
  -- Note: If Config.options.regex can contain single quotes,
  -- you might need a more robust escaping strategy or ensure your regex
  -- does not contain them if passed directly in single quotes.
  -- For most cases, shellescape is sufficient if rg expects a literal string.
  local escaped_rg_regex = vim.fn.shellescape(Config.options.regex)

  -- Iterate over all panes and capture content from non-current panes
  for _, pane_index in ipairs(panes) do
    if pane_index ~= current_pane then
      -- Capture pane content directly and pipe to rg
      -- Use 'tmux capture-pane -pJS - -t <pane_index>' to output to stdout
      -- and pipe that directly to rg's stdin.
      local cmd = string.format(
        "tmux capture-pane -pJS - -t %s | rg -oi %s",
        vim.fn.shellescape(pane_index),
        escaped_rg_regex
      )

      local filtered_content = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        Log.warn(string.format("Failed to capture or filter content for pane %s: %s", pane_index, vim.v.shell_error))
        -- Continue to next pane, don't return early
      end

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
