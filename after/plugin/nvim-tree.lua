local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Nvimtree
keymap("n", "<leader>nt", ":NvimTreeToggle<cr>", opts)
