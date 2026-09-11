-- none-ls is disabled: formatting is handled by conform.nvim and
-- diagnostics/hover by the language servers (bashls, pyright, ruff, ...)

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
}
