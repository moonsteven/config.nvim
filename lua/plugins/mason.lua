local mason = {
  'williamboman/mason.nvim',
  opts = {
    ensure_installed = {
      'black',
      'debugpy',
      'mypy',
      'ruff',
      'pyright',
      'stylua',
    },
  },
}

return mason
