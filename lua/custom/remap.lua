-- Move block up and down together
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Line join
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle when you jump down and up
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search term in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Keep current copy after it's pasted
vim.keymap.set("x", "<leader>p", [["_dP]])