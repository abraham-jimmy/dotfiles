local M = {}

function M.tooling()
  return {
    lsp = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            diagnostics = {
              globals = { "vim" },
            },
            telemetry = {
              enable = false,
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
    },
  }
end

return M
