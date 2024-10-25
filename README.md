# tmux-file-jump.nvim

This Neovim plugin is designed to open files in compilation or linting errors
directly from a sibling tmux pane.

I was looking for a way to easily navigate compile/lint errors without switching
between panes or copy-pasting file paths, aiming to replicate the functionality
of Emacs' compilation mode but using tmux. You can combine it with a tool like
nodemon, watchexec etc. to never leave out of your nvim pane.

Before this plugin, I discovered [tmuxjump.vim](https://github.com/shivamashtikar/tmuxjump.vim),
which offered similar functionality. However, I wanted a Lua-based alternative
with some enhancements tailored to my needs. This plugin is heavily inspired by
tmuxjump.vim.


## 💻 Use case

My use case is very similar to the one described in the plugin I mentioned
earlier. When coding, I typically work with two panes in a vertical split.
Previously, I had to switch back and forth between these panes to recompile
code or run tests, which was tedious. Then I started using `watchexec` to
automatically run commands, such as compilation, testing, or linting, whenever
I modified a file. However, navigating through the error messages produced by
these commands and finding specific lines in the files wasn't very smooth.

That's when I decided to create a plugin that detects file paths with line and
column numbers (e.g., `src/index.js:24:10`) and allows me to jump directly to
the relevant location, all without leaving Neovim. This extension has
streamlined my workflow significantly.

## ⚡️ Requirements

- Neovim >= 0.9.0 with Telescope, Neovim >= 0.8.0 for fzf-lua
- Either [Telescope](https://github.com/nvim-telescope/telescope.nvim) or
[fzf-lua](https://github.com/ibhagwan/fzf-lua).
- ripgrep
- tmux

## 📦 Installation

Install the plugin with your preferred package manager. Here's an example for
lazy.nvim:

### lazy.nvim

```lua
{
  "canova/tmux-file-jump.nvim",
  event = 'VeryLazy',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua', -- Or fzf-lua if you prefer.
  },
  config = function()
    local tmux_file_jump = require 'tmux-file-jump'
    tmux_file_jump.setup {
      -- viewer = "fzf-lua" -- Uncomment for fzf-lua.
    }

    -- Change your keymaps as you like.
    vim.keymap.set('n', '<leader>tl', tmux_file_jump.list_files, { desc = 'List all file paths in the other tmux panes' })
    vim.keymap.set('n', '<leader>tj', tmux_file_jump.jump_first, { desc = 'Go to the first (from bottom) file path in the other tmux panes' })
  end,
}
```

### ⚙️ Configuration

tmux-file-jump.nvim comes with the following defaults:

```lua
{
  -- script that captures the tmux pane file paths.
  script_path = scripts_dir .. "capture.sh",
  -- It can be "telescope" or "fzf-lua".
  viewer = "telescope",
}
```
