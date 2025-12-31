local generate = require("goctl.generate")

describe("goctl.generate", function()
  describe("generate", function()
    it("warns when not an .api file", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "/tmp/test.lua")
      vim.api.nvim_set_current_buf(buf)

      local notified = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        if msg == "Not a .api file" then
          notified = true
        end
      end

      generate.generate("")

      vim.notify = original_notify
      vim.api.nvim_buf_delete(buf, { force = true })

      assert.is_true(notified)
    end)

    it("warns when buffer is unnamed", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)

      local notified = false
      local original_notify = vim.notify
      vim.notify = function(msg, level)
        if msg == "Not a .api file" then
          notified = true
        end
      end

      generate.generate("")

      vim.notify = original_notify
      vim.api.nvim_buf_delete(buf, { force = true })

      assert.is_true(notified)
    end)
  end)
end)
