vim.pack.add({ { src = "https://github.com/folke/zen-mode.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, zen = pcall(require, "zen-mode")
  if not ok then
    vim.schedule(function()
      vim.notify("zen-mode.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  zen.setup({
    window = { width = 150 },
    plugins = {
      options = { enabled = true, laststatus = 0, ruler = false, showcmd = false },
      tmux = { enabled = false },
    },
  })
  vim.keymap.set("n", "<leader>Z", zen.toggle, { desc = "Toggle Zen Mode", silent = true })
end

return M
