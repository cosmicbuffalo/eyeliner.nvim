# 👀 eyeliner.nvim

Move faster with unique `f`/`F` indicators for each word on the line. Like [quick-scope](https://github.com/unblevable/quick-scope), but in Lua. 

> [!NOTE]
> This is cosmicbuffalo's heavily modified fork of jinh0's `eyeliner.nvim`. Compared to jinh0's original plugin, this refactor has removed fennel and the "always on" functionality entirely, and is currently actively maintained.

<!-- ![demo](https://user-images.githubusercontent.com/40512164/181354222-b4487f22-e947-468a-8739-653074e2c012.gif) -->

https://user-images.githubusercontent.com/40512164/178066018-0d3fa234-a5b5-4a41-a340-430e8c4c2739.mov

The orange letters indicate the unique letter in the word that you can jump to with `f`/`F` right away.
Blue letters indicate that there is no unique letter in the word, but you can get to it with `f`/`F` and then a repeat with `;`.

## 📦 Installation
Requirement: Neovim >= 0.7.0

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{ "cosmicbuffalo/eyeliner.nvim" }
```

Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'cosmicbuffalo/eyeliner.nvim'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use 'cosmicbuffalo/eyeliner.nvim'
```

## ⚙️ Configuration

Default values (in lazy.nvim):
```lua
{
  'cosmicbuffalo/eyeliner.nvim',
  opts = {
    -- add eyeliner to f/F/t/T keymaps;
    -- see section on advanced configuration for more information
    default_keymaps = true,

    -- set to true for case-sensitive highlighting (default)
    -- set to false to downcase the line before calculating highlights
    case_sensitive = true,

    -- dim all other characters if set to true
    dim = false,             

    -- set the maximum number of characters eyeliner.nvim will check from
    -- your current cursor position; this is useful if you are dealing with
    -- large files: see https://github.com/jinh0/eyeliner.nvim/issues/41
    max_length = 9999,

    -- filetypes for which eyeliner should be disabled;
    -- e.g., to disable on help files:
    -- disabled_filetypes = {"help"}
    disabled_filetypes = {},

    -- buftypes for which eyeliner should be disabled
    -- e.g., disabled_buftypes = {"nofile"}
    disabled_buftypes = {},
  }
}
```

<details>
<summary>Demo</summary>

https://user-images.githubusercontent.com/40512164/180614964-c1a63671-7fa8-438d-ad4f-c90079adf098.mov

</details>

### Dim functionality

When using eyeliner, you may want to dim the rest of the characters since they are unimportant. You can do this with the `dim` option:

```lua
require'eyeliner'.setup {
  dim = true,
}
```

https://user-images.githubusercontent.com/40512164/211218941-ac7df0b6-67ea-4aa2-af9a-110ef9e3091f.mov


## 🖌 Customize highlight colors
You can customize the highlight colors and styles with the `EyelinerPrimary` and `EyelinerSecondary` highlight groups.

For instance, if you wanted to make eyeliner.nvim more subtle by only using bold and underline, with no color,

In Vimscript:
```vim
highlight EyelinerPrimary gui=underline,bold
highlight EyelinerSecondary gui=underline
```

In Lua:
```lua
vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
vim.api.nvim_set_hl(0, 'EyelinerSecondary', { underline = true })
```

If you want to set a custom color:

In Vimscript:
```vim
highlight EyelinerPrimary guifg=#000000 gui=underline,bold
highlight EyelinerSecondary guifg=#ffffff gui=underline
```

In Lua:
```lua
vim.api.nvim_set_hl(0, 'EyelinerPrimary', { fg='#000000', bold = true, underline = true })
vim.api.nvim_set_hl(0, 'EyelinerSecondary', { fg='#ffffff', underline = true })
```

### Update highlights when the colorscheme is changed
In Vimscript:
```vim
autocmd ColorScheme * :highlight EyelinerPrimary ...
```
In Lua:
```lua
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
  end,
})
```

## Advanced Configuration

Some users might want to use other plugins that change the f/F/t/T functionality, like https://github.com/rhysd/clever-f.vim or https://github.com/echasnovski/mini.jump

eyeliner.nvim by default maps the f/F/t/T keys. You can disable this with the `default_keymaps` option:
```lua
require'eyeliner'.setup {
  default_keymaps = false
}
```

eyeliner.nvim exposes the highlight functionality:
```lua
require("eyeliner").highlight({ forward = true })
```
Set `forward = true` for f/t highlights and `forward = false` for F/T highlights.

You can also override the case sensitivity for individual highlight calls:
```lua
require("eyeliner").highlight({ forward = true, case_sensitive = false })
```

### Example: Integration with clever-f.vim

The following code adds eyeliner.nvim highlights to clever-f's `f` functionality:
```lua
vim.g.clever_f_not_overwrites_standard_mappings = 1

vim.keymap.set(
  {"n", "x", "o"},
  "f",
  function() 
    require("eyeliner").highlight({ forward = true })
    return "<Plug>(clever-f-f)"
  end,
  {expr = true}
)
```

### Example: Integration with mini.jump

The following code integrates eyeliner.nvim with [mini.jump](https://github.com/echasnovski/mini.jump) using `lazy.nvim`:
```lua
{
  "echasnovski/mini.jump",
  keys = { "f", "F", "t", "T" },
  dependencies = {
    {
      "jinh0/eyeliner.nvim",
      opts = {
        default_keymaps = false, -- disable default f/F/t/T keymaps
      },
    },
  },
  config = function()
    require("mini.jump").setup()
    
    -- Trigger eyeliner highlights when mini.jump starts
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniJumpGetTarget",
      callback = function()
        require("eyeliner").highlight({
          forward = not MiniJump.state.backward,
          case_sensitive = false, -- optional: disable case sensitivity if using mini.jump with vim.o.ignorecase
        })
      end,
    })
  end,
}
```

## Commands
Enable/disable/toggle:
```
:EyelinerEnable
:EyelinerDisable
:EyelinerToggle
```

## Troubleshooting

- To disable eyeliner.nvim on the [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) plugin, you need to add `nofile` as a disabled buftype to your configuration, i.e., `disable_buftypes = {"nofile"}` and `NvimTree` as a disabled filetype, i.e., `disable_filetypes = {"NvimTree"}`.

## Contributing

Contributions are welcome! Feel free to fork and spin up a PR
