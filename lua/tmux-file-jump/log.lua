local M = {}

function M.warn(message)
  vim.api.nvim_echo({ { "tmux-file-jump.nvim: " .. message, "WarningMsg" } }, true, {})
end

return M
