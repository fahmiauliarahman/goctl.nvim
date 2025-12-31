---@class GoctlConfig
---@field format_on_save boolean Enable format on save
---@field goctl_path string Path to goctl binary
---@field enable_snippets boolean Enable snippets
---@field enable_keymaps boolean Enable default keymaps (gd, gr)
local config = {
  format_on_save = true,
  goctl_path = "goctl",
  enable_snippets = true,
  enable_keymaps = true,
}

---@class Goctl
local M = {}

---@type GoctlConfig
M.config = config

---@param opts GoctlConfig?
M.setup = function(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Register .api filetype
  vim.filetype.add({
    extension = {
      api = "goctl",
    },
  })

  -- Setup format on save if enabled
  if M.config.format_on_save then
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.api",
      callback = function()
        require("goctl.format").format()
      end,
    })
  end

  -- Setup commands
  require("goctl.commands").setup()

  -- Setup keymaps for definition navigation
  if M.config.enable_keymaps then
    require("goctl.definition").setup_keymaps()
  end

  -- Setup snippets
  if M.config.enable_snippets then
    require("goctl.snippets").setup()
    require("goctl.snippets").load_luasnip()
  end
end

return M
