return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvimtools/hydra.nvim",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {}
      },
      {
        "igorlfs/nvim-dap-view",
        keys = {
          { "<leader>du", function() require("dap-view").toggle(true) end, desc = "Dap View toggle" },
        },
        opts = {
          winbar = {
            sections = { "scopes", "watches", "breakpoints", "threads", "repl", "console" },
            default_section = "scopes"
          },
          windows = {
            position = "right",
          },
          switchbuf = "uselast"
        }
      }
    },
    keys = {
      "<leader>dd",
    },
    config = function()
      local dap = require("dap")
      local dv = require("dap-view")
      local Hydra = require("hydra")
      local vscode = require("dap.ext.vscode")
      local widgets = require("dap.ui.widgets")

      -- DAP Configs
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'OpenDebugAD7'
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
        },
        {
          name = 'Attach to process',
          type = 'cppdbg',
          request = 'attach',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          processId = "${command:pickProcess}"
        },
      }

      -- Icons
      -- vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "GitSignsChangeInline" })

      for name, sign in pairs(require('util.icons').dap) do
        sign = type(sign) == "table" and sign or { sign }
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end


      dap.listeners.before.attach["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.before.launch["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.before.event_terminated["dap-view-config"] = function()
        dv.close(true)
      end
      dap.listeners.before.event_exited["dap-view-config"] = function()
        dv.close(true)
      end

      -- Update statusline
      local original_mode = require("mini.statusline").section_mode
      local function set_statusline()
        require("mini.statusline").section_mode = function()
          return "DEBUG", "MiniStatuslineModeOther"
        end
      end

      local function restore_mode()
        require("mini.statusline").section_mode = original_mode
      end

      -- Keybind helper
      local debug_help_hydra = Hydra({
        name = "Debug Help",
        mode = "n",
        config = {
          color = "amaranth",
          invoke_on_body = true,
          hint = {
            position = "bottom",
            type = "window",
          },
        },
        heads = {
          { "<Esc>", nil, { exit = true, nowait = true } },
          { "?",     nil, { exit = true, nowait = true } },
          { "q",     nil, { exit = true, nowait = true } },
        },
        hint = [[
  [ Debug Hydra Bindings ]
  c: Continue     r: Run to cursor
  L: Step over    I: Step in     O: Step out
  t: Toggle BP    x: Clear BPs   X: Terminate
  H: Hover        a: Watch expr  U: Toggle views
  X: Terminate    J: Stack down  K: Stack up
  R: REPL         S: Scopes      T: Threads
  C: Console      B: Breakpoints q: Quit Hydra
  ]],
      })

      Hydra({
        config = {
          hint = false,
          color = 'pink',
          invoke_on_body = true,
          on_enter = function()
            set_statusline()
          end,
          on_exit = function()
            restore_mode()
          end
        },
        mode = "n",
        body = "<leader>dd",
        heads = {
          { "c", dap.continue,                                  { desc = false } },
          { "r", dap.run_to_cursor,                             { desc = false } },
          { "L", dap.step_over,                                 { desc = false } },
          { "I", dap.step_into,                                 { desc = false } },
          { "O", dap.step_out,                                  { desc = false } },
          { "H", widgets.hover,                                 { desc = false } },
          { "K", dap.down,                                      { desc = false } },
          { "J", dap.up,                                        { desc = false } },
          { "t", dap.toggle_breakpoint,                         { desc = false } },
          { "x", dap.clear_breakpoints,                         { desc = false } },
          { "X", dap.terminate,                                 { desc = false } },
          { "a", dv.add_expr,                                   { desc = false } },
          { "R", function() dv.jump_to_view("repl") end,        { desc = false } },
          { "S", function() dv.jump_to_view("scopes") end,      { desc = false } },
          { "T", function() dv.jump_to_view("threads") end,     { desc = false } },
          { "W", function() dv.jump_to_view("watches") end,     { desc = false } },
          { "C", function() dv.jump_to_view("console") end,     { desc = false } },
          { "B", function() dv.jump_to_view("breakpoints") end, { desc = false } },
          { "U", function() dv.toggle(true) end,                { desc = false } },
          { "?", function() debug_help_hydra:activate() end,    { desc = "show help" } },
          { "q", nil,                                           { exit = true, nowait = true, desc = false } },
        },
      })

      local function load_launch_json()
        local root = require('util').git_root()
        if not root then
          vim.notify("Git root not found", vim.log.levels.WARN)
          return
        end
        local path = root .. "/.vscode/launch.json"
        if vim.fn.filereadable(path) == 1 then
          vscode.load_launchjs(path, { cppdbg = { "c", "cpp", "cc" } })
          vim.notify("Loaded launch.json from " .. path, vim.log.levels.INFO)
        else
          vim.notify("launch.json not found at " .. path, vim.log.levels.WARN)
        end
      end
      load_launch_json()

      vim.keymap.set("n", "<leader>dl", load_launch_json, { desc = "Load launch.json" })
      vim.keymap.set("n", "<leader>dv", function() require("nvim-dap-virtual-text").toggle() end,
        { desc = "Toggle DAP virtual text" })
    end,
  }
} -- return {
--
--   -- Original DAP (Debug Adapter Tool)
--   {
--     "mfussenegger/nvim-dap",
--     recommended = true,
--     desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
--
--     dependencies =
--     {
--       -- rcarriga fancy UI
--       {
--         'rcarriga/nvim-dap-ui',
--         dependencies = { "nvim-neotest/nvim-nio" },
--         -- stylua: ignore
--         keys = {
--           { "<leader>du", function() require("dapui").toggle() end,               desc = "Dap UI" },
--           { "<leader>de", function() require("dapui").eval() end,                 desc = "Eval",        mode = { "n", "v" } },
--           { "<leader>dR", function() require("dapui").open({ reset = true }) end, desc = "Reset Dap UI" },
--           {
--             "<leader>dw",
--             function()
--               require("dapui").elements.watches.add(vim.fn.expand("<cword>"))
--             end,
--             desc = "Add variable under cursor to watch list",
--             mode = { "n" },
--           },
--
--         },
--         opts = {},
--         config = function(_, opts)
--           local dap = require("dap")
--           local dapui = require("dapui")
--           dapui.setup(opts)
--           dap.listeners.after.event_initialized.dapui_config = function()
--             dapui.open({})
--           end
--           dap.listeners.before.launch.dapui_config = function()
--             dapui.open()
--           end
--           dap.listeners.before.event_terminated.dapui_config = function()
--             dapui.close({})
--           end
--           dap.listeners.before.event_exited.dapui_config = function()
--             dapui.close({})
--           end
--         end,
--       },
--
--     },
--
--     -- End of dependencies
--
--     -- stylua: ignore
--     keys = {
--       { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
--       { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
--       { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
--       { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
--       { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
--       { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
--       { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
--       { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
--       { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
--       { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
--       { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
--       { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
--       { "<leader>dP", function() require("dap").pause() end,                                                desc = "Pause" },
--       -- { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
--       { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
--       { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
--       -- { "<leader>dW", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
--       {
--         "<leader>dv",
--         function()
--           local launch_path = require('util').git_root() .. '/.vscode/launch.json'
--           require('dap.ext.vscode').load_launchjs(launch_path, { cppdbg = { 'cc', 'cpp' } })
--           vim.notify("Loaded launch.json", vim.log.levels.INFO)
--         end,
--         desc = "Debug: Load launch.json"
--       } },
--
--     config = function()
--       local dap = require 'dap'
--
--       dap.adapters.cppdbg = {
--         id = 'cppdbg',
--         type = 'executable',
--         command = 'OpenDebugAD7'
--       }
--
--       dap.configurations.cpp = {
--         -- {
--         --   name = "Launch file",
--         --   type = "cppdbg",
--         --   request = "launch",
--         --   program = function()
--         --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--         --   end,
--         --   cwd = '${workspaceFolder}',
--         --   stopAtEntry = true,
--         -- },
--         -- {
--         --   name = 'Attach to process',
--         --   type = 'cppdbg',
--         --   request = 'attach',
--         --   program = function()
--         --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--         --   end,
--         --   processId = "${command:pickProcess}"
--         -- },
--         -- {
--         --   name = 'Attach to gdbserver :1234',
--         --   type = 'cppdbg',
--         --   request = 'launch',
--         --   MIMode = 'gdb',
--         --   miDebuggerServerAddress = 'localhost:1234',
--         --   miDebuggerPath = '/usr/bin/gdb',
--         --   cwd = '${workspaceFolder}',
--         --   program = function()
--         --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--         --   end,
--         -- },
--       }
--
--       vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
--     end,
--
--     --   -- load mason-nvim-dap here, after all adapters have been setup
--     --   if LazyVim.has("mason-nvim-dap.nvim") then
--     --     require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
--     --   end
--     --
--     --   vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
--     --
--     --   for name, sign in pairs(LazyVim.config.icons.dap) do
--     --     sign = type(sign) == "table" and sign or { sign }
--     --     vim.fn.sign_define(
--     --       "Dap" .. name,
--     --       { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
--     --     )
--     --   end
--     --
--     --   -- setup dap config by VsCode launch.json file
--     --   local vscode = require("dap.ext.vscode")
--     --   local json = require("plenary.json")
--     --   vscode.json_decode = function(str)
--     --     return vim.json.decode(json.json_strip_comments(str))
--     --   end
--     -- end,
--   },
--
--   -- Virtual Text for the debugger
--   -- {
--   --   "rcarriga/nvim-dap-ui",
--   --   dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
--   --   version = '*',
--   --   opts = {},
--   -- },
--
--
--
--   --   {
--   --     "mfussenegger/nvim-dap",
--   --     config = function()
--   --       local dap = require("dap")
--   --       -- Configure your debug adapters here
--   --       -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
--   --     end,
--   --   },
--   --   {
--   --     "miroshQa/debugmaster.nvim",
--   --     config = function()
--   --       local dm = require("debugmaster")
--   --       -- make sure you don't have any other keymaps that starts with "<leader>d" to avoid delay
--   --       vim.keymap.set({ "n", "v" }, "<leader>d", dm.mode.toggle, { nowait = true })
--   --       -- If you want to disable debug mode in addition to leader+d using the Escape key:
--   --       -- vim.keymap.set("n", "<Esc>", dm.mode.disable)
--   --       -- This might be unwanted if you already use Esc for ":noh"
--   --       vim.keymap.set("t", "<C-/>", "<C-\\><C-n>", {desc = "Exit terminal mode"})
--   --     end
--   --
--   -- }
-- }
