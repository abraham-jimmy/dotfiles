local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function M.setup()
  local tmux_ok, tmux = pcall(require, "tmux")
  if not tmux_ok then
    vim.schedule(function()
      vim.notify("tmux.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  elseif tmux.setup then
    tmux.setup({})

    map("n", "<C-h>", tmux.move_left, { desc = "Move left across nvim/tmux" })
    map("n", "<C-j>", tmux.move_down, { desc = "Move down across nvim/tmux" })
    map("n", "<C-k>", tmux.move_up, { desc = "Move up across nvim/tmux" })
    map("n", "<C-l>", tmux.move_right, { desc = "Move right across nvim/tmux" })
  end

  local sidekick_ok, sidekick = pcall(require, "sidekick")
  if not sidekick_ok then
    vim.schedule(function()
      vim.notify("sidekick.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  sidekick.setup({
    nes = {
      enabled = false,
    },
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
      picker = "fzf-lua",
    },
  })

  map({ "n", "t", "i", "x" }, "<C-.>", function()
    require("sidekick.cli").toggle({ name = "opencode", focus = true })
  end, { desc = "OpenCode toggle" })
  map("n", "<leader>aa", function()
    require("sidekick.cli").toggle({ name = "opencode", focus = true })
  end, { desc = "OpenCode toggle" })
  map("n", "<leader>ao", function()
    require("sidekick.cli").focus({ name = "opencode" })
  end, { desc = "OpenCode focus" })
  map("n", "<leader>as", function()
    require("sidekick.cli").select({ filter = { installed = true } })
  end, { desc = "OpenCode select CLI" })
  map("n", "<leader>ad", function()
    require("sidekick.cli").send({ msg = "{diagnostics}" })
  end, { desc = "OpenCode send diagnostics" })
  map({ "n", "x" }, "<leader>at", function()
    require("sidekick.cli").send({ msg = "{this}" })
  end, { desc = "OpenCode send context" })
  map("n", "<leader>af", function()
    require("sidekick.cli").send({ msg = "{file}" })
  end, { desc = "OpenCode send file" })
  map("x", "<leader>av", function()
    require("sidekick.cli").send({ msg = "{selection}" })
  end, { desc = "OpenCode send selection" })
  map({ "n", "x" }, "<leader>ap", function()
    require("sidekick.cli").prompt()
  end, { desc = "OpenCode prompt" })
end

return M
