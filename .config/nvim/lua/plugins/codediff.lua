vim.pack.add({ { src = "https://github.com/esmuellert/codediff.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, codediff = pcall(require, "codediff")
  if not ok then
    vim.schedule(function()
      vim.notify("codediff.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  codediff.setup({
    diff = {
      disable_inlay_hints = true,
      jump_to_first_change = true,
    },
    explorer = { initial_focus = "explorer" },
    history = { initial_focus = "history" },
  })
end

return M
