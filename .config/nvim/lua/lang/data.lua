local M = {}

function M.tooling()
  return {
    lsp = {
      jsonls = {
        filetypes = { "json", "jsonc" },
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      },
      yamlls = {
        filetypes = { "yaml" },
        settings = {
          yaml = {
            format = { enable = false },
            keyOrdering = false,
            validate = true,
          },
        },
      },
    },
    formatters_by_ft = {
      json = { "prettier", "jq", stop_after_first = true },
      jsonc = { "prettier", stop_after_first = true },
      yaml = { "prettier", "yamlfmt", stop_after_first = true },
      yml = { "prettier", "yamlfmt", stop_after_first = true },
    },
  }
end

return M
