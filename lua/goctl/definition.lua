local M = {}

---@enum CodeLineType
local CodeLineType = {
  Type = 1,
  InType = 2,
  Url = 3,
  None = 4,
}

---Get regex pattern for type definition
---@param target string
---@return string
local function rex_type(target)
  return "(type)?%s*%f[%w]" .. vim.pesc(target) .. "%f[%W]%s*(struct)?%s*{"
end

---Get regex pattern for in-type usage (field types)
---@param target string
---@return string
local function rex_in_type(target)
  return "[%*%[%]]*%f[%w]" .. vim.pesc(target) .. "%f[%W]%s*`[json|form|path]"
end

---Get regex pattern for URL return type
---@param target string
---@return string
local function rex_url_return(target)
  return "returns%s*%(%s*%f[%w]" .. vim.pesc(target) .. "%f[%W]%s*%)"
end

---Get regex pattern for URL method parameter
---@param target string
---@return string
local function rex_url_method(target)
  return "%(%s*%f[%w]" .. vim.pesc(target) .. "%f[%W]%s*%)"
end

---Determine the line type based on context
---@param line string
---@param target string
---@return CodeLineType
local function match_line_type(line, target)
  if
    line:match("type%s+" .. vim.pesc(target) .. "%s*struct") or line:match("type%s+" .. vim.pesc(target) .. "%s*{")
  then
    return CodeLineType.Type
  elseif line:match("[%*%[%]]*" .. vim.pesc(target) .. "%s*`") then
    return CodeLineType.InType
  elseif
    line:match("returns%s*%(" .. vim.pesc(target) .. "%s*%)")
    or line:match("%(" .. vim.pesc(target) .. "%s*%)%s*returns")
    or line:match("%(%s*" .. vim.pesc(target) .. "%s*%)$")
  then
    return CodeLineType.Url
  end
  return CodeLineType.None
end

---Find the position of target word in a line
---@param line string
---@param target string
---@return number? col 0-indexed column
local function find_target_position(line, target)
  local start_pos = line:find(target, 1, true)
  if start_pos then
    return start_pos - 1
  end
  return nil
end

---Find type definition locations
---@param bufnr number
---@param target string
---@param current_line number
---@return table[] locations
local function find_type_definitions(bufnr, target, current_line)
  local locations = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for line_idx, line in ipairs(lines) do
    if line_idx - 1 ~= current_line then
      -- Match type definition patterns:
      -- "type TypeName struct {" or "type TypeName {"
      -- "type TypeName" (empty type, possibly with trailing whitespace)
      -- "TypeName {" inside type() block
      local escaped = vim.pesc(target)
      if
        line:match("type%s+" .. escaped .. "%s*struct")
        or line:match("type%s+" .. escaped .. "%s*{")
        or line:match("type%s+" .. escaped .. "%s*$")
        or line:match("^%s+" .. escaped .. "%s*{")
        or line:match("^%s+" .. escaped .. "%s*$")
      then
        local col = find_target_position(line, target)
        if col then
          table.insert(locations, {
            bufnr = bufnr,
            lnum = line_idx,
            col = col + 1,
            filename = vim.api.nvim_buf_get_name(bufnr),
          })
        end
      end
    end
  end

  return locations
end

---Find usages of a type (in fields and URL definitions)
---@param bufnr number
---@param target string
---@param current_line number
---@return table[] locations
local function find_type_usages(bufnr, target, current_line)
  local locations = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filename = vim.api.nvim_buf_get_name(bufnr)

  for line_idx, line in ipairs(lines) do
    if line_idx - 1 ~= current_line then
      -- Field usage: "FieldName *TypeName `json:..."
      if line:match("[%*%[%]]*" .. vim.pesc(target) .. "%s*`") then
        local col = find_target_position(line, target)
        if col then
          table.insert(locations, {
            bufnr = bufnr,
            lnum = line_idx,
            col = col + 1,
            filename = filename,
          })
        end
      -- URL request parameter: "(TypeName)"
      elseif line:match("%(%s*" .. vim.pesc(target) .. "%s*%)") then
        local col = find_target_position(line, target)
        if col then
          table.insert(locations, {
            bufnr = bufnr,
            lnum = line_idx,
            col = col + 1,
            filename = filename,
          })
        end
      -- URL return type: "returns(TypeName)"
      elseif line:match("returns%s*%(%s*" .. vim.pesc(target) .. "%s*%)") then
        local col = find_target_position(line, target)
        if col then
          table.insert(locations, {
            bufnr = bufnr,
            lnum = line_idx,
            col = col + 1,
            filename = filename,
          })
        end
      end
    end
  end

  return locations
end

---Go to definition handler
---@return table[]? locations
M.goto_definition = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_idx = cursor[1]
  local col = cursor[2]

  -- Get the word under cursor
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    return nil
  end

  local line = vim.api.nvim_buf_get_lines(bufnr, line_idx - 1, line_idx, false)[1]
  local line_type = match_line_type(line, word)

  local locations = {}

  if line_type == CodeLineType.Type then
    -- On a type definition, find usages
    locations = find_type_usages(bufnr, word, line_idx - 1)
  elseif line_type == CodeLineType.InType or line_type == CodeLineType.Url then
    -- On a type usage, find definition
    locations = find_type_definitions(bufnr, word, line_idx - 1)
  else
    -- Try to find definitions anyway
    locations = find_type_definitions(bufnr, word, line_idx - 1)
    if #locations == 0 then
      locations = find_type_usages(bufnr, word, line_idx - 1)
    end
  end

  return locations
end

---Go to definition and jump to location
M.jump_to_definition = function()
  local locations = M.goto_definition()

  if not locations or #locations == 0 then
    vim.notify("No definition found", vim.log.levels.INFO, { title = "goctl" })
    return
  end

  if #locations == 1 then
    local loc = locations[1]
    vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col - 1 })
  else
    -- Multiple locations, use quickfix list
    vim.fn.setqflist(locations)
    vim.cmd("copen")
  end
end

---Go to type definition (find the type of the field under cursor)
---@return table[]? locations
M.goto_type_definition = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_idx = cursor[1]

  -- Use word under cursor for URL patterns and field types
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    vim.notify("No type found under cursor", vim.log.levels.INFO, { title = "goctl" })
    return nil
  end

  local locations = find_type_definitions(bufnr, word, line_idx - 1)
  return locations
end

---Jump to type definition
M.jump_to_type_definition = function()
  local locations = M.goto_type_definition()

  if not locations or #locations == 0 then
    vim.notify("No type definition found", vim.log.levels.INFO, { title = "goctl" })
    return
  end

  if #locations == 1 then
    local loc = locations[1]
    vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col - 1 })
  else
    vim.fn.setqflist(locations)
    vim.cmd("copen")
  end
end

---Setup keymaps for definition navigation
M.setup_keymaps = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "goctl",
    callback = function(args)
      local bufnr = args.buf
      vim.keymap.set("n", "gd", function()
        M.jump_to_definition()
      end, { buffer = bufnr, desc = "Go to definition" })

      vim.keymap.set("n", "gr", function()
        M.jump_to_references()
      end, { buffer = bufnr, desc = "Find references" })

      vim.keymap.set("n", "gy", function()
        M.jump_to_type_definition()
      end, { buffer = bufnr, desc = "Go to type definition" })
    end,
  })
end

---Find all references of word under cursor
---@return table[]? locations
M.find_references = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local word = vim.fn.expand("<cword>")
  if not word or word == "" then
    return nil
  end

  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local locations = find_type_usages(bufnr, word, current_line)
  local defs = find_type_definitions(bufnr, word, current_line)
  vim.list_extend(locations, defs)

  return locations
end

---Jump to references
M.jump_to_references = function()
  local locations = M.find_references()

  if not locations or #locations == 0 then
    vim.notify("No references found", vim.log.levels.INFO, { title = "goctl" })
    return
  end

  vim.fn.setqflist(locations)
  vim.cmd("copen")
end

return M
