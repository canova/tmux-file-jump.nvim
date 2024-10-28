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
  status, fzf_lua = pcall(require, "fzf-lua")
  if not status then
    Log.warn("fzf-lua not found")
    return
  end

  local opts = config.normalize_opts({
    prompt = "TmuxFileJump> ",
    actions = fzf_lua.defaults.actions.files,
  }, "files")

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

local function get_file_line_contents(file_cache, file_path, line_number)
  if file_cache[file_path] then
    return file_cache[file_path][line_number]
  end

  local file = io.open(file_path, "r")
  if not file then
    return nil
  end

  local lines = {}
  for line in file:lines("*l") do
    lines[#lines + 1] = line
  end
  file:close()

  file_cache[file_path] = lines
  return lines[line_number]
end

local function open_qflist(list, loclist)
  local qf_items = {}
  -- Caching files per call since there can be multiple file entries with different lines.
  local file_cache = {}
  for i, line in ipairs(list) do
    local filepath, lnum, col = string.match(line, "(.-):(%d+):(%d+)")
    lnum = tonumber(lnum)
    col = tonumber(col)
    local line_contents = get_file_line_contents(file_cache, filepath, lnum)

    qf_items[i] = {
      filename = filepath,
      lnum = lnum,
      col = col,
      text = line_contents,
    }
  end

  -- Open either qflist or loclist depending on the choice.
  if loclist then
    vim.fn.setloclist(0, {}, " ", { title = "TmuxFilesJump", id = "$", items = qf_items })
    vim.cmd("lopen")
  else
    vim.fn.setqflist({}, " ", { title = "TmuxFilesJump", id = "$", items = qf_items })
    vim.cmd("copen")
  end
end

-- Open the list depending on the config setting.
function M.open_list(list)
  if Config.options.viewer == "telescope" then
    open_telescope(list)
  elseif Config.options.viewer == "fzf-lua" then
    open_fzf_lua(list)
  elseif Config.options.viewer == "qflist" then
    open_qflist(list)
  elseif Config.options.viewer == "loclist" then
    open_qflist(list, true)
  else
    Log.warn("Unrecognized viewer option")
  end
end

return M
