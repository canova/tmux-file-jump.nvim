local M = {}

-- Take the file path with the line and column numbers and then navigate to that
-- file and location.
function M.jump_to_file(file_with_pos)
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

return M
