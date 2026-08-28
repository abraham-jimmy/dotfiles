local M = {}

local lit_rules = {
  ["no-boolean-in-attribute-binding"] = "off",
  ["no-complex-attribute-binding"] = "off",
  ["no-incompatible-property-type"] = "warning",
  ["no-incompatible-type-binding"] = "off",
}

local function lit_plugin()
  local location = vim.fs.joinpath(vim.env.HOME, ".local", "lib")
  if not vim.uv.fs_stat(vim.fs.joinpath(location, "node_modules", "ts-lit-plugin")) then
    return {}
  end

  return {
    {
      name = "ts-lit-plugin",
      location = location,
      enableForWorkspaceTypeScriptVersions = true,
    },
  }
end

local function configure_lit_plugin(client, bufnr)
  if vim.tbl_isempty(lit_plugin()) then
    return
  end

  client:request("workspace/executeCommand", {
    command = "_typescript.configurePlugin",
    arguments = { "ts-lit-plugin", { rules = lit_rules } },
  }, function(err)
    if err then
      vim.notify("Unable to configure ts-lit-plugin: " .. err.message, vim.log.levels.WARN, { title = "vtsls" })
    end
  end, bufnr)
end

function M.tooling()
  return {
    lsp = {
      eslint = {
        handlers = {
          ["eslint/noLibrary"] = function()
            return {}
          end,
        },
        settings = {
          codeActionOnSave = { enable = false },
          experimental = { useFlatConfig = false },
          format = false,
          run = "onType",
          workingDirectory = { mode = "auto" },
        },
      },
      vtsls = {
        on_attach = configure_lit_plugin,
        settings = {
          typescript = {
            tsserver = { maxTsServerMemory = 8192 },
          },
          vtsls = {
            autoUseWorkspaceTsdk = true,
            tsserver = { globalPlugins = lit_plugin() },
          },
        },
      },
    },
    linters_by_ft = {
      javascript = { "tslint" },
      javascriptreact = { "tslint" },
      typescript = { "tslint" },
      typescriptreact = { "tslint" },
    },
    linters_on_write = { "tslint" },
    formatters_by_ft = {
      javascript = { "prettier", stop_after_first = true },
      javascriptreact = { "prettier", stop_after_first = true },
      typescript = { "prettier", stop_after_first = true },
      typescriptreact = { "prettier", stop_after_first = true },
    },
    formatters = {
      prettier = { require_cwd = true },
    },
  }
end

return M
