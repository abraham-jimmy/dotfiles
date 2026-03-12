local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function leader_group_clues()
  return {
    { mode = { "n", "x" }, keys = "<Leader>a", desc = "+AI / OpenCode" },
    { mode = { "n", "x" }, keys = "<Leader>f", desc = "+Files / Format" },
    { mode = "n", keys = "<Leader>l", desc = "+Language / Lint" },
    { mode = "n", keys = "<Leader>n", desc = "+Notifications" },
    { mode = { "n", "x" }, keys = "<Leader>s", desc = "+Search" },
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    { mode = "n", keys = "<Leader>c", desc = "+Quickfix" },
    { mode = "n", keys = "<Leader>d", desc = "+Diff / DAP" },
    { mode = "n", keys = "<Leader>g", desc = "+Git / Review" },
    { mode = "n", keys = "<Leader>t", desc = "+Toggle" },
    { mode = "n", keys = "<Leader>w", desc = "+Workspace" },
  }
end

function M.setup()
  local theme_notify_background = "#181616"
  local theme_ok, theme = pcall(dofile, vim.fn.expand("~/.config/themes/generated/nvim-new.lua"))

  if not theme_ok or type(theme) ~= "table" then
    vim.schedule(function()
      vim.notify("generated nvim-new theme is unavailable; using default", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    pcall(vim.cmd.colorscheme, "default")
  else
    if type(theme.notify_background) == "string" and theme.notify_background ~= "" then
      theme_notify_background = theme.notify_background
    end

    if type(theme.apply) == "function" then
      local applied, err = theme.apply()
      if not applied then
        vim.schedule(function()
          vim.notify(err or "failed to apply generated nvim-new theme; using default", vim.log.levels.WARN, { title = "nvim-new" })
        end)
        pcall(vim.cmd.colorscheme, "default")
      end
    end
  end

  local notify_ok, notify = pcall(require, "notify")
  if not notify_ok then
    vim.schedule(function()
      vim.notify("nvim-notify is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    notify.setup({
      background_colour = theme_notify_background,
      render = "compact",
      stages = "fade",
      timeout = 3000,
    })

    vim.notify = notify

    map("n", "<leader>nq", function()
      notify.dismiss({ silent = true, pending = true })
    end, { desc = "Dismiss notifications" })
    map("n", "<leader>nh", "<cmd>Notifications<cr>", { desc = "Notification history" })
    map("n", "<leader>nc", function()
      notify.clear_history()
      vim.api.nvim_echo({ { "Notification history cleared", "None" } }, false, {})
    end, { desc = "Clear notification history" })
  end

  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  if devicons_ok then
    devicons.setup({ default = true })
  else
    vim.schedule(function()
      vim.notify("nvim-web-devicons is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  end

  local statusline_ok, statusline = pcall(require, "mini.statusline")
  if not statusline_ok then
    vim.schedule(function()
      vim.notify("mini.statusline is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    statusline.setup({
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local diff = MiniStatusline.section_diff({ trunc_width = 75 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
          local filename = MiniStatusline.section_filename({ trunc_width = 140 })
          local recording = vim.fn.reg_recording()
          local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          local sections = {
            { hl = mode_hl, strings = { mode } },
          }

          if recording ~= "" then
            table.insert(sections, { hl = "MiniStatuslineModeOther", strings = { "REC @" .. recording } })
          end

          table.insert(sections, { hl = "MiniStatuslineDevinfo", strings = { diff, diagnostics, lsp } })
          table.insert(sections, "%<")
          table.insert(sections, { hl = "MiniStatuslineFilename", strings = { filename } })
          table.insert(sections, "%=")
          table.insert(sections, { hl = mode_hl, strings = { search, location } })

          return MiniStatusline.combine_groups(sections)
        end,
      },
      use_icons = devicons_ok,
    })
  end

  local dashboard_ok, dashboard = pcall(require, "dashboard")
  if not dashboard_ok then
    vim.schedule(function()
      vim.notify("dashboard-nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    local header = {
      "",
      "  nvim-new",
      "",
    }

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
          {
            desc = "Quit",
            group = "Number",
            key = "q",
            action = "qa",
          },
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
        mru = {
          cwd_only = false,
          enable = true,
          icon = " ",
          label = "Recent files",
          limit = 10,
        },
        footer = {},
        packages = { enable = false },
      },
      hide = {
        statusline = true,
      },
    })
  end

  local zen_ok, zen = pcall(require, "zen-mode")
  if not zen_ok then
    vim.schedule(function()
      vim.notify("zen-mode.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    zen.setup({
      window = {
        width = 150,
      },
      plugins = {
        options = {
          enabled = true,
          laststatus = 0,
          ruler = false,
          showcmd = false,
        },
        tmux = { enabled = false },
      },
    })

    map("n", "<leader>Z", function()
      zen.toggle()
    end, { desc = "Toggle Zen Mode" })
  end

  local ok, miniclue = pcall(require, "mini.clue")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.clue is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  miniclue.setup({
    clues = {
      leader_group_clues(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = { "n", "x" }, keys = "[" },
      { mode = { "n", "x" }, keys = "]" },
      { mode = "i", keys = "<C-x>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = { "n", "x" }, keys = "z" },
    },
    window = {
      delay = 250,
      config = {
        width = "auto",
      },
    },
  })

  local clue_panel = require("util.clue_panel")
  clue_panel.setup()

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_new_miniclue_special", { clear = true }),
    pattern = { "dashboard", "NvimTree" },
    callback = function(event)
      vim.schedule(function()
        if _G.MiniClue and MiniClue.ensure_buf_triggers then
          MiniClue.ensure_buf_triggers(event.buf)
        end
      end)
    end,
  })
end

return M
