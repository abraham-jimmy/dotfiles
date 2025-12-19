local on_attach = function(client, bufnr)
  -- Autoformat on save
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = "LspFormatOnSave", buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormatOnSave", {}),
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

return {
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },

    dependencies = {
      { 'williamboman/mason.nvim',          config = true },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'j-hui/fidget.nvim',                tag = 'legacy', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },

    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
          },
        },

        stylua = {
          -- settings = {
          --   Lua = {
          --     workspace = { checkThirdParty = false },
          --     telemetry = { enable = false },
          --   },
          -- },
        },
        bashls = {},
        pyright = {},
      },
    },
    -- Add all configs and enable them
    config = function(_, opts)
      -- -- Autoformat on save
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   callback = function(args)
      --     vim.lsp.buf.format({ async = false })
      --   end,
      -- })

      -- Install servers via mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(opts.servers),
      })

      -- Set up servers
      for server, config in pairs(opts.servers or {}) do
        config.on_attach = on_attach
        vim.lsp.config[server] = config
        -- Not needed?
        vim.lsp.enable(server)
      end

      -- Add specific keybindings to clangd
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Clangd specific keymaps",
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client ~= nil and client.name == "clangd" then
            vim.keymap.set(
              "n",
              "<leader><Tab>",
              "<cmd>ClangdSwitchSourceHeader<CR>",
              { buffer = bufnr, desc = "Switch between source and header" }
            )
          end
        end,
      })
    end
  },

  {
    'p00f/clangd_extensions.nvim',
    ft = { "c", "cpp" },
    opts = {}
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },

}
