local M = {}

local function specs()
  return {
    require("lang.bash"),
    require("lang.cpp"),
    require("lang.data"),
    require("lang.hypr"),
    require("lang.lua"),
    require("lang.markdown"),
    require("lang.nix"),
    require("lang.python"),
    require("lang.tmux"),
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

return M
