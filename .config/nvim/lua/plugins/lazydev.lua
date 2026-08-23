vim.pack.add({ { src = "https://github.com/folke/lazydev.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, lazydev = pcall(require, "lazydev")
  if not ok then
    vim.schedule(function()
      vim.notify("lazydev.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  lazydev.setup({
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })
end

return M
