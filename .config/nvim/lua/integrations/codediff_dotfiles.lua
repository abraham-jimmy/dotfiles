local M = {}

local dotfiles_review_sessions = {}
local pending_dotfiles_reviews = {}

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function cleanup_review_payload(review)
  if not review then
    return
  end

  if review.snapshot_dir then
    vim.fn.delete(review.snapshot_dir, "rf")
  end

  if review.temp_paths then
    for _, path in ipairs(review.temp_paths) do
      vim.fn.delete(path)
    end
  end
end

local function queue_pending_review(review)
  pending_dotfiles_reviews[#pending_dotfiles_reviews + 1] = review
end

local function discard_pending_review(review)
  for index, pending in ipairs(pending_dotfiles_reviews) do
    if pending == review then
      table.remove(pending_dotfiles_reviews, index)
      cleanup_review_payload(review)
      return
    end
  end
end

local function same_path(left, right)
  if not left or not right then
    return false
  end
  return vim.fs.normalize(vim.fn.fnamemodify(left, ":p")) == vim.fs.normalize(vim.fn.fnamemodify(right, ":p"))
end

local function take_pending_review(tabpage)
  local lifecycle = require("codediff.ui.lifecycle")
  local mode = lifecycle.get_mode(tabpage)
  local original_path, modified_path = lifecycle.get_paths(tabpage)
  local git_context = lifecycle.get_git_context(tabpage)

  for index, review in ipairs(pending_dotfiles_reviews) do
    local matches_file = review.kind == "file"
      and same_path(original_path, review.temp_paths[1])
      and same_path(modified_path, review.temp_paths[2])
    local matches_repo = review.kind == "repo"
      and mode == "explorer"
      and git_context
      and same_path(git_context.git_root, review.snapshot_dir)
    local matches_history = review.kind == "history"
      and mode == "history"
      and git_context
      and same_path(git_context.git_root, review.snapshot_dir)

    if matches_file or matches_repo or matches_history then
      return table.remove(pending_dotfiles_reviews, index)
    end
  end

  return nil
end

local function dotfiles_git(args)
  local cmd = vim.list_extend({
    "/usr/bin/git",
    "--git-dir=" .. vim.env.HOME .. "/.dotfiles",
    "--work-tree=" .. vim.env.HOME,
  }, args)

  return vim.system(cmd, { cwd = vim.env.HOME, text = true }):wait()
end

local function dotfiles_relpath(path)
  if not path or path == "" then
    return nil
  end

  local abs = vim.fn.fnamemodify(path, ":p")
  local home = vim.fn.fnamemodify(vim.env.HOME, ":p")
  if not vim.startswith(abs, home) then
    return nil
  end

  return abs:sub(#home + 1):gsub("^/", "")
end

local function is_dotfiles_tracked(path)
  local rel = dotfiles_relpath(path)
  if not rel or rel == "" then
    return false
  end

  return dotfiles_git({ "ls-files", "--error-unmatch", "--", rel }).code == 0
end

local function build_dotfiles_snapshot()
  local snapshot_dir = vim.fn.tempname()
  local clone = vim
    .system({
      "/usr/bin/git",
      "clone",
      "--shared",
      "--quiet",
      vim.env.HOME .. "/.dotfiles",
      snapshot_dir,
    }, { text = true })
    :wait()

  if clone.code ~= 0 then
    return nil, clone.stderr ~= "" and clone.stderr or "Unable to create dotfiles snapshot"
  end

  local listed = dotfiles_git({ "ls-files", "-z", "--full-name" })
  if listed.code ~= 0 then
    vim.fn.delete(snapshot_dir, "rf")
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
        vim.fn.delete(snapshot_dir, "rf")
        return nil, copied.stderr ~= "" and copied.stderr or ("Unable to copy dotfiles file: " .. rel)
      end
    else
      vim.fn.delete(target)
    end
  end

  local add = vim.system({ "/usr/bin/git", "-C", snapshot_dir, "add", "-N", "." }, { text = true }):wait()
  if add.code ~= 0 then
    vim.fn.delete(snapshot_dir, "rf")
    return nil, add.stderr ~= "" and add.stderr or "Unable to prepare dotfiles snapshot"
  end

  return snapshot_dir, nil
end

local function run_codediff(command, dir, review)
  local old_cwd = nil
  local escaped_old = nil
  local escaped_new = nil
  if dir then
    old_cwd = vim.fn.getcwd()
    escaped_old = vim.fn.fnameescape(old_cwd)
    escaped_new = vim.fn.fnameescape(dir)
  end

  local ok, err = pcall(function()
    if escaped_new then
      vim.cmd("lcd " .. escaped_new)
    end
    vim.cmd(command)
  end)

  if escaped_old then
    vim.cmd("lcd " .. escaped_old)
  end

  if not ok then
    discard_pending_review(review)
    vim.notify(type(err) == "string" and err or "Unable to launch CodeDiff", vim.log.levels.ERROR, { title = "nvim" })
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

local function detect_review_target(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr or 0)
  if path ~= "" and is_dotfiles_tracked(path) then
    return {
      kind = "dotfiles",
      abs_path = vim.fn.fnamemodify(path, ":p"),
      rel_path = dotfiles_relpath(path),
    }
  end

  return {
    kind = "normal",
    abs_path = path ~= "" and vim.fn.fnamemodify(path, ":p") or nil,
  }
end

local function open_dotfiles_file_review()
  local target = detect_review_target(0)
  if target.kind ~= "dotfiles" then
    vim.notify("Current buffer is not a tracked dotfiles file", vim.log.levels.WARN, { title = "nvim" })
    return
  end

  local show = dotfiles_git({ "show", "HEAD:" .. target.rel_path })
  if show.code ~= 0 then
    local stderr = show.stderr or ""
    if stderr:match("not in 'HEAD'") or stderr:match("exists on disk, but not in 'HEAD'") then
      show = { stdout = "", code = 0 }
    else
      vim.notify(
        stderr ~= "" and stderr or "Unable to read dotfiles HEAD version",
        vim.log.levels.ERROR,
        { title = "nvim" }
      )
      return
    end
  end

  local head_lines = vim.split(show.stdout, "\n", { plain = true })
  if head_lines[#head_lines] == "" then
    table.remove(head_lines, #head_lines)
  end

  local worktree_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local left = write_temp_copy(target.abs_path, head_lines)
  local right = write_temp_copy(target.abs_path, worktree_lines)

  local review = {
    kind = "file",
    temp_paths = { left, right },
  }
  queue_pending_review(review)

  run_codediff("CodeDiff file " .. vim.fn.fnameescape(left) .. " " .. vim.fn.fnameescape(right), nil, review)
end

local function open_dotfiles_repo_review()
  local snapshot_dir, err = build_dotfiles_snapshot()
  if not snapshot_dir then
    vim.notify(err, vim.log.levels.ERROR, { title = "nvim" })
    return
  end

  local review = {
    kind = "repo",
    snapshot_dir = snapshot_dir,
  }
  queue_pending_review(review)

  run_codediff("CodeDiff", snapshot_dir, review)
end

local function open_dotfiles_history_review()
  local snapshot_dir, err = build_dotfiles_snapshot()
  if not snapshot_dir then
    vim.notify(err, vim.log.levels.ERROR, { title = "nvim" })
    return
  end

  local review = {
    kind = "history",
    snapshot_dir = snapshot_dir,
  }
  queue_pending_review(review)

  run_codediff("CodeDiff history", snapshot_dir, review)
end

local function open_current_file_diff()
  local target = detect_review_target(0)
  if target.kind == "dotfiles" then
    open_dotfiles_file_review()
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("Current buffer is not a file", vim.log.levels.WARN, { title = "nvim" })
    return
  end

  vim.cmd("CodeDiff file HEAD")
end

local function open_repo_diff()
  local target = detect_review_target(0)
  if target.kind == "dotfiles" then
    open_dotfiles_repo_review()
    return
  end

  vim.cmd("CodeDiff")
end

local function open_repo_history()
  local target = detect_review_target(0)
  if target.kind == "dotfiles" then
    open_dotfiles_history_review()
    return
  end

  vim.cmd("CodeDiff history")
end

local function cleanup_dotfiles_review(tabpage)
  local review = dotfiles_review_sessions[tabpage]
  if not review then
    return
  end

  cleanup_review_payload(review)
  dotfiles_review_sessions[tabpage] = nil
end

function M.setup()
  local codediff_ok = pcall(require, "codediff")
  if not codediff_ok then
    vim.schedule(function()
      vim.notify("codediff.nvim is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local function is_dotfiles_review_tab(tabpage)
    return dotfiles_review_sessions[tabpage] ~= nil
  end

  local function apply_dotfiles_readonly_to_buffer(bufnr)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    vim.bo[bufnr].readonly = true
    vim.bo[bufnr].modifiable = false
  end

  local function apply_dotfiles_readonly_to_tab(tabpage)
    if not is_dotfiles_review_tab(tabpage) then
      return
    end

    local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
    if not ok then
      return
    end

    local original_bufnr, modified_bufnr = lifecycle.get_buffers(tabpage)
    local result_bufnr = lifecycle.get_result(tabpage)
    apply_dotfiles_readonly_to_buffer(original_bufnr)
    apply_dotfiles_readonly_to_buffer(modified_bufnr)
    apply_dotfiles_readonly_to_buffer(result_bufnr)
  end

  local function install_dotfiles_readonly_maps(tabpage)
    if not is_dotfiles_review_tab(tabpage) then
      return
    end

    local blocked = {
      "-",
      "S",
      "U",
      "X",
      "R",
      "do",
      "dp",
      "<leader>hs",
      "<leader>hu",
      "<leader>hr",
    }

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local bufnr = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(bufnr) then
        for _, lhs in ipairs(blocked) do
          vim.keymap.set("n", lhs, function()
            vim.notify("Dotfiles CodeDiff review is read-only", vim.log.levels.INFO, { title = "nvim" })
          end, {
            buffer = bufnr,
            desc = "Dotfiles review is read-only",
            noremap = true,
            silent = true,
            nowait = true,
          })
        end
      end
    end
  end

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("nvim_codediff_dotfiles_open", { clear = true }),
    pattern = "CodeDiffOpen",
    callback = function(event)
      vim.schedule(function()
        local data = event.data or {}
        local tabpage = data.tabpage or vim.api.nvim_get_current_tabpage()

        local review = take_pending_review(tabpage)
        if review then
          dotfiles_review_sessions[tabpage] = review
        end

        install_dotfiles_readonly_maps(tabpage)
        apply_dotfiles_readonly_to_tab(tabpage)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("nvim_codediff_dotfiles_cleanup", { clear = true }),
    pattern = "CodeDiffClose",
    callback = function(event)
      local data = event.data or {}
      if data.tabpage then
        cleanup_dotfiles_review(data.tabpage)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("nvim_codediff_dotfiles_exit_cleanup", { clear = true }),
    callback = function()
      for _, review in ipairs(pending_dotfiles_reviews) do
        cleanup_review_payload(review)
      end
      pending_dotfiles_reviews = {}

      for tabpage in pairs(dotfiles_review_sessions) do
        cleanup_dotfiles_review(tabpage)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "TabEnter" }, {
    group = vim.api.nvim_create_augroup("nvim_codediff_dotfiles_refresh", { clear = true }),
    callback = function()
      vim.schedule(function()
        vim.schedule(function()
          local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
          if not ok then
            return
          end

          local tabpage = vim.api.nvim_get_current_tabpage()
          if lifecycle.get_session(tabpage) then
            install_dotfiles_readonly_maps(tabpage)
            apply_dotfiles_readonly_to_tab(tabpage)
          end
        end)
      end)
    end,
  })

  vim.api.nvim_create_user_command("DotfilesDiff", open_dotfiles_repo_review, {
    desc = "Read-only CodeDiff review for dotfiles changes",
  })
  vim.api.nvim_create_user_command("DotfilesDiffFile", open_dotfiles_file_review, {
    desc = "Read-only CodeDiff review for current dotfiles file",
  })
  vim.api.nvim_create_user_command("DotfilesDiffHistory", open_dotfiles_history_review, {
    desc = "Read-only CodeDiff history for dotfiles",
  })

  map("n", "<leader>gd", open_repo_diff, { desc = "CodeDiff repo changes" })
  map("n", "<leader>gf", open_current_file_diff, { desc = "CodeDiff file vs HEAD" })
  map("n", "<leader>gh", open_repo_history, { desc = "CodeDiff history" })
end

return M
