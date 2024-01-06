return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    tag = nil,
    version = nil,
    branch = 'master',
    event = 'BufReadPre',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
      {
        'microsoft/python-type-stubs',
        cond = false,
      },
    },
    config = function()
      -- mason-lspconfig requires that these setup functions are called in this order
      -- before setting up the servers.
      require('mason').setup()

      require('mason-lspconfig').setup {
        automatic_installation = true,
      }

      local lspconfig = require 'lspconfig'
      local util = require 'lspconfig.util'

      -- [[ Configure LSP ]]
      --  This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end

          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
      end

      local on_attach_qmd = function(client, bufnr)
        local function buf_set_keymap(...)
          vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local function buf_set_option(...)
          vim.api.nvim_buf_set_option(bufnr, ...)
        end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
        local opts = { noremap = true, silent = true }

        buf_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<leader>ll', '<cmd>lua vim.lsp.codelens.run()<cr>', opts)
        client.server_capabilities.document_formatting = true
      end

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. They will be passed to
      --  the `settings` field of the server config. You must look up that documentation yourself.
      --
      --  If you want to override the default filetypes that your language server will attach to you can
      --  define the property 'filetypes' to the map in question.
      local servers = {
        -- clangd = {},
        -- gopls = {},
        pyright = { filetypes = { 'python' } },
        -- rust_analyzer = {},
        -- tsserver = {},
        -- html = { filetypes = { 'html', 'twig', 'hbs'} },
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      }

      -- Setup neovim lua configuration
      require('neodev').setup()

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      -- See https://github.com/neovim/neovim/issues/23291
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        automatic_installation = true,
        ensure_installed = vim.tbl_keys(servers),
      }

      mason_lspconfig.setup_handlers {
        function(server_name)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          }
        end,
      }

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require('misc.style').border })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require('misc.style').border })

      -- also needs:
      -- $home/.config/marksman/config.toml :
      -- [core]
      -- markdown.file_extensions = ["md", "markdown", "qmd"]
      lspconfig.marksman.setup {
        on_attach = on_attach_qmd,
        capabilities = capabilities,
        filetypes = { 'markdown', 'quarto' },
        root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
      }

      -- -- another optional language server for grammar and spelling
      -- -- <https://github.com/valentjn/ltex-ls>
      -- lspconfig.ltex.setup {
      --   on_attach = on_attach_qmd,
      --   capabilities = capabilities,
      --   filetypes = { "markdown", "tex", "quarto" },
      -- }

      --  lspconfig.r_language_server.setup {
      --    on_attach = on_attach,
      --    capabilities = capabilities,
      --    flags = lsp_flags,
      --    settings = {
      --      r = {
      --        lsp = {
      --          rich_documentation = false,
      --        },
      --      },
      --    },
      --  }

      lspconfig.cssls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.html.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.emmet_language_server.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.yamlls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = '',
            },
          },
        },
      }

      lspconfig.dotls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      }

      local function strsplit(s, delimiter)
        local result = {}
        for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
          table.insert(result, match)
        end
        return result
      end

      local function get_quarto_resource_path()
        local f = assert(io.popen('quarto --paths', 'r'))
        local s = assert(f:read '*a')
        f:close()
        return strsplit(s, '\n')[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file('', true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once 'quarto not found, lua library files not loaded'
      else
        table.insert(lua_library_files, resource_path .. '/lua-types')
        table.insert(lua_plugin_paths, resource_path .. '/lua-plugin/plugin.lua')
      end

      -- not upadated yet in automatic mason-lspconfig install,
      -- open mason manually with `<space>vm` and `/` search for lua.
      lspconfig.lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = {
              version = 'LuaJIT',
              plugin = lua_plugin_paths,
            },
            diagnostics = {
              globals = { 'vim', 'quarto', 'pandoc', 'io', 'string', 'print', 'require', 'table' },
              disable = { 'trailing-space' },
            },
            workspace = {
              library = lua_library_files,
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too slow on linux for
      -- python projects
      -- where pyright and nvim both create many watchers otherwise
      -- if it is not fixed by
      -- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      -- up top
      -- local ok, wf = pcall(require, "vim.lsp._watchfiles")
      -- if ok then
      --   wf._watchfunc = function()
      --     return function() end
      --   end
      -- end

      lspconfig.pyright.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            stubPath = vim.fn.stdpath 'data' .. '/lazy/python-type-stubs',
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = false,
              diagnosticMode = 'openFilesOnly',
            },
          },
        },
        root_dir = function(fname)
          return util.root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt')(fname) or util.path.dirname(fname)
        end,
      }

      -- lspconfig.jedi_language_server.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   settings = {
      --   },
      --   root_dir = function(fname)
      --     return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(
      --       fname
      --     ) or util.path.dirname(fname)
      --   end,
      -- })

      -- to install pylsp plugins run:
      -- cd ~/.local/share/nvim/mason/packages/python-lsp-server
      -- source venv/bin/activate
      -- pip install mypy
      -- pip install rope
      -- pip install pylsp-rope
      -- pip install python-lsp-black
      -- pip install pylsp-mypy
      --
      -- lspconfig.pylsp.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   settings = {
      --     pylsp = {
      --       configurationSources = {
      --       },
      --       plugins = {
      --         pycodestyle = {
      --           ignore = {
      --             'W391',
      --             'W292', -- no blank line after file
      --             'E303', -- blank lines in otter document
      --             'E302', -- blank lines in otter document
      --             'E305', -- blank lines in otter document
      --             'E111', -- indentation is not a multiple of four
      --             'E265', -- magic comments
      --             'E402', -- imports not at top
      --             'E741', -- ambiguous variable name
      --           },
      --           maxLineLength = 120
      --         },
      --         black = {
      --           enabled = true
      --         },
      --         mypy = {
      --           enabled = true,
      --           dmypy = true,
      --           live_mode = false,
      --         },
      --         rope = {
      --
      --         },
      --       }
      --     }
      --   },
      --   root_dir = function(fname)
      --     return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(
      --       fname
      --     ) or util.path.dirname(fname)
      --   end,
      -- })

      lspconfig.julials.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.bashls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'sh', 'bash' },
      }

      -- Add additional languages here.
      -- See `:h lspconfig-all` for the configuration.
      -- Like e.g. Haskell:
      -- lspconfig.hls.setup {
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   flags = lsp_flags
      -- }

      -- lspconfig.rust_analyzer.setup{
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     ['rust-analyzer'] = {
      --       diagnostics = {
      --         enable = false;
      --       }
      --     }
      --   }
      -- }
    end,
  },
}
