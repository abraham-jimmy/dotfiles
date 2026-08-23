vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-web-devicons is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end
  devicons.setup({ default = true })
end

return M
