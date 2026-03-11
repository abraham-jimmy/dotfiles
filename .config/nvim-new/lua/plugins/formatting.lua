local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.schedule(function()
      vim.notify("conform.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  local language_tooling = require("lang")

  conform.setup({
    formatters_by_ft = language_tooling.formatters_by_ft(),
    formatters = language_tooling.formatters(),
    format_on_save = function(bufnr)
      if not vim.g.autoformat_enabled or vim.b[bufnr].disable_autoformat then
        return
      end

      return {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    end,
  })

  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

  map({ "n", "x" }, "<leader>fo", function()
    conform.format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format buffer" })
end

return M
