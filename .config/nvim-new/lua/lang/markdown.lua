local M = {}

function M.tooling()
  return {
    lsp = {
      marksman = {
        filetypes = { "markdown" },
        root_markers = { ".marksman.toml", ".git" },
      },
    },
  }
end

return M
