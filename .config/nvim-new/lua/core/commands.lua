local toggle = require("util.toggle")

vim.api.nvim_create_user_command("FormatToggle", function()
  toggle.autoformat()
end, { desc = "Toggle autoformat-on-save" })

local function create_command_alias(name, callback, opts)
  if vim.fn.exists(":" .. name) == 2 then
    return
  end

  vim.api.nvim_create_user_command(name, callback, opts or {})
end

local function run_lsp_subcommand(subcommand, opts)
  if vim.fn.exists(":lsp") ~= 2 then
    vim.notify("Native :lsp command is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    return
  end

  vim.cmd({ cmd = "lsp", args = vim.list_extend({ subcommand }, opts.fargs), bang = opts.bang })
end

create_command_alias("LspInfo", function()
  vim.cmd.checkhealth("vim.lsp")
end, { desc = "Alias to :checkhealth vim.lsp" })

create_command_alias("LspStart", function(opts)
  run_lsp_subcommand("enable", opts)
end, {
  bang = true,
  desc = "Alias to :lsp enable",
  nargs = "*",
})

create_command_alias("LspRestart", function(opts)
  run_lsp_subcommand("restart", opts)
end, {
  bang = true,
  desc = "Alias to :lsp restart",
  nargs = "*",
})

create_command_alias("LspStop", function(opts)
  run_lsp_subcommand("stop", opts)
end, {
  bang = true,
  desc = "Alias to :lsp stop",
  nargs = "*",
})

create_command_alias("LspDisable", function(opts)
  run_lsp_subcommand("disable", opts)
end, {
  bang = true,
  desc = "Alias to :lsp disable",
  nargs = "*",
})

create_command_alias("LspLog", function()
  vim.cmd.tabnew(vim.lsp.log.get_filename())
end, { desc = "Open the Neovim LSP log" })
