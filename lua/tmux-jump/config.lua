local M = {}

local function get_current_file_path()
  -- Get the current file's path
  local script_path = debug.getinfo(1).source:sub(2) -- Remove the leading '@'
  return vim.fn.fnamemodify(script_path, ":p:h")
end

local scripts_dir = get_current_file_path() .. "/../../scripts/"

---@class TmuxJump.Config
local defaults = {
  -- script that captures the tmux pane file paths.
  script_path = scripts_dir .. "capture.sh",
  -- It can be "telescope" or "fzf-lua".
  viewer = "telescope",
}

---@class TmuxJump.Config
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
