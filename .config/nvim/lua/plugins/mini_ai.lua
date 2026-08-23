vim.pack.add({ { src = "https://github.com/nvim-mini/mini.ai.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, ai = pcall(require, "mini.ai")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.ai is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local spec_treesitter = ai.gen_spec.treesitter
  ai.setup({
    custom_textobjects = {
      f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
      c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
      i = spec_treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
    },
  })
end

return M
