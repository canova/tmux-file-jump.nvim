local File = require("tmux-jump.file")

local M = {}

-- Open the file list in fzf-lua.
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
        File.jump_to_file(selected[1])
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

-- Open the list depending on the config setting.
function M.open_list(list)
  open_fzf_lua(list)
end

return M
