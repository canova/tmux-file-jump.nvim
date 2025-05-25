local M = {}

---@class TmuxFileJump.Config
local defaults = {
  -- Regular expression that's being used for capturing file paths.
  regex = "[a-zA-Z0-9_\\-~\\/]+(?:\\.[a-zA-Z0-9_\\-~]+)+\\:\\d+(?:\\:\\d+)?",
  -- It can be "telescope", "fzf-lua", "qflist", or "loclist".
  viewer = "telescope",
}

---@class TmuxFileJump.Config
M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
