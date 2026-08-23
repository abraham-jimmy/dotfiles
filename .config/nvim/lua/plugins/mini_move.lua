vim.pack.add({ { src = "https://github.com/nvim-mini/mini.move.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, move = pcall(require, "mini.move")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.move is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end
  move.setup({})
end

return M
