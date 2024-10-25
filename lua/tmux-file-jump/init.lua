local Config = require("tmux-file-jump.config")
local Viewer = require("tmux-file-jump.viewer")
local File = require("tmux-file-jump.file")
local Tmux = require("tmux-file-jump.tmux")

local M = {}

function M.setup(opts)
  Config.setup(opts)
end

-- Get the paths from tmux and list all of them in either telescope or fzf-lua
function M.list_files(pattern)
  pattern = pattern or {}

  local list = Tmux.get_paths(pattern)
  if #list == 0 then
    return
  end

  Viewer.open_list(list)
end

-- Get the first (bottom first) path from tmux and directly jump to that file.
function M.jump_first(pattern)
  pattern = pattern or {}

  local list = Tmux.get_paths(pattern)
  if #list == 0 then
    return
  end

  File.jump_to_file(list[1])
end

vim.api.nvim_create_user_command("TmuxFileJump", function(opts)
  M.list_files(opts.args)
end, { nargs = "*", desc = "List all file paths in the other tmux panes" })

vim.api.nvim_create_user_command("TmuxFileJumpFirst", function(opts)
  M.jump_first(opts.args)
end, { nargs = "*", desc = "Go to the first (from bottom) file path in the other tmux panes" })

return M
