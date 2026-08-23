vim.pack.add({ { src = "https://github.com/igorlfs/nvim-dap-view.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  local view_ok, dap_view = pcall(require, "dap-view")
  if not dap_ok or not view_ok then
    vim.schedule(function()
      vim.notify("nvim-dap-view is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  dap_view.setup({
    switchbuf = "uselast",
    winbar = {
      sections = { "scopes", "watches", "breakpoints", "threads", "repl", "console" },
      default_section = "scopes",
    },
    windows = {
      position = "right",
    },
  })

  dap.listeners.before.attach["dap-view"] = dap_view.open
  dap.listeners.before.launch["dap-view"] = dap_view.open
  dap.listeners.before.event_terminated["dap-view"] = function()
    dap_view.close(true)
  end
  dap.listeners.before.event_exited["dap-view"] = function()
    dap_view.close(true)
  end

  vim.keymap.set("n", "<leader>du", function()
    dap_view.toggle(true)
  end, { desc = "DAP: Toggle DAP view", silent = true })
end

return M
