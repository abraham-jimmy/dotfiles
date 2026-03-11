local M = {}

function M.tooling()
  return {
    lsp = {
      hyprls = {
        filetypes = { "hyprlang" },
        root_markers = { ".hyprlsignore", ".git" },
        settings = {
          hyprls = {
            preferIgnoreFile = true,
          },
        },
      },
    },
  }
end

return M
