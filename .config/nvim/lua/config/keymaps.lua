local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local util = require("util")

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map('n', 'q:', '<nop>')
map('n', '<C-d>', '<C-d>zz', { desc = "Scroll window down and center" })
map('n', '<C-u>', '<C-u>zz', { desc = "Scroll window up and center" })
map('n', '<leader>cn', ':cn<CR>')
map('n', '<leader>cp', ':cp<CR>')
map('i', '<C-c>', '<Esc>')
map('n', '<C-c>', '<Esc>')
map('n', '<leader>dh', ':diffget //2<CR>')
map('n', '<leader>dl', ':diffget //3<CR>')
map('n', '<leader>do', ':only<CR>')

-- -- TMUX
-- map('n', '<C-h>', [[<cmd>lua require('tmux').move_left()<cr>]], { silent = true })
-- map('n', '<C-l>', [[<cmd>lua require('tmux').move_right()<cr>]], { silent = true })
-- map('n', '<C-k>', [[<cmd>lua require('tmux').move_up()<cr>]], { silent = true })
-- map('n', '<C-j>', [[<cmd>lua require('tmux').move_down()<cr>]], { silent = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Toggle
map("n", "<leader>ts", function() util.toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>tw", function() util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>tl", function()
  util.toggle("relativenumber")
  util.toggle("number")
end, { desc = "Toggle Line Numbers" })
map("n", "<leader>td", util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
map("n", "<leader>tD", util.toggle_diagnostics_inline_text, { desc = "Toggle Diagnostics inline text" })
map("n", "<leader>ti", util.toggle_inlay_hints, { desc = "Toggle Inlay Hints" })
map("n", "<leader>tf", "<Cmd>FormatToggle<CR>", { desc = "Toggle Autoformat" })
