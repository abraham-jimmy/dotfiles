vim.pack.add({ { src = "https://github.com/theHamsta/nvim-dap-virtual-text.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-dap-virtual-text is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  virtual_text.setup({})
  vim.keymap.set("n", "<leader>dv", virtual_text.toggle, { desc = "DAP: Toggle virtual text", silent = true })
end

return M
