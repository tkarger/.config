-- only format with prettier when the file's project actually configures it,
-- so project rules (.prettierrc) are respected and other files stay untouched
local function project_prettier(bufnr)
  if
    vim.fs.root(bufnr, {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.jsonc",
      ".prettierrc.yaml",
      ".prettierrc.yml",
      ".prettierrc.toml",
      "prettier.config.js",
      "prettier.config.mjs",
      "prettier.config.cjs",
    })
  then
    return { "prettier" }
  end
  return {}
end

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile", "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>f",
      function() require("conform").format { async = true } end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      sh = { "shfmt" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      yaml = project_prettier,
      markdown = project_prettier,
      json = project_prettier,
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    -- Import organization for Python is done by the `ruff_organize_imports`
    -- autocmd in astrolsp.lua, so only the formatter runs here.
    -- Respects the `<Leader>uf` (buffer) and `<Leader>uF` (global) toggles.
    format_on_save = function(bufnr)
      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then return end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
