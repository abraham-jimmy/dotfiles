return {

  -- Starting page
  {
    "goolord/alpha-nvim",
    dependencies = { 'MaximilianLloyd/ascii.nvim',
      'rubiin/fortune.nvim',
    },
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      local ascii = require("ascii")

      -- Pick a random ASCII from the 'starwars' category
      local header_art = ascii.get_random("text", "neovim")
      dashboard.section.header.val = header_art
      dashboard.section.header.opts = {
        position = "center",
      }

      -- Optional footer or buttons
      local info = {}
      local fortune = require("fortune").get_fortune()
      dashboard.section.footer.val = fortune

      alpha.setup(dashboard.opts)
    end,
  },


  {
    'echasnovski/mini.statusline',
    version = '*',
    opts = {
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          -- },
          local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
          local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
          local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
          -- local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location      = MiniStatusline.section_location({ trunc_width = 75 })
          local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

          return MiniStatusline.combine_groups({
            { hl = mode_hl,                 strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { diff, diagnostics, lsp } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            -- { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl,                  strings = { search, location } },
          })
        end
      }
    }
  },


}
