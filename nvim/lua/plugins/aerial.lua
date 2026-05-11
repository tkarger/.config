return {
  "stevearc/aerial.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("aerial").setup {
      -- Priority list of backends to use for symbols
      backends = { "lsp", "markdown", "man" },

      layout = {
        -- These control the width of the aerial window
        max_width = { 40, 0.2 },
        min_width = 20,
        default_direction = "right",
      },

      -- Determines how the aerial window decides which section to focus on
      update_events = "TextChanged,InsertLeave",

      -- Show icons next to symbols
      show_icons = true,

      -- Keymaps inside the aerial window
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    }

    -- Global Keybindings
    vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle! right<CR>", { desc = "Toggle Outline" })
  end,
}
