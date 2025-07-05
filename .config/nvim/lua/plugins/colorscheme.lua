return {
  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'onedark'
  --   end,
  -- },
  --
  -- {
  --   "rebelot/kanagawa.nvim",
  --   name = "kanagawa",
  --   priority = 1000,
  --   lazy = false,
  --   config = function()
  --     vim.cmd.colorscheme 'kanagawa-wave' --Opts: -wave, -dragon, -lotus
  --   end,
  -- },

  -- catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Gruvbox theme
  -- {
  --   "ellisonleao/gruvbox.nvim",
  --   priority = 1000,
  --   opts = {
  --     overrides = {
  --       -- Add highlight for vim-illuminate instead of underline
  --       IlluminatedWordText = { bg = "#3c3836" },
  --       IlluminatedWordRead = { bg = "#3c3836" },
  --       IlluminatedWordWrite = { bg = "#3c3836" },
  --     },
  --   },
  --   config = function()
  --     vim.cmd.colorscheme 'gruvbox'
  --     -- set normal to a default if not already set
  --     if vim.api.nvim_get_hl_by_name("Normal", true).background == nil then
  --       vim.api.nvim_set_hl(0, "Normal", { background = 0x171717 })
  --       vim.api.nvim_set_hl(0, "NormalFloat", { background = 0x171717 })
  --     end
  --   end,
  -- }
}
