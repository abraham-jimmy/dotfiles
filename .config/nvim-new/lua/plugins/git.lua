local M = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function dotfiles_git(args)
  local cmd = vim.list_extend({
    "/usr/bin/git",
    "--git-dir=" .. vim.env.HOME .. "/.dotfiles",
    "--work-tree=" .. vim.env.HOME,
  }, args)

  return vim.system(cmd, { text = true }):wait()
end

local function is_dotfiles_tracked(path)
  if not path or path == "" then
    return false
  end

  return dotfiles_git({ "ls-files", "--error-unmatch", path }).code == 0
end

local function build_dotfiles_snapshot()
  local snapshot_dir = vim.fn.stdpath("cache") .. "/codediff-dotfiles"
  local clone

  vim.fn.delete(snapshot_dir, "rf")

  clone = vim.system({
    "git",
    "clone",
    "--shared",
    "--quiet",
    vim.env.HOME .. "/.dotfiles",
    snapshot_dir,
  }, { text = true }):wait()

  if clone.code ~= 0 then
    return nil, clone.stderr ~= "" and clone.stderr or "Unable to create dotfiles snapshot"
  end

  local listed = dotfiles_git({ "ls-files", "-z" })
  if listed.code ~= 0 then
    return nil, listed.stderr ~= "" and listed.stderr or "Unable to list dotfiles tracked files"
  end

  local tracked_files = vim.split(listed.stdout, "\0", { plain = true, trimempty = true })

  for _, rel in ipairs(tracked_files) do
    local source = vim.env.HOME .. "/" .. rel
    local target = snapshot_dir .. "/" .. rel

    if vim.uv.fs_stat(source) then
      vim.fn.mkdir(vim.fn.fnamemodify(target, ":h"), "p")

      local copied = vim.system({ "cp", "-a", source, target }, { text = true }):wait()
      if copied.code ~= 0 then
        return nil, copied.stderr ~= "" and copied.stderr or ("Unable to copy dotfiles file: " .. rel)
      end
    else
      vim.fn.delete(target)
    end
  end

  vim.system({ "git", "-C", snapshot_dir, "add", "-N", "." }, { text = true }):wait()

  return snapshot_dir, nil
end

local function run_codediff_in_dir(dir, command)
  local old_cwd = vim.fn.getcwd()
  local escaped_old = vim.fn.fnameescape(old_cwd)
  local escaped_new = vim.fn.fnameescape(dir)

  local ok, err = pcall(function()
    vim.cmd("lcd " .. escaped_new)
    vim.cmd(command)
  end)

  vim.cmd("lcd " .. escaped_old)

  if not ok then
    vim.notify(type(err) == "string" and err or "Unable to launch CodeDiff", vim.log.levels.ERROR, { title = "nvim-new" })
  end
end

local function write_temp_copy(source_path, lines)
  local temp = vim.fn.tempname()
  local extension = vim.fn.fnamemodify(source_path, ":e")
  if extension ~= "" then
    temp = temp .. "." .. extension
  end

  vim.fn.writefile(lines, temp, "b")
  return temp
end

local function open_current_file_diff()
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("Current buffer is not a file", vim.log.levels.WARN, { title = "nvim-new" })
    return
  end

  local tracked = dotfiles_git({ "ls-files", "--error-unmatch", current_file })
  if tracked.code == 0 then
    local rel = vim.fn.fnamemodify(current_file, ":~")
    if vim.startswith(rel, "~/") then
      rel = rel:sub(3)
    end

    local show = dotfiles_git({ "show", "HEAD:" .. rel })
    if show.code ~= 0 then
      local stderr = show.stderr or ""
      if stderr:match("not in 'HEAD'") or stderr:match("exists on disk, but not in 'HEAD'") then
        local temp = write_temp_copy(current_file, {})
        vim.cmd("CodeDiff file " .. vim.fn.fnameescape(temp) .. " " .. vim.fn.fnameescape(current_file))
        return
      end

      vim.notify(stderr ~= "" and stderr or "Unable to read dotfiles HEAD version", vim.log.levels.ERROR, { title = "nvim-new" })
      return
    end

    local lines = vim.split(show.stdout, "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines, #lines)
    end
    local temp = write_temp_copy(current_file, lines)

    vim.cmd("CodeDiff file " .. vim.fn.fnameescape(temp) .. " " .. vim.fn.fnameescape(current_file))
    return
  end

  vim.cmd("CodeDiff file HEAD")
end

local function open_repo_diff()
  local current_file = vim.api.nvim_buf_get_name(0)

  if is_dotfiles_tracked(current_file) then
    local snapshot_dir, err = build_dotfiles_snapshot()
    if not snapshot_dir then
      vim.notify(err, vim.log.levels.ERROR, { title = "nvim-new" })
      return
    end

    run_codediff_in_dir(snapshot_dir, "CodeDiff")
    return
  end

  vim.cmd("CodeDiff")
end

local function open_repo_history()
  local current_file = vim.api.nvim_buf_get_name(0)

  if is_dotfiles_tracked(current_file) then
    local snapshot_dir, err = build_dotfiles_snapshot()
    if not snapshot_dir then
      vim.notify(err, vim.log.levels.ERROR, { title = "nvim-new" })
      return
    end

    run_codediff_in_dir(snapshot_dir, "CodeDiff history")
    return
  end

  vim.cmd("CodeDiff history")
end

function M.setup()
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if not gitsigns_ok then
    vim.schedule(function()
      vim.notify("gitsigns.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
  else
    gitsigns.setup({
      signs = {
        add = { text = "|" },
        change = { text = "|" },
        delete = { text = "_" },
        topdelete = { text = "_" },
        changedelete = { text = "~" },
        untracked = { text = "|" },
      },
      on_attach = function(bufnr)
        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        bmap("n", "]h", gitsigns.next_hunk, "Next hunk")
        bmap("n", "[h", gitsigns.prev_hunk, "Previous hunk")
        bmap({ "n", "x" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        bmap({ "n", "x" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        bmap("n", "<leader>gS", gitsigns.stage_buffer, "Stage buffer")
        bmap("n", "<leader>gu", gitsigns.undo_stage_hunk, "Undo stage hunk")
        bmap("n", "<leader>gR", gitsigns.reset_buffer, "Reset buffer")
        bmap("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
        bmap("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "Blame line")
        bmap("n", "<leader>gD", gitsigns.diffthis, "Diff this")
        bmap("n", "<leader>g~", function()
          gitsigns.diffthis("~")
        end, "Diff this against tilde")
        bmap({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    })
  end

  local codediff_ok, codediff = pcall(require, "codediff")
  if not codediff_ok then
    vim.schedule(function()
      vim.notify("codediff.nvim is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
    end)
    return
  end

  codediff.setup({
    diff = {
      disable_inlay_hints = true,
      jump_to_first_change = true,
    },
    explorer = {
      initial_focus = "explorer",
    },
    history = {
      initial_focus = "history",
    },
  })

  local function install_codediff_hint_map(tabpage)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.keymap.set("n", "<leader>?", function()
          require("util.clue_panel").toggle_codediff(tabpage)
        end, { buffer = bufnr, desc = "CodeDiff: Toggle hints", noremap = true, silent = true, nowait = true })
      end
    end
  end

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("nvim_new_codediff_hints", { clear = true }),
    pattern = "CodeDiffOpen",
    callback = function(event)
      vim.schedule(function()
        local data = event.data or {}
        local tabpage = data.tabpage or vim.api.nvim_get_current_tabpage()
        install_codediff_hint_map(tabpage)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("nvim_new_codediff_hint_refresh", { clear = true }),
    callback = function()
      local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
      if not ok then
        return
      end

      local tabpage = vim.api.nvim_get_current_tabpage()
      if lifecycle.get_session(tabpage) then
        install_codediff_hint_map(tabpage)
      end
    end,
  })

  map("n", "<leader>gd", open_repo_diff, { desc = "CodeDiff repo changes" })
  map("n", "<leader>gf", open_current_file_diff, { desc = "CodeDiff file vs HEAD" })
  map("n", "<leader>gh", open_repo_history, { desc = "CodeDiff history" })
end

return M
