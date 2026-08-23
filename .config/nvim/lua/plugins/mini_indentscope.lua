vim.pack.add({ { src = "https://github.com/nvim-mini/mini.indentscope.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, indentscope = pcall(require, "mini.indentscope")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.indentscope is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  indentscope.setup({
    symbol = "│",
    options = { try_as_border = true },
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_indentscope_disable", { clear = true }),
    pattern = {
      "dashboard",
      "help",
      "lazy",
      "lazyterm",
      "mason",
      "minifiles",
      "NvimTree",
      "notify",
      "qf",
      "toggleterm",
    },
    callback = function()
      vim.b.miniindentscope_disable = true
    end,
  })
end

return M
