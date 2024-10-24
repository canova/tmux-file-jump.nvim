local Config = require("tmux-jump.config")

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
    vim.api.nvim_echo({ { "tmux-jump.nvim: Not in a tmux session", "WarningMsg" } }, true, {})
    return {}
  end

  local captured_files = vim.fn.system("bash " .. Config.options.script_path .. " " .. pattern)
  if captured_files == "" then
    vim.api.nvim_echo({ { "tmux-jump.nvim: No file paths found", "WarningMsg" } }, true, {})
    return {}
  end

  local list = vim.fn.reverse(
    vim.fn.uniq(strip_prefix_from_list(vim.split(captured_files, "\n", { trimempty = true }), { "a/", "b/" }))
  )
  return list
end

return M
