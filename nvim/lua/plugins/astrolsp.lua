-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      helm_ls = {
        settings = {
          ["helm-ls"] = {
            -- helm_ls shells out to yamlls; point it at the mason binary since mason/bin is not on PATH
            yamlls = {
              path = vim.fn.stdpath "data" .. "/mason/bin/yaml-language-server",
            },
          },
        },
      },
      pyright = {
        before_init = function(params, config)
          local bufname = vim.api.nvim_buf_get_name(0)
          local start = config.root_dir
            or (params.rootUri and vim.uri_to_fname(params.rootUri))
            or (bufname ~= "" and vim.fs.dirname(bufname))
            or vim.fn.getcwd()
          local root =
            require("lspconfig.util").root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git")(start)
          if root then
            local venv = root .. "/.venv/bin/python"
            if vim.fn.executable(venv) == 1 then
              config.settings.python.pythonPath = venv
              local site_packages = vim.fn.glob(root .. "/.venv/lib/python3.*/site-packages", false, true)[1]
              if site_packages then
                local extra_paths = { site_packages }
                -- editable installs (uv/pip finder style) use a runtime import hook
                -- that pyright cannot resolve statically; add their source roots
                for _, finder in ipairs(vim.fn.glob(site_packages .. "/__editable___*_finder.py", false, true)) do
                  local content = table.concat(vim.fn.readfile(finder), "\n")
                  local mapping = content:match "MAPPING[^=]*=%s*(%b{})"
                  if mapping then
                    for path in mapping:gmatch "['\"]([^'\"]+)['\"]" do
                      if vim.startswith(path, "/") and vim.fn.isdirectory(path) == 1 then
                        table.insert(extra_paths, vim.fs.dirname(path))
                      end
                    end
                  end
                end
                config.settings.python.analysis.extraPaths = extra_paths
              end
            end
          end
        end,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            }
          }
        }
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- format on save is handled by conform.nvim; disable AstroNvim's LSP based autoformat
      lsp_auto_format = false,
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
      -- organize/sort imports on save using Ruff
      ruff_organize_imports = {
        cond = function(client) return client.name == "ruff" end,
        {
          event = "BufWritePre",
          desc = "Organize imports on save (Ruff)",
          callback = function(args)
            local client = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })[1]
            if not client then return end

            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { only = { "source.organizeImports.ruff" }, diagnostics = {} }

            local result = client:request_sync("textDocument/codeAction", params, 1000, args.buf)
            if not result or not result.result or vim.tbl_isempty(result.result) then return end

            for _, action in ipairs(result.result) do
              -- resolve the action if it doesn't already have an edit
              if not action.edit and client.supports_method and client:supports_method "codeAction/resolve" then
                local resolved = client:request_sync("codeAction/resolve", action, 1000, args.buf)
                if resolved and resolved.result then action = resolved.result end
              end

              if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
              elseif action.command then
                client:exec_cmd(action.command, { bufnr = args.buf })
              end
            end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
        ["<Leader>uF"] = {
          function()
            local enabled = vim.g.autoformat ~= false
            vim.g.autoformat = not enabled
            require("astrocore").notify(("Global autoformatting %s"):format(enabled and "off" or "on"))
          end,
          desc = "Toggle autoformatting (global)",
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
