vim.pack.add({ { src = "https://github.com/folke/which-key.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, which_key = pcall(require, "which-key")
  if not ok then
    vim.schedule(function()
      vim.notify("which-key.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  which_key.setup({ delay = 250 })
  which_key.add({
    { "<leader>a", group = "AI / OpenCode", mode = { "n", "x" } },
    { "<leader>f", group = "Files / Format", mode = { "n", "x" } },
    { "<leader>l", group = "Language / Lint" },
    { "<leader>n", group = "Notifications" },
    { "<leader>s", group = "Search", mode = { "n", "x" } },
    { "<leader>b", group = "Buffers" },
    { "<leader>c", group = "Quickfix" },
    { "<leader>d", group = "Diff / DAP" },
    { "<leader>g", group = "Git / Review" },
    { "<leader>t", group = "Toggle" },
    { "<leader>w", group = "Workspace" },
  })
  vim.keymap.set("n", "<leader>?", function()
    which_key.show({ global = false })
  end, { desc = "Buffer local keymaps", silent = true })
end

return M
