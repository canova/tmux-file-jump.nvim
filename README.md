# tmux-jump.nvim

This Neovim plugin is designed to open files directly from a sibling tmux pane.

I was looking for a way to easily navigate compile/lint errors without switching
between panes or copy-pasting file paths, aiming to replicate the functionality
of Emacs' compilation mode but using tmux.

I discovered [tmuxjump.vim](https://github.com/shivamashtikar/tmuxjump.vim),
which offered similar functionality. However, I wanted a Lua-based alternative
with some enhancements tailored to my needs. This plugin is heavily inspired by
tmuxjump.vim.

## ⚡️ Requirements

- Neovim >= 0.9.0 with Telescope, Neovim >= 0.8.0 for fzf-lua
- Either [Telescope](https://github.com/nvim-telescope/telescope.nvim) or
[fzf-lua](https://github.com/ibhagwan/fzf-lua).

## 📦 Installation

Install the plugin with your preferred package manager. Here's an example for
lazy.nvim:

### lazy.nvim

```lua
{
  "canova/tmux-jump.nvim",
  event = 'VeryLazy',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua', -- Or fzf-lua if you prefer.
  },
  config = function()
    local tmux_jump = require 'tmux-jump'
    tmux_jump.setup {}

    -- Change your keymaps as you like.
    vim.keymap.set('n', '<leader>tl', tmux_jump.list_files, { desc = 'List all file paths in the other tmux panes' })
    vim.keymap.set('n', '<leader>tj', tmux_jump.jump_first, { desc = 'Go to the first (from bottom) file path in the other tmux panes' })
  end,
}
```

### ⚙️ Configuration

tmux-jump.nvim comes with the following defauls:

```lua
{
  -- script that captures the tmux pane file paths.
  script_path = scripts_dir .. "capture.sh",
  -- It can be "telescope" or "fzf-lua".
  viewer = "telescope",
}
```
