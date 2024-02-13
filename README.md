# blame-me.nvim

A lean git blame plugin for neovim.

![demo](assets/demo.gif?raw=true)

## Usage

blame-me.nvim _should_ work out of the box. Simply install it using your package manager of choice:

### Lazy

```lua
local blame_me_plugin = {
  'hougesen/blame-me.nvim',
  opts = {
    -- your options here
  },
}
```

## Available options

| Name       | Default                             | Description                                                    |
| ---------- | ----------------------------------- | -------------------------------------------------------------- |
| modes      | {'n'}                               | Modes plugin is enabled for                                    |
| delay      | 1000                                | Amount of milliseconds to wait before showing line information |
| show_on    | `{ 'CursorHold', 'CursorHoldI' }`   | List of events to show line information on                     |
| hide_on    | `{ 'CursorMoved', 'CursorMovedI' }` | List of events to hide line information on                     |
| refresh_on | `{ 'BufEnter', 'BufWritePost' }`    | List of events to fresh commit information on                  |
| signs      | `true`                              | Whether to set `M` sign                                        |
