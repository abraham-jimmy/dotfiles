vim.pack.add({ { src = "https://github.com/nvim-mini/mini.trailspace.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, trailspace = pcall(require, "mini.trailspace")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.trailspace is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  trailspace.setup({})
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_trailspace_disable", { clear = true }),
    pattern = "dashboard",
    callback = function()
      vim.b.minitrailspace_disable = true
    end,
  })
end

return M
