local toggle = require("util.toggle")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "v" }, "<Space>", "<Nop>")
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "q:", "<Nop>")

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "<leader>cn", "<cmd>cnext<cr>", { desc = "Quickfix next" })
map("n", "<leader>cp", "<cmd>cprev<cr>", { desc = "Quickfix previous" })
map("i", "<C-c>", "<Esc>")
map("n", "<C-c>", "<Esc>")
map("n", "<leader>dh", "<cmd>diffget //2<cr>", { desc = "Diff get left" })
map("n", "<leader>dl", "<cmd>diffget //3<cr>", { desc = "Diff get right" })
map("n", "<leader>do", "<cmd>only<cr>", { desc = "Keep current window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<leader>ts", function()
  toggle.option("spell")
end, { desc = "Toggle spelling" })

map("n", "<leader>tw", function()
  toggle.option("wrap")
end, { desc = "Toggle wrap" })

map("n", "<leader>tl", toggle.line_numbers, { desc = "Toggle line numbers" })
map("n", "<leader>td", toggle.diagnostics, { desc = "Toggle diagnostics" })
map("n", "<leader>tD", toggle.inline_diagnostics, { desc = "Toggle inline diagnostics" })
map("n", "<leader>ti", toggle.inlay_hints, { desc = "Toggle inlay hints" })
map("n", "<leader>tI", toggle.indent_scope, { desc = "Toggle indent scope" })
map("n", "<leader>tf", "<cmd>FormatToggle<cr>", { desc = "Toggle autoformat" })
map("n", "<leader>tp", toggle.autopairs, { desc = "Toggle autopairs" })
