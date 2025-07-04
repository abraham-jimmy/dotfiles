return {

  -- Custom text objects
  {
    'echasnovski/mini.ai',
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    version = false,
    opts = function()
      local ai = require('mini.ai')
      local spec_treesitter = ai.gen_spec.treesitter
      return {
        custom_textobjects = {
          -- This will override default "function call" textobject
          f = spec_treesitter({ a = '@function.outer', i = '@function.inner' }),
          c = spec_treesitter({ a = '@class.outer', i = '@class.inner' }),
          -- This will possibly conflict with textobjects from 'mini.indentscope':
          -- If typed quickly (within 'timeoutlen' milliseconds),
          -- 'mini.indentscope' will be used, this one otherwise.
          i = spec_treesitter({ a = '@conditional.outer', i = '@conditional.inner' }),
        }
      }
    end
  },

  -- Move selected lines with alt+h/j/k/l
  {
    'echasnovski/mini.move',
    event = { "BufReadPost", "BufNewFile" },
    version = false,
    opts = {},
  },

  {
    'echasnovski/mini.pairs',
    event = "InsertEnter",
    version = false,
    opts = {},
  },

  {
    'echasnovski/mini.surround',
    event = { "BufReadPost", "BufNewFile" },
    version = false,
    opts = {
      mappings = {
        add = 'gsa',            -- Add surrounding in Normal and Visual modes
        delete = 'gsd',         -- Delete surrounding
        find = 'gsf',           -- Find surrounding (to the right)
        find_left = 'gsF',      -- Find surrounding (to the left)
        highlight = 'gsh',      -- Highlight surrounding
        replace = 'gsr',        -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      }
    }
  },


  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  {
    "echasnovski/mini.files",
    version = '*',
    opts = {},
    keys = {
      {
        "<leader>e",
        function()
          local mf = require('mini.files')
          if not mf.close() then
            local buf = vim.api.nvim_get_current_buf()
            if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
              local name = vim.api.nvim_buf_get_name(buf)
              mf.open(name ~= "" and name or nil)
            else
              mf.open()
            end
          end
        end,
        desc = "MiniFiles open (current dir)"
      },

      {
        "<leader>E",
        function()
          local mf = require('mini.files')
          if not mf.close() then
            local git_root = require('util').git_root()
            mf.open(git_root, false)
          end
        end,
        desc = "MiniFiles open (git root)"
      },
    }



  }
}
