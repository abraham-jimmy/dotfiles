local M = {}

function M.setup()
  if vim.fn.has("nvim-0.12") == 0 then
    vim.schedule(function()
      vim.notify("nvim expects Neovim 0.12 or newer", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  if not vim.pack then
    vim.schedule(function()
      vim.notify("vim.pack is unavailable in this Neovim build", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local function load(name)
    local plugin = require("plugins." .. name)
    if plugin.setup then
      plugin.setup()
    end
  end

  load("kanagawa")
  load("catppuccin")
  require("integrations.theme").setup()
  load("nvim_notify")
  load("nvim_web_devicons")

  load("fzf_lua")
  load("nvim_hlslens")
  load("todo_comments")
  load("gitsigns")
  load("codediff")
  require("integrations.codediff_dotfiles").setup()

  load("mini_files")
  load("nvim_tree")
  load("nvim_treesitter")
  load("nvim_treesitter_textobjects")
  load("mini_indentscope")
  load("mini_move")
  load("mini_trailspace")
  load("mini_ai")
  load("mini_surround")
  load("mini_pairs")

  load("nvim_dap")
  load("nvim_dap_virtual_text")
  load("nvim_dap_view")
  load("lazydev")
  load("nvim_lspconfig")
  load("nvim_lint")
  load("conform")
  load("blink_cmp")

  load("flash")
  load("tmux_nvim")
  load("sidekick")
  load("lualine")
  load("ascii")
  load("dashboard")
  load("zen_mode")
  load("which_key")
end

return M
