vim.pack.add({ { src = "https://github.com/seblyng/roslyn.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, roslyn = pcall(require, "roslyn")
  if not ok then
    vim.schedule(function()
      vim.notify("roslyn.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  roslyn.setup({ broad_search = true })
end

return M
