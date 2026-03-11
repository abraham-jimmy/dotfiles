local toggle = require("util.toggle")

vim.api.nvim_create_user_command("FormatToggle", function()
  toggle.autoformat()
end, { desc = "Toggle autoformat-on-save" })
