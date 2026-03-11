local M = {}

function M.setup()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then
    vim.schedule(function()
      vim.notify("blink.cmp is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  blink.setup({
    keymap = {
      preset = "default",
      ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      documentation = {
        auto_show = false,
      },
    },
    sources = {
      default = { "lazydev", "lsp", "path", "buffer" },
      providers = {
        lazydev = {
          module = "lazydev.integrations.blink",
          name = "LazyDev",
          score_offset = 100,
        },
      },
    },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  })
end

return M
