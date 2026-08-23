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
      json = { "jq" },
      yaml = { "yamlfmt" },
      yml = { "yamlfmt" },
    },
  }
end

return M
