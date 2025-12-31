local M = {}

M.setup = function()
  vim.api.nvim_create_user_command("GoctlFormat", function()
    require("goctl.format").format()
  end, { desc = "Format goctl .api file" })

  vim.api.nvim_create_user_command("GoctlGenerate", function(opts)
    require("goctl.generate").generate(opts.args)
  end, {
    desc = "Generate code from .api file",
    nargs = "*",
  })
end

return M
