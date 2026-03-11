local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local ok, flash = pcall(require, "flash")
  if not ok then
    vim.schedule(function()
      vim.notify("flash.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  flash.setup({
    modes = {
      char = {
        autohide = true,
        jump_labels = true,
        multi_line = false,
      },
    },
  })

  map({ "n", "x", "o" }, "s", function()
    flash.jump()
  end, { desc = "Flash jump" })

  map({ "n", "x", "o" }, "S", function()
    flash.treesitter()
  end, { desc = "Flash Treesitter" })

  map("o", "r", function()
    flash.remote()
  end, { desc = "Flash remote" })

  map({ "o", "x" }, "R", function()
    flash.treesitter_search()
  end, { desc = "Flash Treesitter search" })
end

return M
