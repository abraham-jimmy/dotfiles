local M = {}

function M.setup()
  local notify_background = "#181616"
  local ok, theme = pcall(dofile, vim.fn.expand("~/.config/themes/generated/nvim.lua"))

  if not ok or type(theme) ~= "table" then
    vim.schedule(function()
      vim.notify("generated nvim theme is unavailable; using default", vim.log.levels.WARN, { title = "nvim" })
    end)
    pcall(vim.cmd.colorscheme, "default")
  else
    if type(theme.notify_background) == "string" and theme.notify_background ~= "" then
      notify_background = theme.notify_background
    end

    if type(theme.apply) == "function" then
      local applied, err = theme.apply()
      if not applied then
        vim.schedule(function()
          vim.notify(
            err or "failed to apply generated nvim theme; using default",
            vim.log.levels.WARN,
            { title = "nvim" }
          )
        end)
        pcall(vim.cmd.colorscheme, "default")
      end
    end
  end

  vim.g.nvim_notify_background = notify_background
end

return M
