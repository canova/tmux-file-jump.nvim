local Config = require("tmux-jump.config")
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

-- Open the file list in fzf-lua.
local function open_telescope(list)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local function entry_maker(line)
    local filepath, lnum, col = string.match(line, "(.-):(%d+):(%d+)")
    return {
      value = line,
      display = line, -- this is what will be shown in the picker
      ordinal = filepath, -- used for sorting and filtering
      path = filepath,
      lnum = tonumber(lnum),
      col = tonumber(col),
    }
  end

  pickers
    .new({}, {
      prompt_title = "TmuxJump",
      __locations_input = true,
      finder = finders.new_table({
        results = list,
        entry_maker = entry_maker,
      }),
      previewer = conf.grep_previewer({}),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

-- Open the list depending on the config setting.
function M.open_list(list)
  if Config.options.viewer == "telescope" then
    open_telescope(list)
  elseif Config.options.viewer == "fzf-lua" then
    open_fzf_lua(list)
  else
    vim.api.nvim_echo({ { "tmux-jump.nvim: Unrecognized viewer option", "WarningMsg" } }, true, {})
  end
end

return M
