vim.pack.add({ { src = "https://github.com/nvim-mini/mini.files.git" } }, { confirm = false, load = true })

local M = {}

local function nearest_existing_path(path)
  if path == nil or path == "" then
    return nil
  end

  path = vim.fs.normalize(path)
  while vim.uv.fs_stat(path) == nil do
    local parent = vim.fs.dirname(path)
    if parent == nil or parent == path then
      return nil
    end
    path = parent
  end

  return path
end

local function toggle(path, use_absolute)
  local files = require("mini.files")
  if files.close() then
    return
  end
  files.open(path, use_absolute)
end

function M.setup()
  local ok, files = pcall(require, "mini.files")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.files is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  files.setup({
    options = { use_as_default_explorer = true },
    windows = {
      preview = false,
      width_focus = 36,
      width_nofocus = 18,
    },
  })

  vim.keymap.set("n", "<leader>e", function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      toggle(nearest_existing_path(vim.api.nvim_buf_get_name(buf)))
      return
    end
    toggle()
  end, { desc = "MiniFiles current path", silent = true })

  vim.keymap.set("n", "<leader>E", function()
    toggle(require("util.root").git_root(0), false)
  end, { desc = "MiniFiles git root", silent = true })
end

return M
