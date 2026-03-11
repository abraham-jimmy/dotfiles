local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local ok, lint = pcall(require, "lint")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-lint is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  lint.linters_by_ft = require("lang").linters_by_ft()

  local function try_lint()
    local linters = lint.linters_by_ft[vim.bo.filetype]
    if not linters or vim.tbl_isempty(linters) then
      return
    end

    lint.try_lint()
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("nvim_new_linting", { clear = true }),
    callback = try_lint,
  })

  map("n", "<leader>ll", try_lint, { desc = "Run linters" })
end

return M
