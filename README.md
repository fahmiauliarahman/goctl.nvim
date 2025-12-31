# goctl.nvim

A Neovim plugin for [go-zero](https://github.com/zeromicro/go-zero) `.api` file support.

## Features

- Syntax highlighting for `.api` files
- Format on save using `goctl api format`
- Go-to-definition and find references
- Code snippets (LuaSnip integration)
- Code generation command

## Requirements

- Neovim >= 0.9.0
- [goctl](https://github.com/zeromicro/go-zero) installed and in PATH
- (Optional) [LuaSnip](https://github.com/L3MON4D3/LuaSnip) for snippets

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "fahmiauliarahman/goctl.nvim",
  ft = { "goctl", "api" },
  opts = {
    format_on_save = true,
    goctl_path = "goctl",
    enable_snippets = true,
    enable_keymaps = true,
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "fahmiauliarahman/goctl.nvim",
  config = function()
    require("goctl").setup()
  end,
}
```

## Configuration

Default configuration:

```lua
require("goctl").setup({
  -- Enable format on save
  format_on_save = true,
  -- Path to goctl binary
  goctl_path = "goctl",
  -- Enable snippets (requires LuaSnip)
  enable_snippets = true,
  -- Enable default keymaps (gd, gr)
  enable_keymaps = true,
})
```

## Commands

| Command          | Description                           |
| ---------------- | ------------------------------------- |
| `:GoctlFormat`   | Format the current `.api` file        |
| `:GoctlGenerate` | Generate Go code from the `.api` file |

## Keymaps

When `enable_keymaps` is true, the following keymaps are available in `.api` files:

| Keymap | Description      |
| ------ | ---------------- |
| `gd`   | Go to definition |
| `gr`   | Find references  |

## Snippets

Available snippets (prefix → expansion):

| Prefix         | Description             |
| -------------- | ----------------------- |
| `info`         | API info block          |
| `service`      | Service definition      |
| `type` / `tys` | Type/struct definition  |
| `handler`      | Route handler with doc  |
| `@doc`         | Doc annotation          |
| `@server`      | Server annotation       |
| `@handler`     | Handler annotation      |
| `get`          | GET endpoint            |
| `post`         | POST endpoint           |
| `put`          | PUT endpoint            |
| `delete`       | DELETE endpoint         |
| `patch`        | PATCH endpoint          |
| `json`         | JSON tag                |
| `path`         | Path tag                |
| `form`         | Form tag                |
| `jwt`          | JWT middleware          |
| `group`        | Route group with prefix |
| `im`           | Import statement        |

## Example `.api` file

```
info(
    title: User API
    desc: User management API
    author: Your Name
    email: your@email.com
    version: 1.0
)

type (
    LoginRequest {
        Username string `json:"username"`
        Password string `json:"password"`
    }

    LoginResponse {
        Token string `json:"token"`
    }
)

@server(
    prefix: /api/v1
)
service user-api {
    @doc(
        summary: User login
    )
    @handler LoginHandler
    post /login(LoginRequest) returns(LoginResponse)
}
```

## License

MIT
