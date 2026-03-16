local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local hlslens_ok, hlslens = pcall(require, "hlslens")
  if not hlslens_ok then
    vim.schedule(function()
      vim.notify("nvim-hlslens is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    hlslens.setup({
      calm_down = true,
      nearest_float_when = "auto",
    })

    map("n", "n", function()
      vim.cmd("normal! " .. vim.v.count1 .. "n")
      hlslens.start()
    end, { desc = "Next search result" })

    map("n", "N", function()
      vim.cmd("normal! " .. vim.v.count1 .. "N")
      hlslens.start()
    end, { desc = "Previous search result" })

    map("n", "*", function()
      vim.cmd("normal! *")
      hlslens.start()
    end, { desc = "Search word forward" })

    map("n", "#", function()
      vim.cmd("normal! #")
      hlslens.start()
    end, { desc = "Search word backward" })

    map("n", "g*", function()
      vim.cmd("normal! g*")
      hlslens.start()
    end, { desc = "Search partial word forward" })

    map("n", "g#", function()
      vim.cmd("normal! g#")
      hlslens.start()
    end, { desc = "Search partial word backward" })

    map("n", "<leader>sh", function()
      vim.cmd("nohlsearch")
      hlslens.stop()
    end, { desc = "Clear search highlight" })
  end

  local fzf_ok, fzf = pcall(require, "fzf-lua")
  if not fzf_ok then
    vim.schedule(function()
      vim.notify("fzf-lua is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    fzf.setup({
      winopts = {
        preview = {
          hidden = false,
        },
      },
    })

    map("n", "<leader>b", fzf.buffers, { desc = "Buffers" })
    map("n", "<leader>ff", fzf.files, { desc = "Files" })
    map("n", "<leader>fp", function()
      fzf.files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "Config files" })
    map("n", "<leader>fg", fzf.git_files, { desc = "Git files" })
    map("n", "<leader>sg", fzf.grep, { desc = "Grep" })
    map("n", "<leader>sf", fzf.live_grep, { desc = "Live grep" })
    map("n", "<leader>/", fzf.lgrep_curbuf, { desc = "Current buffer grep" })
    map("n", "<leader>sr", fzf.resume, { desc = "Resume search" })
    map("n", "<leader>sd", fzf.diagnostics_document, { desc = "Document diagnostics" })
    map("n", "<leader>sk", fzf.keymaps, { desc = "Keymaps" })
    map("n", "<leader>sw", fzf.grep_cword, { desc = "Current word" })
    map("x", "<leader>sw", fzf.grep_visual, { desc = "Selection" })
    map("n", "<leader>sG", function()
      fzf.grep({ cwd = require("util.root").git_root(0) })
    end, { desc = "Grep git root" })
  end

  local todo_ok, todo = pcall(require, "todo-comments")
  if not todo_ok then
    vim.schedule(function()
      vim.notify("todo-comments.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  todo.setup({
    signs = false,
    highlight = {
      comments_only = true,
      keyword = "wide",
    },
  })
end

return M
