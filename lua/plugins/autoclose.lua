return {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup()
  end,
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
}
