local function use_default_colorscheme()
  pcall(vim.cmd.colorscheme, "default")
end

local ok, spec = pcall(dofile, vim.fn.expand("~/.config/themes/generated/nvim.lua"))
if not ok or type(spec) ~= "table" or vim.tbl_isempty(spec) then
  vim.schedule(function()
    vim.notify("generated nvim theme is unavailable; using default", vim.log.levels.WARN, { title = "nvim" })
  end)
  use_default_colorscheme()
  return {}
end

local theme = spec[1]
if type(theme) == "table" and type(theme.config) == "function" then
  local original_config = theme.config
  theme.config = function(...)
    local applied, err = pcall(original_config, ...)
    if applied then
      return
    end

    vim.schedule(function()
      vim.notify(err or "failed to apply generated nvim theme; using default", vim.log.levels.WARN, { title = "nvim" })
    end)
    use_default_colorscheme()
  end
end

return spec
