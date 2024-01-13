return {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup()
  end,
  requires = { 'nvim-treesitter/nvim-treesitter' },
}
