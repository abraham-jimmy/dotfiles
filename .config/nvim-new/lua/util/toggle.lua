local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "nvim-new" })
end

local function diagnostics_enabled()
  local ok, enabled = pcall(vim.diagnostic.is_enabled, { bufnr = 0 })
  if ok then
    return enabled
  end

  return true
end

function M.option(name, values)
  local current = vim.opt_local[name]:get()

  if values then
    local next_value = current == values[1] and values[2] or values[1]
    vim.opt_local[name] = next_value
    notify(name .. ": " .. tostring(vim.opt_local[name]:get()))
    return
  end

  vim.opt_local[name] = not current
  local enabled = vim.opt_local[name]:get()
  notify((enabled and "Enabled " or "Disabled ") .. name, enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.line_numbers()
  local enabled = not (vim.wo.number or vim.wo.relativenumber)
  vim.wo.number = enabled
  vim.wo.relativenumber = enabled
  notify((enabled and "Enabled" or "Disabled") .. " line numbers", enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.diagnostics()
  local enabled = diagnostics_enabled()
  vim.diagnostic.enable(not enabled, { bufnr = 0 })
  notify((not enabled and "Enabled" or "Disabled") .. " diagnostics", not enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.inline_diagnostics()
  local enabled = vim.g.inline_diagnostics_enabled ~= false
  require("core.diagnostics").apply_inline_text(not enabled)

  if not enabled then
    notify("Inline diagnostics show warnings and errors")
    return
  end

  notify("Inline diagnostics limited to errors")
end

function M.inlay_hints()
  if not vim.lsp.inlay_hint then
    notify("Inlay hints are unavailable", vim.log.levels.WARN)
    return
  end

  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
  notify((not enabled and "Enabled" or "Disabled") .. " inlay hints", not enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  notify((vim.g.autoformat_enabled and "Enabled" or "Disabled") .. " autoformat", vim.g.autoformat_enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.autopairs()
  vim.g.minipairs_disable = not vim.g.minipairs_disable
  local enabled = not vim.g.minipairs_disable
  notify((enabled and "Enabled" or "Disabled") .. " autopairs", enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

function M.indent_scope()
  vim.g.miniindentscope_disable = not vim.g.miniindentscope_disable
  local enabled = not vim.g.miniindentscope_disable

  local ok, indentscope = pcall(require, "mini.indentscope")
  if ok then
    if enabled then
      indentscope.draw()
    else
      indentscope.undraw()
    end
  end

  notify((enabled and "Enabled" or "Disabled") .. " indent scope", enabled and vim.log.levels.INFO or vim.log.levels.WARN)
end

return M
