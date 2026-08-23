vim.pack.add({ { src = "https://github.com/rcarriga/nvim-notify.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, notify = pcall(require, "notify")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-notify is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  notify.setup({
    background_colour = vim.g.nvim_notify_background or "#181616",
    render = "compact",
    stages = "fade",
    timeout = 3000,
  })
  vim.notify = notify

  vim.keymap.set("n", "<leader>nq", function()
    notify.dismiss({ silent = true, pending = true })
  end, { desc = "Dismiss notifications", silent = true })
  vim.keymap.set("n", "<leader>nh", "<cmd>Notifications<cr>", { desc = "Notification history", silent = true })
  vim.keymap.set("n", "<leader>nc", function()
    notify.clear_history()
    vim.api.nvim_echo({ { "Notification history cleared", "None" } }, false, {})
  end, { desc = "Clear notification history", silent = true })
end

return M
