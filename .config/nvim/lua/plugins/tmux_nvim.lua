vim.pack.add({ { src = "https://github.com/nathom/tmux.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, tmux = pcall(require, "tmux")
  if not ok then
    vim.schedule(function()
      vim.notify("tmux.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  if tmux.setup then
    tmux.setup({})
  end
  vim.keymap.set("n", "<C-h>", tmux.move_left, { desc = "Move left across nvim/tmux", silent = true })
  vim.keymap.set("n", "<C-j>", tmux.move_down, { desc = "Move down across nvim/tmux", silent = true })
  vim.keymap.set("n", "<C-k>", tmux.move_up, { desc = "Move up across nvim/tmux", silent = true })
  vim.keymap.set("n", "<C-l>", tmux.move_right, { desc = "Move right across nvim/tmux", silent = true })
end

return M
