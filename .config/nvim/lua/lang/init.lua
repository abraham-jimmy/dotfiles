local M = {}

local function specs()
  return {
    require("lang.bash"),
    require("lang.cpp"),
    require("lang.csharp"),
    require("lang.data"),
    require("lang.glsl"),
    require("lang.hypr"),
    require("lang.lua"),
    require("lang.markdown"),
    require("lang.nix"),
    require("lang.python"),
    require("lang.typescript"),
    require("lang.web"),
    require("lang.zsh"),
  }
end

local function merge_maps(extract)
  local merged = {}

  for _, spec in ipairs(specs()) do
    local entries = extract(spec.tooling and spec.tooling() or {}) or {}

    for key, value in pairs(entries) do
      if type(value) == "table" and vim.islist(value) then
        merged[key] = vim.list_extend(merged[key] or {}, value)
      else
        merged[key] = vim.tbl_deep_extend("force", merged[key] or {}, value)
      end
    end
  end

  return merged
end

function M.lsp_servers()
  return merge_maps(function(tooling)
    return tooling.lsp
  end)
end

function M.formatters_by_ft()
  return merge_maps(function(tooling)
    return tooling.formatters_by_ft
  end)
end

function M.formatters()
  return merge_maps(function(tooling)
    return tooling.formatters
  end)
end

function M.linters_by_ft()
  return merge_maps(function(tooling)
    return tooling.linters_by_ft
  end)
end

function M.linters_on_write()
  local names = merge_maps(function(tooling)
    return tooling.linters_on_write and { names = tooling.linters_on_write }
  end).names or {}

  return vim.iter(names):fold({}, function(result, name)
    result[name] = true
    return result
  end)
end

return M
