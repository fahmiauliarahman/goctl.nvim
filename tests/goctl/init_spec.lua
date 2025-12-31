local goctl = require("goctl")

describe("goctl", function()
  before_each(function()
    -- Reset config before each test
    goctl.config = {
      format_on_save = true,
      goctl_path = "goctl",
      enable_snippets = true,
      enable_keymaps = true,
    }
  end)

  describe("setup", function()
    it("works with default config", function()
      goctl.setup()
      assert.is_true(goctl.config.format_on_save)
      assert.equals("goctl", goctl.config.goctl_path)
      assert.is_true(goctl.config.enable_snippets)
      assert.is_true(goctl.config.enable_keymaps)
    end)

    it("merges custom config", function()
      goctl.setup({
        format_on_save = false,
        goctl_path = "/custom/path/goctl",
      })
      assert.is_false(goctl.config.format_on_save)
      assert.equals("/custom/path/goctl", goctl.config.goctl_path)
      assert.is_true(goctl.config.enable_snippets)
    end)

    it("disables snippets when configured", function()
      goctl.setup({ enable_snippets = false })
      assert.is_false(goctl.config.enable_snippets)
    end)

    it("disables keymaps when configured", function()
      goctl.setup({ enable_keymaps = false })
      assert.is_false(goctl.config.enable_keymaps)
    end)

    it("registers .api filetype", function()
      goctl.setup()
      -- After setup, .api files should be recognized as goctl filetype
      local ft = vim.filetype.match({ filename = "test.api" })
      assert.equals("goctl", ft)
    end)
  end)
end)
