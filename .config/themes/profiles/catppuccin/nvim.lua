return {
  id = "catppuccin",
  plugin = "catppuccin",
  colorscheme = "catppuccin",
  notify_background = "#1e1e2e",
  apply = function()
    local ok, catppuccin = pcall(require, "catppuccin")
    if not ok then
      return false, "catppuccin.nvim is unavailable"
    end

    catppuccin.setup({})
    vim.cmd.colorscheme("catppuccin")
    return true
  end,
}
