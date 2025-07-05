return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "rcarriga/nvim-notify",
    lazy = true, -- load only when required
    dependencies = { "telescope.nvim" },
    config = function()
      require("notify").setup({
        stages = "fade",
        timeout = 1500,
        background_colour = "#1e1e2e",
      })
      vim.notify = require("notify")
    end,
    keys = {
      {
        "<leader>nc",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss notifications"
      },
      {
        "<leader>ns",
        function()
          require("notify")._print_history()
        end,
        desc = "Show notification"
      },
      { "<leader>nh", ":Notifications<cr>",    desc = "Show notification history" },
      { "<leader>nt", ":Telescope notify<cr>", desc = "Show notification history, with telescope" },
    }
  }
}
