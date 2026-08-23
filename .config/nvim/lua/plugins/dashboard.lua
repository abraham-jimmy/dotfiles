vim.pack.add({ { src = "https://github.com/nvimdev/dashboard-nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, dashboard = pcall(require, "dashboard")
  if not ok then
    vim.schedule(function()
      vim.notify("dashboard-nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local header = { "", "  nvim", "" }
  local ascii_ok, ascii = pcall(require, "ascii")
  if ascii_ok then
    header = ascii.get_random("text", "neovim")
  end

  dashboard.setup({
    theme = "hyper",
    config = {
      header = header,
      shortcut = {
        {
          desc = "Files",
          group = "Keyword",
          key = "f",
          action = function()
            require("fzf-lua").files()
          end,
        },
        {
          desc = "Grep",
          group = "String",
          key = "g",
          action = function()
            require("fzf-lua").live_grep()
          end,
        },
        {
          desc = "Config",
          group = "Function",
          key = "c",
          action = function()
            require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
          end,
        },
        { desc = "Quit", group = "Number", key = "q", action = "qa" },
      },
      project = {
        action = function(path)
          require("fzf-lua").files({ cwd = path })
        end,
        enable = true,
        icon = " ",
        label = "Recent projects",
        limit = 8,
      },
      mru = { cwd_only = false, enable = true, icon = " ", label = "Recent files", limit = 10 },
      footer = {},
      packages = { enable = false },
    },
    hide = { statusline = true },
  })
end

return M
