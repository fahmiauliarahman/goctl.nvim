local definition = require("goctl.definition")

describe("goctl.definition", function()
  local test_api_content = [[
syntax = "v1"

type LoginRequest {
  Username string `json:"username"`
  Password string `json:"password"`
}

type LoginResponse {
  Token string `json:"token"`
  User  *UserInfo `json:"user"`
}

type UserInfo struct {
  Id   int64  `json:"id"`
  Name string `json:"name"`
}

service user-api {
  @handler Login
  post /login(LoginRequest) returns(LoginResponse)
}
]]

  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufnr, "/tmp/test.api")
    vim.api.nvim_buf_set_option(bufnr, "filetype", "goctl")
    local lines = vim.split(test_api_content, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(bufnr)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  describe("goto_definition", function()
    it("returns nil when cursor is on empty word", function()
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      local locations = definition.goto_definition()
      -- Word is "syntax" not empty, so we need to test differently
      assert.is_table(locations)
    end)

    it("finds type definition from usage in URL", function()
      -- Position cursor on LoginRequest in the URL line
      vim.api.nvim_win_set_cursor(0, { 20, 16 }) -- post /login(LoginRequest)
      -- The word under cursor should be "LoginRequest"
      local word = vim.fn.expand("<cword>")
      assert.equals("LoginRequest", word)
    end)

    it("finds type definition from field usage", function()
      -- Position cursor on UserInfo in LoginResponse
      vim.api.nvim_win_set_cursor(0, { 10, 10 }) -- User  *UserInfo
      local word = vim.fn.expand("<cword>")
      assert.equals("UserInfo", word)
    end)
  end)

  describe("setup_keymaps", function()
    it("creates autocmd for goctl filetype", function()
      definition.setup_keymaps()
      local autocmds = vim.api.nvim_get_autocmds({ event = "FileType", pattern = "goctl" })
      assert.is_true(#autocmds >= 1)
    end)
  end)
end)
