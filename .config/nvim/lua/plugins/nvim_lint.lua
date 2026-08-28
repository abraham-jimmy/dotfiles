vim.pack.add({ { src = "https://github.com/mfussenegger/nvim-lint.git" } }, { confirm = false, load = true })

local M = {}

local function find_upward(path, relative_path)
  local dir = vim.fs.dirname(path)

  while dir do
    local candidate = vim.fs.joinpath(dir, relative_path)
    if vim.uv.fs_stat(candidate) then
      return candidate
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

local function tslint_parser(output)
  if vim.trim(output) == "" then
    return {}
  end

  local ok, results = pcall(vim.json.decode, output)
  if not ok then
    return {}
  end

  return vim
    .iter(results or {})
    :map(function(result)
      local start = result.startPosition or {}
      local finish = result.endPosition or start
      local severity = result.ruleSeverity and result.ruleSeverity:upper() or "WARNING"

      return {
        lnum = start.line or 0,
        col = start.character or 0,
        end_lnum = finish.line or start.line or 0,
        end_col = finish.character or start.character or 0,
        message = result.failure or result.name or "TSLint diagnostic",
        code = result.ruleName,
        severity = severity == "ERROR" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        source = "tslint",
      }
    end)
    :totable()
end

local function tslint_linter()
  local filename = vim.api.nvim_buf_get_name(0)
  local binary = find_upward(filename, "node_modules/.bin/tslint")
  local config = find_upward(filename, "tslint.json")
  local project = find_upward(filename, "tsconfig.json")

  return {
    cmd = binary or "tslint",
    condition = binary ~= nil and config ~= nil and project ~= nil,
    args = { "--format", "json", "--project", project or "tsconfig.json", filename },
    append_fname = false,
    ignore_exitcode = true,
    parser = tslint_parser,
    stream = "stdout",
  }
end

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
  lint.linters.tslint = tslint_linter

  local linters_on_write = require("lang").linters_on_write()

  local function try_lint(event)
    local linters = lint.linters_by_ft[vim.bo.filetype]
    if not linters or vim.tbl_isempty(linters) then
      return
    end

    if vim.bo.filetype == "zsh" and vim.api.nvim_buf_get_name(0) == "" then
      return
    end

    lint.try_lint(linters, {
      filter = function(linter)
        if linter.condition == false then
          return false
        end

        return not event or event == "BufWritePost" or not linters_on_write[linter.name]
      end,
    })
  end

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("nvim_linting", { clear = true }),
    callback = function(args)
      try_lint(args.event)
    end,
  })

  map("n", "<leader>ll", function()
    try_lint()
  end, { desc = "Run linters" })
end

return M
