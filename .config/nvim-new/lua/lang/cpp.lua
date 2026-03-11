local M = {}

function M.tooling()
  return {
    lsp = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
        },
        root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
      },
    },
    formatters_by_ft = {
      c = { "clang_format" },
      cpp = { "clang_format" },
    },
  }
end

return M
