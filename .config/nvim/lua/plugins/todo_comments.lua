vim.pack.add({ { src = "https://github.com/folke/todo-comments.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, todo = pcall(require, "todo-comments")
  if not ok then
    vim.schedule(function()
      vim.notify("todo-comments.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  todo.setup({
    signs = false,
    highlight = {
      comments_only = true,
      keyword = "wide",
    },
  })
end

return M
