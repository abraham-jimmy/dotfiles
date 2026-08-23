vim.pack.add(
  { { src = "https://github.com/folke/sidekick.nvim.git", version = "v2.1.0" } },
  { confirm = false, load = true }
)

local M = {}

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

function M.setup()
  local ok, sidekick = pcall(require, "sidekick")
  if not ok then
    vim.schedule(function()
      vim.notify("sidekick.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  sidekick.setup({
    nes = { enabled = false },
    cli = {
      mux = { backend = "tmux", enabled = true },
      picker = "fzf-lua",
    },
  })

  map({ "n", "t", "i", "x" }, "<C-.>", function()
    require("sidekick.cli").toggle({ name = "opencode", focus = true })
  end, "OpenCode toggle")
  map("n", "<leader>aa", function()
    require("sidekick.cli").toggle({ name = "opencode", focus = true })
  end, "OpenCode toggle")
  map("n", "<leader>ao", function()
    require("sidekick.cli").focus({ name = "opencode" })
  end, "OpenCode focus")
  map("n", "<leader>as", function()
    require("sidekick.cli").select({ filter = { installed = true } })
  end, "OpenCode select CLI")
  map("n", "<leader>ad", function()
    require("sidekick.cli").send({ msg = "{diagnostics}" })
  end, "OpenCode send diagnostics")
  map({ "n", "x" }, "<leader>at", function()
    require("sidekick.cli").send({ msg = "{this}" })
  end, "OpenCode send context")
  map("n", "<leader>af", function()
    require("sidekick.cli").send({ msg = "{file}" })
  end, "OpenCode send file")
  map("x", "<leader>av", function()
    require("sidekick.cli").send({ msg = "{selection}" })
  end, "OpenCode send selection")
  map({ "n", "x" }, "<leader>ap", function()
    require("sidekick.cli").prompt()
  end, "OpenCode prompt")
end

return M
