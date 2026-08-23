vim.pack.add({ { src = "https://github.com/nvim-mini/mini.pairs.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, pairs = pcall(require, "mini.pairs")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.pairs is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end
  pairs.setup({})
end

return M
