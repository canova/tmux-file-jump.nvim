local Config = require("tmux-file-jump.config")
local File = require("tmux-file-jump.file")
local Log = require("tmux-file-jump.log")

local M = {}

-- Open the file list in fzf-lua.
local function open_fzf_lua(list)
  local status, config, fzf_lua
  status, config = pcall(require, "fzf-lua.config")
  if not status then
    Log.warn("fzf-lua not found")
    return
  end

  local opts = config.normalize_opts({
    prompt = "TmuxFileJump> ",
    actions = {
      ["default"] = function(selected)
        File.jump_to_file(selected[1])
      end,
    },
  }, "files")

  status, fzf_lua = pcall(require, "fzf-lua")
  if not status then
    Log.warn("fzf-lua not found")
    return
  end
  fzf_lua.fzf_exec(list, opts)
end

-- Open the file list in telescope.
local function open_telescope(list)
  local status, pickers, finders, conf
  status, pickers = pcall(require, "telescope.pickers")
  if not status then
    Log.warn("telescope.pickers not found")
    return
  end
  status, finders = pcall(require, "telescope.finders")
  if not status then
    Log.warn("telescope.finders not found")
    return
  end
  status, conf = pcall(require, "telescope.config")
  if not status then
    Log.warn("telescope.config not found")
    return
  end

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
      prompt_title = "TmuxFileJump",
      __locations_input = true,
      finder = finders.new_table({
        results = list,
        entry_maker = entry_maker,
      }),
      previewer = conf.values.grep_previewer({}),
      sorter = conf.values.generic_sorter({}),
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
    Log.warn("Unrecognized viewer option")
  end
end

return M
