local M = {}

local function virtual_text(enabled)
  if enabled then
    return {
      severity = {
        min = vim.diagnostic.severity.WARN,
        max = vim.diagnostic.severity.ERROR,
      },
    }
  end

  return {
    severity = {
      min = vim.diagnostic.severity.ERROR,
      max = vim.diagnostic.severity.ERROR,
    },
  }
end

function M.apply_inline_text(enabled)
  vim.g.inline_diagnostics_enabled = enabled
  vim.diagnostic.config({ virtual_text = virtual_text(enabled) })
end

vim.diagnostic.config({
  virtual_text = virtual_text(vim.g.inline_diagnostics_enabled ~= false),
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticHint",
    },
  },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
})

return M
