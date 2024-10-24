local Config = require("tmux-jump.config")
local Viewer = require("tmux-jump.viewer")
local File = require("tmux-jump.file")
local Tmux = require("tmux-jump.tmux")

local M = {}

function M.setup(opts)
  Config.setup(opts)
end

-- Get the paths from tmux and list all of them in either telescope or fzf-lua
function M.list_files(pattern)
  if pattern == nil then
    pattern = ""
  end
  local list = Tmux.get_paths(pattern)
  if #list == 0 then
    return
  end

  Viewer.open_list(list)
end

-- Get the first (bottom first) path from tmux and directly jump to that file.
function M.jump_first(pattern)
  if pattern == nil then
    pattern = ""
  end

  local list = Tmux.get_paths(pattern)
  if #list == 0 then
    return
  end

  File.jump_to_file(list[1])
end

vim.api.nvim_create_user_command("TmuxJumpFiles", function(opts)
  M.list_files(opts.args)
end, { nargs = "*", desc = "List all file paths in the other tmux panes" })

vim.api.nvim_create_user_command("TmuxJumpFirst", function(opts)
  M.jump_first(opts.args)
end, { nargs = "*", desc = "Go to the first (from bottom) file path in the other tmux panes" })

return M
