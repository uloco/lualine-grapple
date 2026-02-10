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
  -- Override highlight groups inline (optional)
  colors = nil,
}
```

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `number_of_tags` | `integer` | `4` | How many tag slots (1..N) to display. Slots without a tag are simply omitted. |
| `colors` | `table\|nil` | `nil` | A table of highlight overrides keyed by group name (see below). Takes priority over theme-defined and default highlights. |

Each value in the `colors` table can be either:
- A **string** — interpreted as a highlight group name to link to (e.g. `"Comment"`)
- A **table** — a highlight definition (same format as `vim.api.nvim_set_hl`, e.g. `{ fg = "#e0af68", bold = true }`)

The `colors` table accepts the following keys:

| Key | Highlight Group | Description |
| --- | --- | --- |
| `Bracket` | `LualineGrappleBracket` | Brackets `[]` (inactive) |
| `BracketActive` | `LualineGrappleBracketActive` | Brackets `[]` (active) |
| `Index` | `LualineGrappleIndex` | Tag index number (inactive) |
| `IndexActive` | `LualineGrappleIndexActive` | Tag index number (active) |
| `Name` | `LualineGrappleName` | Tag filename (inactive) |
| `NameActive` | `LualineGrappleNameActive` | Tag filename (active) |

### Examples

Show 6 tags with custom active colors:

```lua
{ "grapple_tags",
  number_of_tags = 6,
  colors = {
    NameActive = { fg = "#e0af68", bg = "#2e3440", bold = true },
    BracketActive = { fg = "#7aa2f7", bg = "#2e3440" },
    IndexActive = { fg = "#7aa2f7", bg = "#2e3440" },
  },
}
```

Link to existing highlight groups (string shorthand):

```lua
{ "grapple_tags",
  colors = {
    NameActive = "CursorLine",
    Name = "Comment",
  },
}
```

Override all groups with explicit colors:

```lua
{ "grapple_tags",
  colors = {
    Bracket = { fg = "#616161" },
    BracketActive = { fg = "#7aa2f7" },
    Index = { fg = "#616161" },
    IndexActive = { fg = "#7aa2f7" },
    Name = { fg = "#616161" },
    NameActive = { fg = "#e0af68", bold = true },
  },
}
```

## Highlight Groups

The component defines the following highlight groups with sensible defaults. All of them are set with `default = true`, so you can override them in your colorscheme or config and the plugin will not overwrite your settings.

| Highlight Group | Default | Description |
| --- | --- | --- |
| `LualineGrappleBracket` | fg from `Punctuation`, bg from `lualine_c_normal` | Brackets `[]` around the tag index (inactive) |
| `LualineGrappleBracketActive` | fg from `Punctuation`, bg from `Folded` | Brackets `[]` around the tag index (active) |
| `LualineGrappleIndex` | fg from `Number`, bg from `lualine_c_normal` | Tag index number (inactive) |
| `LualineGrappleIndexActive` | fg from `Number`, bg from `Folded` | Tag index number (active) |
| `LualineGrappleName` | links to `lualine_c_normal` | Tag filename (inactive) |
| `LualineGrappleNameActive` | links to `Folded` | Tag filename (active) |

### Overriding highlights

Override any group in your config (after loading your colorscheme):

```lua
vim.api.nvim_set_hl(0, "LualineGrappleNameActive", { fg = "#e0af68", bg = "#2e3440", bold = true })
vim.api.nvim_set_hl(0, "LualineGrappleBracketActive", { fg = "#7aa2f7", bg = "#2e3440" })
```

Colorscheme authors can also define these groups directly and they will be respected.

## How It Works

The component iterates through grapple tag slots 1 through `number_of_tags`. For each slot that has a tag, it renders the tag index and the filename (tail component of the path). The tag corresponding to the current buffer is highlighted differently from the rest, making it easy to see which tag you're on at a glance.

If grapple.nvim is not installed or not loaded, the component silently returns an empty string.
