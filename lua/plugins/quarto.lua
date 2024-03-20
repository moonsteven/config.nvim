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
