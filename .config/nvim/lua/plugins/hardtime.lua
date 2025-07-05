return {

  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      notification = true,
      custom_notify = function(msg)
        require("notify")(msg, "warn", { title = "Hardtime" })
      end,
    },
    keys = {
      { "<leader>ht", "<cmd>Hardtime toggle<cr>",  desc = "Toggle hardtime" },
      { "<leader>he", "<cmd>Hardtime enable<cr>",  desc = "Enable hardtime" },
      { "<leader>hd", "<cmd>Hardtime disable<cr>", desc = "Disable hardtime" }

    }
  }
}
