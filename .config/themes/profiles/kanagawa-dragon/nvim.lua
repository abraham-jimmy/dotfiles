return {
  id = "kanagawa-dragon",
  plugin = "kanagawa",
  colorscheme = "kanagawa-dragon",
  notify_background = "#181616",
  apply = function()
    local ok, kanagawa = pcall(require, "kanagawa")
    if not ok then
      return false, "kanagawa.nvim is unavailable"
    end

    kanagawa.setup({
      theme = "dragon",
      background = {
        dark = "dragon",
        light = "lotus",
      },
    })

    vim.cmd.colorscheme("kanagawa-dragon")
    return true
  end,
}
