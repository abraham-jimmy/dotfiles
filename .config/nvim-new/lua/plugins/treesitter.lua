local M = {}

function M.setup()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-treesitter is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  local install_ok, install = pcall(require, "nvim-treesitter.install")
  if install_ok then
    install.compilers = { "clang", "gcc" }
  end

  treesitter.setup({
    auto_install = true,
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "diff",
      "hyprlang",
      "json",
      "jsonc",
      "lua",
      "markdown",
      "markdown_inline",
      "nix",
      "query",
      "tmux",
      "vim",
      "vimdoc",
      "yaml",
      "zsh",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
      disable = { "yaml" },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-Space>",
        node_incremental = "<C-Space>",
        scope_incremental = false,
        node_decremental = "<BS>",
      },
    },
  })
end

return M
