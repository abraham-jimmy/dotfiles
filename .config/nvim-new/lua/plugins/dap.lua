local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function executable_path()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

local function executable_args()
  local input = vim.fn.input("Arguments: ")
  return vim.split(input, " ", { plain = true, trimempty = true })
end

local function load_launch_json()
  local root = require("util.root").git_root(0)
  local path = root .. "/.vscode/launch.json"

  if vim.fn.filereadable(path) == 0 then
    vim.notify("launch.json not found at " .. path, vim.log.levels.WARN, { title = "nvim-new" })
    return
  end

  require("dap.ext.vscode").load_launchjs(path, { codelldb = { "c", "cpp", "cc" } })
  vim.notify("Loaded launch.json from " .. path, vim.log.levels.INFO, { title = "nvim-new" })
end

function M.setup()
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    vim.schedule(function()
      vim.notify("nvim-dap is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  local dap_view_ok, dap_view = pcall(require, "dap-view")
  if not dap_view_ok then
    vim.schedule(function()
      vim.notify("nvim-dap-view is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  local virtual_text_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
  if not virtual_text_ok then
    vim.schedule(function()
      vim.notify("nvim-dap-virtual-text is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  virtual_text.setup({})

  dap_view.setup({
    switchbuf = "uselast",
    winbar = {
      sections = { "scopes", "watches", "breakpoints", "threads", "repl", "console" },
      default_section = "scopes",
    },
    windows = {
      position = "right",
    },
  })

  dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
    },
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = executable_path,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Launch with args",
      type = "codelldb",
      request = "launch",
      program = executable_path,
      args = executable_args,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
    {
      name = "Attach to process",
      type = "codelldb",
      request = "attach",
      pid = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }

  dap.configurations.c = dap.configurations.cpp
  dap.configurations.cc = dap.configurations.cpp

  for name, sign in pairs(require("util.icons").dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define("Dap" .. name, {
      text = sign[1],
      texthl = sign[2] or "DiagnosticInfo",
      linehl = sign[3],
      numhl = sign[3],
    })
  end

  dap.listeners.before.attach["dap-view"] = function()
    dap_view.open()
  end
  dap.listeners.before.launch["dap-view"] = function()
    dap_view.open()
  end
  dap.listeners.before.event_terminated["dap-view"] = function()
    dap_view.close(true)
  end
  dap.listeners.before.event_exited["dap-view"] = function()
    dap_view.close(true)
  end

  map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
  map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "DAP: Conditional breakpoint" })
  map("n", "<leader>dc", dap.continue, { desc = "DAP: Continue/start" })
  map("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })
  map("n", "<leader>dU", dap.step_out, { desc = "DAP: Step out" })
  map("n", "<leader>dO", dap.step_over, { desc = "DAP: Step over" })
  map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate debug session" })
  map("n", "<leader>du", function()
    dap_view.toggle(true)
  end, { desc = "DAP: Toggle DAP view" })
  map("n", "<leader>dv", virtual_text.toggle, { desc = "DAP: Toggle virtual text" })
  map("n", "<leader>dL", load_launch_json, { desc = "DAP: Load launch.json" })
end

return M
