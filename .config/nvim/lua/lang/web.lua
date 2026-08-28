local M = {}

function M.tooling()
  return {
    lsp = {
      cssls = {},
      html = {},
    },
    formatters_by_ft = {
      css = { "prettier", stop_after_first = true },
      html = { "prettier", stop_after_first = true },
    },
  }
end

return M
