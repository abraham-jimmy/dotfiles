local uv = vim.uv or vim.loop

local M = {}

M.root_patterns = { ".git", "lua", "compile_commands.json" }

function M.get_root(bufnr)
  bufnr = bufnr or 0

  local path = vim.api.nvim_buf_get_name(bufnr)
  path = path ~= "" and uv.fs_realpath(path) or nil

  local roots = {}

  if path then
    for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      local workspace = client.config.workspace_folders
      local paths = workspace and vim.tbl_map(function(ws)
        return vim.uri_to_fname(ws.uri)
      end, workspace) or client.config.root_dir and { client.config.root_dir } or {}

      for _, client_path in ipairs(paths) do
        local real = uv.fs_realpath(client_path)
        if real and path:find(real, 1, true) then
          roots[#roots + 1] = real
        end
      end
    end
  end

  table.sort(roots, function(a, b)
    return #a > #b
  end)

  local root = roots[1]

  if not root then
    local search_path = path and vim.fs.dirname(path) or uv.cwd()
    root = vim.fs.find(M.root_patterns, { path = search_path, upward = true })[1]
    root = root and vim.fs.dirname(root) or uv.cwd()
  end

  return root
end

function M.git_root(bufnr)
  local root = M.get_root(bufnr)
  local git_dir = vim.fs.find(".git", { path = root, upward = true })[1]
  return git_dir and vim.fs.dirname(git_dir) or root
end

return M
