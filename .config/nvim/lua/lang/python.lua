local M = {}

local uv = vim.uv or vim.loop

local function path_exists(path)
  return path ~= nil and uv.fs_stat(path) ~= nil
end

local function executable_path(path)
  if path_exists(path) and vim.fn.executable(path) == 1 then
    return path
  end

  return nil
end

local function root_with_markers(bufnr, markers)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local path = name ~= "" and vim.fs.normalize(vim.fn.fnamemodify(name, ":p")) or vim.fn.getcwd()
  local stat = uv.fs_stat(path)
  local search_path = stat and stat.type == "directory" and path or vim.fs.dirname(path)
  local marker = vim.fs.find(markers, { path = search_path, upward = true })[1]
  return marker and vim.fs.dirname(marker) or nil
end

local function find_root(bufnr)
  local venv_root = root_with_markers(bufnr, { ".venv" })
  if venv_root then
    return venv_root
  end

  local project_root = root_with_markers(bufnr, {
    "pyrightconfig.json",
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "Pipfile",
  })
  if project_root then
    return project_root
  end

  local requirements_root = root_with_markers(bufnr, { "requirements.txt" })
  if requirements_root then
    return requirements_root
  end

  local git_root = root_with_markers(bufnr, { ".git" })
  if git_root then
    return git_root
  end

  return vim.fn.getcwd()
end

local function expected_python(root_dir)
  if not root_dir or root_dir == "" then
    return nil
  end

  return vim.fs.joinpath(root_dir, ".venv", "bin", "python")
end

local function configured_python(root_dir)
  return executable_path(expected_python(root_dir))
end

function M.tooling()
  return {
    lsp = {
      basedpyright = {
        root_dir = function(bufnr, on_dir)
          on_dir(find_root(bufnr))
        end,
        before_init = function(_, config)
          local python_path = configured_python(config.root_dir)

          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = {
              pythonPath = python_path,
            },
          })

          config._nvim_python_path = python_path
          config._nvim_python_root = config.root_dir
          config._nvim_python_expected = expected_python(config.root_dir)
        end,
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "standard",
            },
          },
        },
      },
    },
    linters_by_ft = {
      python = { "ruff" },
    },
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    },
  }
end

return M
