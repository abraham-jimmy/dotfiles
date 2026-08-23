vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    vim.schedule(function()
      vim.notify("gitsigns.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  gitsigns.setup({
    signs = {
      add = { text = "|" },
      change = { text = "|" },
      delete = { text = "_" },
      topdelete = { text = "_" },
      changedelete = { text = "~" },
      untracked = { text = "|" },
    },
    on_attach = function(bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
      end

      map("n", "]h", gitsigns.next_hunk, "Next hunk")
      map("n", "[h", gitsigns.prev_hunk, "Previous hunk")
      map({ "n", "x" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
      map({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
      map("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>gD", gitsigns.diffthis, "Diff this")
      map("n", "<leader>g~", function()
        gitsigns.diffthis("~")
      end, "Diff this against tilde")
      map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
    end,
  })
end

return M
