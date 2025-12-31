if vim.g.loaded_goctl then
  return
end
vim.g.loaded_goctl = true

-- Ensure the filetype is registered even without setup
vim.filetype.add({
  extension = {
    api = "goctl",
  },
})
