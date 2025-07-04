return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  opts = {
    server = {
      api_url = 'https://codingbuddy.onprem.gic.ericsson.se/_route/api_server',
      portal_url = 'https://codingbuddy.onprem.gic.ericsson.se',
    },
  },
  config = function(_, opts)
    vim.keymap.set("i", "<A-f>", function()
      require("neocodeium").accept()
    end)
    vim.keymap.set("i", "<A-w>", function()
      require("neocodeium").accept_word()
    end)
    vim.keymap.set("i", "<A-a>", function()
      require("neocodeium").accept_line()
    end)
    vim.keymap.set("i", "<A-e>", function()
      require("neocodeium").cycle_or_complete()
    end)
    vim.keymap.set("i", "<A-r>", function()
      require("neocodeium").cycle_or_complete(-1)
    end)
    vim.keymap.set("i", "<A-c>", function()
      require("neocodeium").clear()
    end)
    require("neocodeium").setup(opts)
  end

}
