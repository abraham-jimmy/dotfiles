local function augroup(name)
  return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

local tmux_file_dir = {
  applied = nil,
  pending = nil,
  running = false,
}

local function apply_tmux_file_dir()
  if tmux_file_dir.running or not tmux_file_dir.pending or tmux_file_dir.pending == tmux_file_dir.applied then
    return
  end

  local dir = tmux_file_dir.pending
  tmux_file_dir.running = true

  vim.system({ "tmux", "set-option", "-p", "-t", vim.env.TMUX_PANE, "-q", "@nvim_file_dir", dir }, {}, function(result)
    vim.schedule(function()
      tmux_file_dir.running = false
      if result.code == 0 then
        tmux_file_dir.applied = dir
      else
        tmux_file_dir.applied = nil
      end
      if tmux_file_dir.pending ~= dir then
        apply_tmux_file_dir()
      end
    end)
  end)
end

local function sync_tmux_file_dir()
  if not vim.env.TMUX or not vim.env.TMUX_PANE then
    return
  end

  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()

  if dir == "" then
    return
  end

  tmux_file_dir.pending = dir
  apply_tmux_file_dir()
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("formatoptions"),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("spec_commentstring"),
  pattern = "spec",
  callback = function()
    vim.opt_local.commentstring = "# %s"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.hl.hl_op()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "gitsigns-blame",
    "help",
    "lspinfo",
    "man",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
  group = augroup("recording_statusline"),
  callback = function()
    vim.schedule(function()
      vim.cmd("redrawstatus")
    end)
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("checktime"),
  command = "checktime",
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "DirChanged", "WinEnter" }, {
  group = augroup("tmux_file_dir"),
  callback = sync_tmux_file_dir,
})
