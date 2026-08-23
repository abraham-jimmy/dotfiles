vim.pack.add({ { src = "https://github.com/ibhagwan/fzf-lua.git" } }, { confirm = false, load = true })

local M = {}

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

function M.setup()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.schedule(function()
      vim.notify("fzf-lua is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  fzf.setup({
    winopts = {
      preview = { hidden = false },
    },
  })

  map("n", "<leader>b", fzf.buffers, "Buffers")
  map("n", "<leader>ff", fzf.files, "Files")
  map("n", "<leader>fp", function()
    fzf.files({ cwd = vim.fn.stdpath("config") })
  end, "Config files")
  map("n", "<leader>fg", fzf.git_files, "Git files")
  map("n", "<leader>sg", fzf.grep, "Grep")
  map("n", "<leader>sf", fzf.live_grep, "Live grep")
  map("n", "<leader>/", fzf.lgrep_curbuf, "Current buffer grep")
  map("n", "<leader>sr", fzf.resume, "Resume search")
  map("n", "<leader>sd", fzf.diagnostics_document, "Document diagnostics")
  map("n", "<leader>sk", fzf.keymaps, "Keymaps")
  map("n", "<leader>sw", fzf.grep_cword, "Current word")
  map("x", "<leader>sw", fzf.grep_visual, "Selection")
  map("n", "<leader>sG", function()
    fzf.grep({ cwd = require("util.root").git_root(0) })
  end, "Grep git root")
end

return M
