return {
  'nanozuki/tabby.nvim',
  config = function()
    require('tabby.tabline').use_preset 'tab_only'
  end,
}
