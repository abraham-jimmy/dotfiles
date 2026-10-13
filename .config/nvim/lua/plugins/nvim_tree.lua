vim.pack.add(
  { { src = "https://github.com/nvim-tree/nvim-tree.lua.git", version = "v1" } },
  { confirm = false, load = true }
)

local M = {}

function M.setup()
  local ok, tree = pcall(require, "nvim-tree")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-tree is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  tree.setup({
    disable_netrw = false,
    hijack_netrw = false,
    diagnostics = {
      enable = true,
      show_on_dirs = true,
    },
    git = {
      enable = true,
      ignore = false,
    },
    renderer = {
      group_empty = true,
      highlight_git = "name",
      icons = {
        git_placement = "after",
        show = { git = true },
        glyphs = {
          git = {
            unstaged = "M",
            staged = "S",
            unmerged = "U",
            renamed = "R",
            untracked = "?",
            deleted = "D",
            ignored = "I",
          },
        },
      },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    view = {
      preserve_window_proportions = true,
      width = 34,
    },
  })

  vim.keymap.set("n", "<leader>o", function()
    local api = require("nvim-tree.api")
    api.tree.toggle({ find_file = true, focus = true })
    if api.tree.is_visible() then
      -- Reopening should refresh even when filesystem watchers miss changes.
      api.tree.reload()
    end
  end, { desc = "Tree toggle (refresh on open)", silent = true })
  vim.keymap.set("n", "<leader>O", function()
    require("nvim-tree.api").tree.open({
      current_window = false,
      focus = true,
      find_file = true,
      update_root = true,
    })
  end, { desc = "Tree reveal current file", silent = true })
end

return M
