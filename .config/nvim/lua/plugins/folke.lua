return {

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      -- explorer = { enabled = true },
      -- indent = { enabled = true },
      -- input = { enabled = true },
      -- picker = { enabled = true },
      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- scope = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
      lazygit = { enabled = true }
    },
    keys = {
      { "<leader>lg", function() Snacks.lazygit.open() end, desc = "Open Lazygit" }
    }
  },
  {
    "folke/zen-mode.nvim",
    version = '*',
    opts = {
      window = {
        width = 150,
      },
    },
    keys = {
      { "<leader>Z", "<Cmd> ZenMode <Cr>", desc = "Toggle ZenMode" },

    }
  },

  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          autohide = true,
          jump_labels = true,
          multi_line = false,
        }
      }
    },
    keys = {
      { "f", "F",                      "t",                                          "T" },
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o",               function() require("fRuga").remote() end,     desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc =
        "Treesitter Search"
      },
      -- {
      --   "<c-s>",
      --   mode = { "c" },
      --   function() require("flash").toggle() end,
      --   desc =
      --   "Toggle Flash Search"
      -- },
    },
  },

  -- Need to update, "ganska najs - sebbe"
  -- {
  --   "folke/trouble.nvim",
  --   cmd = { "TroubleToggle", "Trouble" },
  --   opts = { use_diagnostic_signs = true },
  --   keys = {
  --     { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics (Trouble)" },
  --     { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
  --     { "<leader>xL", "<cmd>TroubleToggle loclist<cr>",               desc = "Location List (Trouble)" },
  --     { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List (Trouble)" },
  --     {
  --       "[q",
  --       function()
  --         if require("trouble").is_open() then
  --           require("trouble").previous({ skip_groups = true, jump = true })
  --         else
  --           local ok, err = pcall(vim.cmd.cprev)
  --           if not ok then
  --             vim.notify(err, vim.log.levels.ERROR)
  --           end
  --         end
  --       end,
  --       desc = "Previous trouble/quickfix item",
  --     },
  --     {
  --       "]q",
  --       function()
  --         if require("trouble").is_open() then
  --           require("trouble").next({ skip_groups = true, jump = true })
  --         else
  --           local ok, err = pcall(vim.cmd.cnext)
  --           if not ok then
  --             vim.notify(err, vim.log.levels.ERROR)
  --           end
  --         end
  --       end,
  --       desc = "Next trouble/quickfix item",
  --     },
  --   },
  -- },

  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",      desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "Todo/Fix/Fixme" },
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {
      preset = "classic",
      show_help = false,
      show_keys = false,
      win = {
        padding = { 0, 0 },
        title = false,
      }
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.add({
        { "<leader>f", group = "file" },          -- group
        { "<leader>c", group = "idk" },           -- group
        { "<leader>d", group = "diff/dap" },      -- group
        { "<leader>s", group = "Search/todo" },   -- group
        { "<leader>x", group = "Trouble stuff" }, -- group
        { "<leader>t", group = "Toggle stuff" },  -- group
        -- { "<leader>f1", hidden = true },      -- hide this keymap
        -- { "<leader>v",  group = "windows" },  -- proxy to window mappings
        {
          -- Nested mappings are allowed and can be added in any order
          -- Most attributes can be inherited or overridden on any level
          -- There's no limit to the depth of nesting
          mode = { "n", "v" },                          -- NORMAL and VISUAL mode
          { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
          { "<leader>w", "<cmd>w<cr>", desc = "Write" },
        }
      })

      wk.setup(opts)
    end
  },

}
