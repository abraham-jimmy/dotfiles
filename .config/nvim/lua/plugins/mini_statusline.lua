vim.pack.add({ { src = "https://github.com/nvim-mini/mini.statusline.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, statusline = pcall(require, "mini.statusline")
  if not ok then
    vim.schedule(function()
      vim.notify("mini.statusline is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local has_devicons = pcall(require, "nvim-web-devicons")
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
        local sections = { { hl = mode_hl, strings = { mode } } }

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
    use_icons = has_devicons,
  })
end

return M
