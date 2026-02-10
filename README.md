# lualine-grapple.nvim

A [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) component that displays your [grapple.nvim](https://github.com/cbochs/grapple.nvim) tags in the statusline.

Each tagged file is shown as `[index] filename`, with the active buffer's tag visually highlighted.

## Requirements

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [grapple.nvim](https://github.com/cbochs/grapple.nvim)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "cbochs/grapple.nvim",
    "uloco/lualine-grapple.nvim",
  },
  opts = {
    sections = {
      lualine_c = {
        { "grapple_tags" },
      },
    },
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "nvim-lualine/lualine.nvim",
  requires = {
    "cbochs/grapple.nvim",
    "uloco/lualine-grapple.nvim",
  },
}
```

Then add `"grapple_tags"` to any lualine section:

```lua
require("lualine").setup({
  sections = {
    lualine_c = {
      { "grapple_tags" },
    },
  },
})
```

## Configuration

All options are passed directly in the lualine component table. These are the defaults:

```lua
{ "grapple_tags",
  -- Number of tag slots to display
  number_of_tags = 4,
  -- Highlight group used for bracket color ([, ])
  highlight_bracket = "Punctuation",
  -- Highlight group used for the tag index number
  highlight_index = "Number",
  -- Highlight group used for the active tag (current buffer)
  highlight_name_active = "Folded",
  -- Highlight group used for inactive tags
  highlight_name_inactive = "lualine_c_normal",
}
```

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `number_of_tags` | `integer` | `4` | How many tag slots (1..N) to display. Slots without a tag are simply omitted. |
| `highlight_bracket` | `string` | `"Punctuation"` | Highlight group whose **foreground** is used for `[` and `]`. |
| `highlight_index` | `string` | `"Number"` | Highlight group whose **foreground** is used for the tag index number. |
| `highlight_name_active` | `string` | `"Folded"` | Highlight group applied to the filename of the tag matching the current buffer. Its **background** is also used behind the brackets and index. |
| `highlight_name_inactive` | `string` | `"lualine_c_normal"` | Highlight group applied to filenames of tags that do not match the current buffer. Its **background** is also used behind the brackets and index. |

### Example

Show 6 tags with custom colors:

```lua
{ "grapple_tags",
  number_of_tags = 6,
  highlight_bracket = "Delimiter",
  highlight_index = "Special",
  highlight_name_active = "CursorLine",
  highlight_name_inactive = "Comment",
}
```

## How It Works

The component iterates through grapple tag slots 1 through `number_of_tags`. For each slot that has a tag, it renders the tag index and the filename (tail component of the path). The tag corresponding to the current buffer is highlighted differently from the rest, making it easy to see which tag you're on at a glance.

If grapple.nvim is not installed or not loaded, the component silently returns an empty string.
