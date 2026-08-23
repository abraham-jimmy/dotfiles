vim.pack.add({ { src = "https://github.com/nvim-lualine/lualine.nvim.git" } }, { confirm = false, load = true })

local M = {}

local function is_current_buffer_session(session)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.fn.getcwd()
  end

  path = vim.fs.normalize(path)
  local cwd = vim.fs.normalize(session.cwd):gsub("/$", "")
  return path == cwd or vim.startswith(path, cwd .. "/")
end

local function ai_status()
  local ok, status = pcall(require, "sidekick.status")
  if not ok then
    return "", false
  end

  local labels, seen = {}, {}
  local copilot = status.get(0)
  local busy = copilot and copilot.busy or false

  if copilot then
    labels[#labels + 1] = busy and "copilot..." or "copilot"
    seen.copilot = true
  end

  for _, session in ipairs(status.cli()) do
    if is_current_buffer_session(session) and not seen[session.tool] then
      labels[#labels + 1] = session.tool
      seen[session.tool] = true
    end
  end

  table.sort(labels)
  return #labels > 0 and "AI " .. table.concat(labels, ",") or "", busy
end

local function lsp_off()
  if vim.bo.buftype == "" and #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
    return "LSP off"
  end
  return ""
end

local function recording()
  local register = vim.fn.reg_recording()
  return register ~= "" and "REC @" .. register or ""
end

local function rows()
  return string.format("Ln %d/%d", vim.fn.line("."), vim.fn.line("$"))
end

function M.setup()
  local ok, lualine = pcall(require, "lualine")
  if not ok then
    vim.schedule(function()
      vim.notify("lualine.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  lualine.setup({
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = { left = "│", right = "│" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        winbar = { "NvimTree", "dashboard", "minifiles" },
      },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "", right = "" } } },
      lualine_b = { "branch", "diff", "diagnostics", { recording, color = "DiagnosticError" } },
      lualine_c = { { "filename", path = 0 } },
      lualine_x = {
        "searchcount",
        {
          "lsp_status",
          icon = " LSP",
          symbols = { done = "✓", separator = ", " },
        },
        { lsp_off, color = "Comment" },
        {
          function()
            return ai_status()
          end,
          cond = function()
            return ai_status() ~= ""
          end,
          color = function()
            local _, busy = ai_status()
            return busy and "DiagnosticWarn" or "Special"
          end,
        },
      },
      lualine_y = { "filetype" },
      lualine_z = { { rows, separator = { left = "", right = "" } } },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 0 } },
      lualine_x = {},
      lualine_y = {},
      lualine_z = { rows },
    },
    winbar = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { "filename", path = 3, file_status = false } },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "fzf", "nvim-tree", "quickfix" },
  })
end

return M
