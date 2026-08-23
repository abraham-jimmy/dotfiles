local M = {}

function M.tooling()
  return {
    lsp = {
      nixd = {
        filetypes = { "nix" },
        root_markers = { "flake.nix", "shell.nix", "default.nix", ".git" },
      },
    },
    formatters_by_ft = {
      nix = { "nixfmt" },
    },
  }
end

return M
