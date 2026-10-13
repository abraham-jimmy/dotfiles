vim.pack.add({ { src = "https://github.com/seblyng/roslyn.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, roslyn = pcall(require, "roslyn")
  if not ok then
    vim.schedule(function()
      vim.notify("roslyn.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  roslyn.setup({})

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("roslyn_diagnostics_on_save", { clear = true }),
    pattern = "*.cs",
    callback = function(args)
      -- Run after didSave; the native handler preserves Roslyn's diagnostic provider identifiers.
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(args.buf) then
          return
        end

        for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf, name = "roslyn" })) do
          vim.lsp.handlers["workspace/diagnostic/refresh"](nil, nil, { client_id = client.id })
        end
      end)
    end,
  })
end

return M
