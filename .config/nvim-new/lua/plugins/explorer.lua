local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function toggle_mini_files(path, use_absolute)
  local ok, files = pcall(require, "mini.files")
  if not ok then
    vim.notify("mini.files is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    return
  end

  if files.close() then
    return
  end

  files.open(path, use_absolute)
end

function M.setup()
  local ok, files = pcall(require, "mini.files")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.files is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  files.setup({
    options = {
      use_as_default_explorer = true,
    },
    windows = {
      preview = false,
      width_focus = 36,
      width_nofocus = 18,
    },
  })

  map("n", "<leader>e", function()
    local buf = vim.api.nvim_get_current_buf()

    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      toggle_mini_files(name ~= "" and name or nil)
      return
    end

    toggle_mini_files()
  end, { desc = "MiniFiles current path" })

  map("n", "<leader>E", function()
    toggle_mini_files(require("util.root").git_root(0), false)
  end, { desc = "MiniFiles git root" })

  local tree_ok, tree = pcall(require, "nvim-tree")
  if not tree_ok then
    vim.schedule(function()
      vim.notify("nvim-tree is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  tree.setup({
    disable_netrw = false,
    hijack_netrw = false,
    diagnostics = {
      enable = true,
      show_on_dirs = true,
    },
    git = {
      enable = true,
      ignore = false,
    },
    renderer = {
      group_empty = true,
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    view = {
      preserve_window_proportions = true,
      width = 34,
    },
  })

  map("n", "<leader>o", function()
    require("nvim-tree.api").tree.toggle({
      find_file = true,
      focus = true,
    })
  end, { desc = "Tree toggle" })

  map("n", "<leader>O", function()
    require("nvim-tree.api").tree.open({
      current_window = false,
      focus = true,
      find_file = true,
      update_root = true,
    })
  end, { desc = "Tree reveal current file" })
end

return M
