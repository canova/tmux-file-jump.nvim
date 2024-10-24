local M = {}

function M.warn(message)
  vim.api.nvim_echo({ { "tmux-jump.nvim: " .. message, "WarningMsg" } }, true, {})
end

return M
