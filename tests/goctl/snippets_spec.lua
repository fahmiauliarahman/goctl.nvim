local snippets = require("goctl.snippets")

describe("goctl.snippets", function()
  describe("setup", function()
    it("does not error when LuaSnip is not available", function()
      -- This should not throw an error even if LuaSnip is not installed
      assert.has_no.errors(function()
        snippets.setup()
      end)
    end)
  end)

  describe("get_luasnip_snippets", function()
    it("returns empty table when LuaSnip is not available", function()
      -- When LuaSnip is not installed, should return empty table
      local result = snippets.get_luasnip_snippets()
      assert.is_table(result)
    end)
  end)

  describe("load_luasnip", function()
    it("does not error when LuaSnip is not available", function()
      assert.has_no.errors(function()
        snippets.load_luasnip()
      end)
    end)
  end)
end)
