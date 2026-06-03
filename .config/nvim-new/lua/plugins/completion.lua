local M = {}

local function sanitize_lsp_items(_, items)
  for _, item in ipairs(items) do
    if item.labelDetails ~= nil and type(item.labelDetails) ~= "table" then
      item.labelDetails = nil
    elseif item.labelDetails then
      if item.labelDetails.detail ~= nil and type(item.labelDetails.detail) ~= "string" then
        item.labelDetails.detail = nil
      end
      if item.labelDetails.description ~= nil and type(item.labelDetails.description) ~= "string" then
        item.labelDetails.description = nil
      end
    end
  end

  return items
end

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
        lsp = {
          transform_items = sanitize_lsp_items,
        },
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
