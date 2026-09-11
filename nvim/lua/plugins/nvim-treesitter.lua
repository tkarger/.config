-- Additional treesitter parsers beyond the AstroNvim defaults
-- (highlighting, indenting and textobjects are configured by AstroNvim core)

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "helm", "yaml" },
  },
}
