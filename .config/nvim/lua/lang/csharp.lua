local M = {}

function M.tooling()
  return {
    lsp = {
      roslyn = {
        root_markers = {},
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "fullSolution",
            dotnet_compiler_diagnostics_scope = "fullSolution",
          },
        },
      },
    },
  }
end

return M
