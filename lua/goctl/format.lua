local M = {}

---@class FormatResult
---@field success boolean
---@field output string?
---@field error string?

---Format the current buffer using goctl api format
---@return FormatResult
M.format = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)

  if filename == "" then
    vim.notify("Cannot format unnamed buffer", vim.log.levels.WARN, { title = "goctl" })
    return { success = false, error = "unnamed buffer" }
  end

  local config = require("goctl").config
  local goctl_path = config.goctl_path or "goctl"

  -- Get buffer content
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Run goctl api format with stdin
  local cmd = { goctl_path, "api", "format", "-iu", "-dir", filename, "--stdin" }

  local result = vim
    .system(cmd, {
      stdin = content,
      text = true,
      timeout = 5000,
    })
    :wait()

  if result.code ~= 0 then
    local err = result.stderr or "Unknown error"
    M.handle_format_error(bufnr, err)
    return { success = false, error = err }
  end

  -- Apply formatted content
  if result.stdout and result.stdout ~= "" then
    -- Clear existing diagnostics
    vim.diagnostic.reset(vim.api.nvim_create_namespace("goctl"), bufnr)

    -- Save cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)

    -- Replace buffer content
    local formatted_lines = vim.split(result.stdout, "\n", { plain = true })
    -- Remove trailing empty line if present
    if formatted_lines[#formatted_lines] == "" then
      table.remove(formatted_lines)
    end

    -- Remove "struct" keyword from empty type definitions if configured
    if config.remove_struct_keyword then
      formatted_lines = M.remove_struct_keyword(formatted_lines)
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)

    -- Restore cursor position (clamped to valid range)
    local new_line_count = vim.api.nvim_buf_line_count(bufnr)
    cursor[1] = math.min(cursor[1], new_line_count)
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)

    return { success = true, output = result.stdout }
  end

  return { success = true }
end

---Handle format errors and display diagnostics
---@param bufnr number
---@param error_output string
M.handle_format_error = function(bufnr, error_output)
  local namespace = vim.api.nvim_create_namespace("goctl")
  local diagnostics = {}

  for line in error_output:gmatch("[^\n]+") do
    if line:match("%S") then
      local parsed = M.parse_error(line)
      if parsed then
        table.insert(diagnostics, {
          lnum = parsed.line - 1,
          col = parsed.col,
          severity = vim.diagnostic.severity.ERROR,
          source = "goctl",
          message = parsed.message,
        })
      end
    end
  end

  vim.diagnostic.set(namespace, bufnr, diagnostics)

  if #diagnostics == 0 then
    vim.notify("goctl format error: " .. error_output, vim.log.levels.ERROR, { title = "goctl" })
  end
end

---Remove "struct" keyword from type definitions
---Converts "TypeName struct {" to "TypeName {"
---@param lines string[]
---@return string[]
M.remove_struct_keyword = function(lines)
  local result = {}
  for _, line in ipairs(lines) do
    -- Match "TypeName struct {" or "TypeName struct{}" patterns
    local modified = line:gsub("(%s*)(%w+)%s+struct%s*({)", "%1%2 %3")
    table.insert(result, modified)
  end
  return result
end

---Parse error line from goctl output
---@param line string
---@return {line: number, col: number, message: string}?
M.parse_error = function(line)
  -- Format: "error filename.api 10:5 error message here"
  local line_num, col, msg = line:match("(%d+):(%d+)%s+(.+)")
  if line_num then
    return {
      line = tonumber(line_num) or 1,
      col = tonumber(col) or 0,
      message = msg or line,
    }
  end

  -- Fallback: try to extract any error message
  local simple_line, simple_msg = line:match("(%d+):%s*(.+)")
  if simple_line then
    return {
      line = tonumber(simple_line) or 1,
      col = 0,
      message = simple_msg or line,
    }
  end

  return nil
end

return M
