local M = {}

local function map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

function M.setup()
  local lazydev_ok, lazydev = pcall(require, "lazydev")
  if lazydev_ok then
    lazydev.setup({
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    })
  else
    vim.schedule(function()
      vim.notify("lazydev.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  end

  local ok = pcall(require, "lspconfig")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-lspconfig is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  vim.lsp.config("*", {
    root_markers = { ".git" },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_new_lsp_attach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      map(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP definition")
      map(bufnr, "n", "gr", vim.lsp.buf.references, "LSP references")
      map(bufnr, "n", "gI", vim.lsp.buf.implementation, "LSP implementation")
      map(bufnr, "n", "K", vim.lsp.buf.hover, "LSP hover")
      map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
      map(bufnr, { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
      map(bufnr, "n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace add")
      map(bufnr, "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace remove")
      map(bufnr, "n", "<leader>wl", function()
        vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO, { title = "nvim-new" })
      end, "Workspace list")
      map(bufnr, "n", "<leader>li", function()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local names = vim.tbl_map(function(item)
          return item.name
        end, clients)

        if #names == 0 then
          vim.notify("No LSP clients attached", vim.log.levels.WARN, { title = "nvim-new" })
          return
        end

        table.sort(names)
        vim.notify(table.concat(names, ", "), vim.log.levels.INFO, { title = "LSP clients" })
      end, "LSP client info")

      if client and client.name == "clangd" then
        map(bufnr, "n", "<leader><Tab>", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header")
      end

      if _G.MiniClue and MiniClue.ensure_buf_triggers then
        MiniClue.ensure_buf_triggers(bufnr)
      end
    end,
  })

  M.enable(require("lang").lsp_servers())
end

function M.enable(servers)
  if not servers or vim.tbl_isempty(servers) then
    return
  end

  local names = {}

  for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    names[#names + 1] = name
  end

  table.sort(names)
  vim.lsp.enable(names)
end

return M
