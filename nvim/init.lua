-- Workaround for https://github.com/nvim-treesitter/nvim-treesitter/issues/8618
-- Neovim 0.12 changed some query matches to return a list of nodes instead of
-- a single node; some plugins/directives haven't caught up and pass nil nodes
-- into get_node_text(), which crashes. Make it defensive instead of erroring.
local orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  if not node then return "" end
  local ok, result = pcall(orig_get_node_text, node, source, opts)
  if ok then return result end
  return ""
end
-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- make mason-managed tools (stylua, shfmt, ruff, yaml-language-server, tree-sitter, ...)
-- resolvable by conform.nvim, language servers and shell commands
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin:" .. vim.env.PATH

vim.api.nvim_create_augroup("neotree_autoopen", { clear = true })
vim.api.nvim_create_autocmd("BufRead", {
  desc = "Open neo-tree on enter",
  group = "neotree_autoopen",
  once = true,
  callback = function(args)
    if not vim.g.neotree_opened then
      vim.g.neotree_opened = true
      vim.schedule(function()
        vim.cmd "Neotree show"
        local file_win = vim.fn.bufwinid(args.buf)
        if file_win ~= -1 then vim.api.nvim_set_current_win(file_win) end
      end)
    end
  end,
})
--[[ A bit annoying 
vim.api.nvim_create_augroup("toggleterm_autoopen", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open ToggleTerm on startup",
  group = "toggleterm_autoopen",
  callback = function() vim.cmd "ToggleTerm" end,
})
]]
