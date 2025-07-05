local M = {}

M.root_patterns = { ".git", "lua", "compile_commands.json" }

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

-- Returns git root
function M.git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

-- function M.expand("<cword>")
--   return [':<C-u>%s/\<' . expand('<cword>') . '\>//g<Left><Left>']]
--
function M.toggle(option, values)
  if values then
    if vim.opt_local[option]:get() == values[1] then
      vim.opt_local[option] = values[2]
    else
      vim.opt_local[option] = values[1]
    end
  end
  vim.opt_local[option] = not vim.opt_local[option]:get()
  if vim.opt_local[option]:get() then
    vim.notify("Enabled " .. option, vim.log.levels.INFO)
  else
    vim.notify("Disabled " .. option, vim.log.levels.WARN)
  end
end

local inline_text_enabled = true
function M.toggle_diagnostics_inline_text()
  vim.b.diag_enabled = true
  if inline_text_enabled == true then
    vim.diagnostic.config({
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.ERROR,
          max = vim.diagnostic.severity.ERROR,
        }
      }
    })
    inline_text_enabled = false
  else
    vim.diagnostic.config({
      virtual_text = {
        severity = {
          min = vim.diagnostic.severity.WARN,
          max = vim.diagnostic.severity.ERROR,
        }
      }
    })
    inline_text_enabled = true
  end
  vim.notify("NEW Diagnostics: " .. (inline_text_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.toggle_diagnostics()
  if vim.b.diag_enabled == nil then
    vim.b.diag_enabled = true
  end
  vim.diagnostic.enable(not vim.b.diag_enabled, { bufnr = 0 })
  vim.b.diag_enabled = not vim.b.diag_enabled
  vim.notify("Diagnostics: " .. (vim.b.diag_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.toggle_inlay_hints()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
end

return M
