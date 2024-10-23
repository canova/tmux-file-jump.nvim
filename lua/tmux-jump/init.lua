local Config = require("tmux-jump.config")

local M = {}

function M.setup(opts)
  Config.setup(opts)
end

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
local function get_paths_from_tmux(pattern)
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

-- Take the file path with the line and column numbers and then navigate to that
-- file and location.
local function jump_to_file(file_with_pos)
  vim.print(file_with_pos)
  local list = vim.split(file_with_pos, ":")
  local file_name = list[1]
  if not vim.fn.filereadable(file_name) then
    return
  end
  vim.cmd("edit " .. file_name)
  if #list == 2 then
    vim.cmd("normal " .. list[2])
  elseif #list == 3 then
    vim.cmd("normal " .. list[2] .. "G" .. list[3] .. "|")
  end
end

-- Open the file list in fzf-lua.
--
local function open_fzf_lua(list)
  local status, config, fzf_lua
  status, config = pcall(require, "fzf-lua.config")
  if not status then
    vim.api.nvim_echo({ { "tmux-jump.nvim: fzf-lua not found", "WarningMsg" } }, true, {})
    return
  end

  local opts = config.normalize_opts({
    prompt = "TmuxJump> ",
    actions = {
      ["default"] = function(selected)
        jump_to_file(selected[1])
      end,
    },
  }, "files")

  status, fzf_lua = pcall(require, "fzf-lua")
  if not status then
    vim.api.nvim_echo({ { "tmux-jump.nvim: fzf-lua not found", "WarningMsg" } }, true, {})
    return
  end
  fzf_lua.fzf_exec(list, opts)
end

-- Get the paths from tmux and list all of them in either telescope or fzf-lua
function M.list_files(pattern)
  if pattern == nil then
    pattern = ""
  end
  local list = get_paths_from_tmux(pattern)
  if #list == 0 then
    return
  end

  open_fzf_lua(list)
end

-- Get the first (bottom first) path from tmux and directly jump to that file.
function M.jump_first(pattern)
  if pattern == nil then
    pattern = ""
  end

  local list = get_paths_from_tmux(pattern)
  if #list == 0 then
    return
  end

  jump_to_file(list[1])
end

vim.api.nvim_create_user_command("TmuxJumpFiles", function(opts)
  M.list_files(opts.args)
end, { nargs = "*", desc = "List all file paths in the other tmux panes" })

vim.api.nvim_create_user_command("TmuxJumpFirst", function(opts)
  M.jump_first(opts.args)
end, { nargs = "*", desc = "Go to the first (from bottom) file path in the other tmux panes" })

return M
