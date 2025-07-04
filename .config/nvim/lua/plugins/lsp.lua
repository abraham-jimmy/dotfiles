return
{
  'neovim/nvim-lspconfig',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    -- 'williamboman/mason-lspconfig.nvim',

    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    { 'folke/neodev.nvim',       opts = {} },
  },
  opts = {
    autoformat = true,
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
  },
  config = function(_, opts)
    local lspconfig = require('lspconfig')


    local on_attach = function(_, bufnr)
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>ss', "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header (C/C++)")
      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('gr', "<cmd>FzfLua lsp_references<cr>", '[G]oto [R]eferences')
      nmap('gI', "<cmd>FzfLua lsp_implementations<cr>", '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('<leader>ds', "<cmd>FzfLua lsp_document_symbols<cr>", '[D]ocument [S]ymbols')
      nmap('<leader>ws', "<cmd>FzfLua lsp_workspace_symbols<cr>", '[W]orkspace [S]ymbols')

      -- See `:help K` for why this keymap
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

      -- Lesser used LSP functionality
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    require('neodev').setup()


    lspconfig.clangd.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed"
        }
      }
    })

    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        }
      }
    })


    -- mason
    -- require("mason").setup()
    -- require("mason-lspconfig").setup_handlers({
    --
    --   function(server_name)
    --     require("lspconfig")[server_name].setup {
    --       on_attach = on_attach,
    --       capabilities = capabilities
    --     }
    --   end,
    --
    --   ["lua_ls"] = function()
    --     require('neodev').setup()
    --     require('lspconfig').lua_ls.setup {
    --       on_attach = on_attach,
    --       capabilities = capabilities,
    --       settings = {
    --         Lua = {
    --           workspace = { checkThirdParty = false },
    --           telemetry = { enable = false },
    --         },
    --       }
    --     }
    --   end
    -- })

    -- mason_lspconfig.setup {
    --   ensure_installed = vim.tbl_keys(servers),
    -- }
  end
}
