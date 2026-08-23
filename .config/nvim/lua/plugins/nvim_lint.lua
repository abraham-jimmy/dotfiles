vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-lint.git" } }, { confirm = false, load = true })

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
      vim.notify("nvim-lint is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  lint.linters_by_ft = require("lang").linters_by_ft()
  lint.linters.zsh = vim.tbl_deep_extend("force", lint.linters.zsh, {
    args = { "--no-exec", "--no-rcs", "--no-globalrcs" },
    parser = require("lint.parser").from_errorformat("%f:%l:%m", {
      source = "zsh",
      severity = vim.diagnostic.severity.ERROR,
    }),
    stdin = false,
  })

  local function try_lint()
    local linters = lint.linters_by_ft[vim.bo.filetype]
    if not linters or vim.tbl_isempty(linters) then
      return
    end

    if vim.bo.filetype == "zsh" and vim.api.nvim_buf_get_name(0) == "" then
      return
    end

    lint.try_lint()
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("nvim_linting", { clear = true }),
    callback = try_lint,
  })

  map("n", "<leader>ll", try_lint, { desc = "Run linters" })
end

return M
