vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig.git" } }, { confirm = false, load = true })

local M = {}
local python_attach_notified = {}

local function map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

local function preview_definition(bufnr)
  local method = "textDocument/definition"

  vim.lsp.buf_request_all(bufnr, method, function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, function(results)
    local locations = {}
    local seen = {}

    for _, response in pairs(results) do
      local result = response and response.result
      if result then
        local items = vim.islist(result) and result or { result }

        for _, location in ipairs(items) do
          local uri = location.targetUri or location.uri
          local range = location.targetSelectionRange or location.targetRange or location.range
          local key = uri and range and string.format("%s:%d:%d", uri, range.start.line, range.start.character) or nil

          if key and not seen[key] then
            seen[key] = true
            locations[#locations + 1] = location
          end
        end
      end
    end

    if #locations == 0 then
      vim.notify("No definition found", vim.log.levels.INFO, { title = "LSP" })
      return
    end

    local function show(location)
      if location then
        vim.lsp.util.preview_location(location, { border = "rounded", max_height = 30, max_width = 100 })
      end
    end

    if #locations == 1 then
      show(locations[1])
      return
    end

    vim.ui.select(locations, {
      prompt = "Definitions",
      format_item = function(location)
        local uri = location.targetUri or location.uri
        local range = location.targetSelectionRange or location.targetRange or location.range
        local path = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":~:.")
        return string.format("%s:%d:%d", path, range.start.line + 1, range.start.character + 1)
      end,
    }, show)
  end)
end

function M.setup()
  local ok = pcall(require, "lspconfig")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-lspconfig is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  vim.lsp.config("*", {
    root_markers = { ".git" },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_attach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client and client.name == "basedpyright" and not python_attach_notified[client.id] then
        python_attach_notified[client.id] = true

        local root = client.config._nvim_python_root or client.config.root_dir or vim.fn.getcwd()
        local python_path = client.config._nvim_python_path
        local expected = client.config._nvim_python_expected or vim.fs.joinpath(root, ".venv", "bin", "python")

        if python_path then
          vim.notify(
            string.format("basedpyright attached\nroot: %s\npython: %s", root, python_path),
            vim.log.levels.INFO,
            { title = "Python LSP" }
          )
        else
          vim.notify(
            string.format("basedpyright attached without repo-local .venv\nroot: %s\nexpected: %s", root, expected),
            vim.log.levels.WARN,
            { title = "Python LSP" }
          )
        end
      end

      map(bufnr, "n", "gd", vim.lsp.buf.definition, "LSP definition")
      map(bufnr, "n", "gD", function()
        preview_definition(bufnr)
      end, "LSP definition preview")
      map(bufnr, "n", "gr", vim.lsp.buf.references, "LSP references")
      map(bufnr, "n", "gI", vim.lsp.buf.implementation, "LSP implementation")
      map(bufnr, "n", "K", vim.lsp.buf.hover, "LSP hover")
      map(bufnr, "n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
      map(bufnr, { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
      map(bufnr, "n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Workspace add")
      map(bufnr, "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Workspace remove")
      map(bufnr, "n", "<leader>wl", function()
        vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO, { title = "nvim" })
      end, "Workspace list")
      map(bufnr, "n", "<leader>li", function()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local names = vim.tbl_map(function(item)
          return item.name
        end, clients)

        if #names == 0 then
          vim.notify("No LSP clients attached", vim.log.levels.WARN, { title = "nvim" })
          return
        end

        table.sort(names)
        vim.notify(table.concat(names, ", "), vim.log.levels.INFO, { title = "LSP clients" })
      end, "LSP client info")

      if client and client.name == "clangd" then
        map(bufnr, "n", "<leader><Tab>", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header")
      end

      if client and client.name == "eslint" then
        map(bufnr, "n", "<leader>lf", "<cmd>LspEslintFixAll<cr>", "ESLint fix all")
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
