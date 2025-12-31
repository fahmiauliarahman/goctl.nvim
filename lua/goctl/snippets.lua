local M = {}

---Setup snippets for goctl filetype
---Works with LuaSnip and nvim-cmp
M.setup = function()
  -- Check if LuaSnip is available
  local has_luasnip, luasnip = pcall(require, "luasnip")
  if not has_luasnip then
    return
  end

  -- Load JSON snippets using LuaSnip's VSCode loader
  local has_loader, loader = pcall(require, "luasnip.loaders.from_vscode")
  if has_loader then
    -- Get the path to our snippets directory
    local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
    local snippets_path = plugin_path .. "/snippets"

    loader.load({ paths = { snippets_path } })
  end
end

---Create LuaSnip snippets programmatically (alternative to JSON)
---@return table[]
M.get_luasnip_snippets = function()
  local has_luasnip, ls = pcall(require, "luasnip")
  if not has_luasnip then
    return {}
  end

  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local c = ls.choice_node
  local fmt = require("luasnip.extras.fmt").fmt

  return {
    s(
      "info",
      fmt(
        [[
info(
	title: {}
	desc: {}
	author: {}
	email: {}
	version: {}
)

{}
]],
        { i(1, "title"), i(2, "description"), i(3, "author"), i(4, "email"), i(5, "1.0"), i(0) }
      )
    ),

    s(
      "service",
      fmt(
        [[
service {}-api {{
	{}
}}
]],
        { i(1, "name"), i(0) }
      )
    ),

    s(
      "type",
      fmt(
        [[
type {} {{
	{}
}}
]],
        { i(1, "Name"), i(0) }
      )
    ),

    s(
      "tys",
      fmt(
        [[
type {} struct {{
	{}
}}
]],
        { i(1, "Name"), i(0) }
      )
    ),

    s(
      "handler",
      fmt(
        [[
@doc(
	summary: {}
)
@handler {}
{} /{}({}) returns({})

{}
]],
        {
          i(1, "description"),
          i(2, "handlerName"),
          c(3, { t("get"), t("post"), t("put"), t("delete"), t("patch") }),
          i(4, "path"),
          i(5, "Request"),
          i(6, "Response"),
          i(0),
        }
      )
    ),

    s(
      "@doc",
      fmt(
        [[
@doc(
	summary: {}
)
{}
]],
        { i(1, "description"), i(0) }
      )
    ),

    s(
      "@server",
      fmt(
        [[
@server(
	handler: {}
)
{}
]],
        { i(1, "HandlerName"), i(0) }
      )
    ),

    s("@handler", fmt("@handler {}", { i(1, "handlerName") })),

    s("get", fmt("get /{}({}) returns({})", { i(1, "path"), i(2, "Request"), i(3, "Response") })),
    s("post", fmt("post /{}({}) returns({})", { i(1, "path"), i(2, "Request"), i(3, "Response") })),
    s("put", fmt("put /{}({}) returns({})", { i(1, "path"), i(2, "Request"), i(3, "Response") })),
    s("delete", fmt("delete /{}({}) returns({})", { i(1, "path"), i(2, "Request"), i(3, "Response") })),
    s("patch", fmt("patch /{}({}) returns({})", { i(1, "path"), i(2, "Request"), i(3, "Response") })),

    s("json", fmt('`json:"{}"`', { i(1, "field") })),
    s("path", fmt('`path:"{}"`', { i(1, "param") })),
    s("form", fmt('`form:"{}"`', { i(1, "field") })),

    s(
      "jwt",
      fmt(
        [[
@server(
	jwt: {}
)
{}
]],
        { i(1, "Auth"), i(0) }
      )
    ),

    s(
      "group",
      fmt(
        [[
@server(
	prefix: {}
	group: {}
)
{}
]],
        { i(1, "/api/v1"), i(2, "groupName"), i(0) }
      )
    ),

    s("im", fmt('import "{}"', { i(1, "package") })),
  }
end

---Load snippets into LuaSnip
M.load_luasnip = function()
  local has_luasnip, ls = pcall(require, "luasnip")
  if not has_luasnip then
    return
  end

  ls.add_snippets("goctl", M.get_luasnip_snippets())
end

return M
