vim.pack.add({ { src = "https://github.com/nvim-mini/mini.surround.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, surround = pcall(require, "mini.surround")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.surround is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  surround.setup({
    mappings = {
      add = "gsa",
      delete = "gsd",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      replace = "gsr",
      update_n_lines = "gsn",
    },
  })
end

return M
