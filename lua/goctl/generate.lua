local M = {}

---Generate code from .api file
---@param args string
M.generate = function(args)
  local filename = vim.api.nvim_buf_get_name(0)

  if filename == "" or not filename:match("%.api$") then
    vim.notify("Not a .api file", vim.log.levels.WARN, { title = "goctl" })
    return
  end

  local config = require("goctl").config
  local goctl_path = config.goctl_path or "goctl"

  -- Get the directory of the current file
  local dir = vim.fn.fnamemodify(filename, ":h")

  -- Default generate command: goctl api go -api file.api -dir .
  local cmd = { goctl_path, "api", "go", "-api", filename, "-dir", dir }

  -- If additional args provided, use them
  if args and args ~= "" then
    cmd = { goctl_path, "api" }
    for arg in args:gmatch("%S+") do
      table.insert(cmd, arg)
    end
    table.insert(cmd, "-api")
    table.insert(cmd, filename)
  end

  vim.notify("Running: " .. table.concat(cmd, " "), vim.log.levels.INFO, { title = "goctl" })

  vim.system(cmd, {
    text = true,
    timeout = 30000,
  }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Code generated successfully", vim.log.levels.INFO, { title = "goctl" })
      else
        local err = result.stderr or "Unknown error"
        vim.notify("Generation failed: " .. err, vim.log.levels.ERROR, { title = "goctl" })
      end
    end)
  end)
end

return M
