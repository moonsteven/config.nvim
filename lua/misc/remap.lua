-- Move block up and down together
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Line join
vim.keymap.set('n', 'J', 'mzJ`z')

-- Keep cursor in the middle when you jump down and up
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Keep search term in the middle
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Keep current copy after it's pasted
vim.keymap.set('x', '<leader>p', [["_dP]])

-- none-ls
vim.keymap.set('n', '<leader>ff', function()
  vim.lsp.buf.format { async = true }
end, {})

-- fugitive
vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

-- Nvimtree
vim.api.nvim_set_keymap('n', '<leader>nt', ':NvimTreeToggle<cr>', { noremap = true, silent = true })

-- Undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Copy to system clipboard
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

-- Noice
vim.keymap.set('n', '<leader>nd', '<cmd>NoiceDismiss<CR>', { desc = 'Dismiss notification' })

-- Twilight
vim.keymap.set('n', '<leader>tw', '<cmd>Twilight<CR>', { desc = 'Toggle Twilight' })

-- Quarto
vim.keymap.set('n', '<leader>qp', '<cmd>QuartoPreview<CR>', { desc = 'Quarto' })
