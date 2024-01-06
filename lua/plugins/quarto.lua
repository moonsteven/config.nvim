local plugins = {
  -- Quarto configs
  {
    'quarto-dev/quarto-nvim',
    dependencies = {
      { 'hrsh7th/nvim-cmp' },
      {
        'jmbuhr/otter.nvim',
        config = function()
          require('otter').setup {
            lsp = {
              hover = {
                border = require('misc.style').border,
              },
            },
          }
        end,
      },

      -- optional
      -- { 'quarto-dev/quarto-vim',
      --   ft = 'quarto',
      --   dependencies = { 'vim-pandoc/vim-pandoc-syntax' },
      --   -- note: needs additional syntax highlighting enabled for markdown
      --   --       in `nvim-treesitter`
      --   config = function()
      -- conceal can be tricky because both
      -- the treesitter highlighting and the
      -- regex vim syntax files can define conceals
      --
      -- -- see `:h conceallevel`
      -- vim.opt.conceallevel = 1
      --
      -- -- disable conceal in markdown/quarto
      -- vim.g['pandoc#syntax#conceal#use'] = false
      --
      -- -- embeds are already handled by treesitter injectons
      -- vim.g['pandoc#syntax#codeblocks#embeds#use'] = false
      -- vim.g['pandoc#syntax#conceal#blacklist'] = { 'codeblock_delim', 'codeblock_start' }
      --
      -- -- but allow some types of conceal in math regions:
      -- -- see `:h g:tex_conceal`
      -- vim.g['tex_conceal'] = 'gm'
      -- --   end
      -- },
    },
    config = function()
      require('quarto').setup {
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          languages = { 'r', 'python', 'julia', 'bash', 'lua' },
          chunks = 'curly', -- 'curly' or 'all'
          diagnostics = {
            enabled = true,
            triggers = { 'BufWritePost' },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = 'K',
          definition = 'gd',
        },
      }
    end,
  },
}

return plugins
