vim.pack.add({ { src = "https://github.com/kevinhwang91/nvim-hlslens.git" } }, { confirm = false, load = true })

local M = {}

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

function M.setup()
  local ok, hlslens = pcall(require, "hlslens")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-hlslens is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  hlslens.setup({
    calm_down = true,
    nearest_float_when = "auto",
  })

  map("n", function()
    vim.cmd("normal! " .. vim.v.count1 .. "n")
    hlslens.start()
  end, "Next search result")
  map("N", function()
    vim.cmd("normal! " .. vim.v.count1 .. "N")
    hlslens.start()
  end, "Previous search result")
  map("*", function()
    vim.cmd("normal! *")
    hlslens.start()
  end, "Search word forward")
  map("#", function()
    vim.cmd("normal! #")
    hlslens.start()
  end, "Search word backward")
  map("g*", function()
    vim.cmd("normal! g*")
    hlslens.start()
  end, "Search partial word forward")
  map("g#", function()
    vim.cmd("normal! g#")
    hlslens.start()
  end, "Search partial word backward")
  map("<leader>sh", function()
    vim.cmd("nohlsearch")
    hlslens.stop()
  end, "Clear search highlight")
end

return M
