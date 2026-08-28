local M = {}

function M.tooling()
  return {
    lsp = {
      marksman = {
        filetypes = { "markdown" },
        root_markers = { ".marksman.toml", ".git" },
      },
    },
    formatters_by_ft = {
      markdown = { "prettier", stop_after_first = true },
    },
  }
end

return M
