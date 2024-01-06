-- paste an image to markdown from the clipboard
-- :PasteImg,
return {
  'dfendr/clipboard-image.nvim',
  keys = {
    { '<leader>ip', ':PasteImg<cr>', desc = 'image paste' },
  },
  cmd = {
    'PasteImg',
  },
  config = function()
    require('clipboard-image').setup {
      quarto = {
        img_dir = 'img',
        affix = '![](%s)',
      },
    }
  end,
}
