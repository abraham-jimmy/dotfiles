local M = {}

local state = {
  augroup = nil,
  buf_id = nil,
  kind = nil,
  manual = {},
  tabpage = nil,
  win_id = nil,
}

local panels = {
  minifiles = {
    title = "mini.files",
    lines = {
      { "l", "open or enter" },
      { "L", "open and close on file" },
      { "h", "go out" },
      { "H", "go out and close" },
      { "=", "apply changes" },
      { "q", "close" },
      { "m<char>", "set bookmark" },
      { "'<char>", "jump bookmark" },
      { "<BS>", "reset view" },
      { "@", "reveal cwd" },
      { "<", "trim left" },
      { ">", "trim right" },
      { "g?", "help" },
    },
  },
  NvimTree = {
    title = "nvim-tree",
    lines = {
      { "<C-]>", "cd to node" },
      { "<C-e>", "open in place" },
      { "<C-k>", "info popup" },
      { "<C-r>", "rename omit filename" },
      { "<C-t>", "open in new tab" },
      { "<C-v>", "open vertical split" },
      { "<C-x>", "open horizontal split" },
      { "<BS>", "close directory" },
      { "<CR>", "open" },
      { "<Tab>", "open preview" },
      { ">", "next sibling" },
      { "<", "previous sibling" },
      { ".", "run command" },
      { "-", "go to parent root" },
      { "a", "add" },
      { "bd", "delete bookmarked" },
      { "bt", "trash bookmarked" },
      { "bmv", "move bookmarked" },
      { "B", "toggle no-buffer filter" },
      { "d", "delete" },
      { "D", "trash" },
      { "r", "rename" },
      { "e", "rename basename" },
      { "u", "rename full path" },
      { "c", "copy" },
      { "C", "toggle git-clean filter" },
      { "x", "cut" },
      { "p", "paste" },
      { "[c", "prev git change" },
      { "]c", "next git change" },
      { "[e", "prev diagnostic" },
      { "]e", "next diagnostic" },
      { "E", "expand all" },
      { "f", "live filter" },
      { "F", "clear live filter" },
      { "ge", "copy basename" },
      { "gy", "copy absolute path" },
      { "H", "toggle hidden" },
      { "I", "toggle gitignore filter" },
      { "J", "last sibling" },
      { "K", "first sibling" },
      { "L", "toggle group empty" },
      { "M", "toggle no-bookmark filter" },
      { "m", "toggle bookmark" },
      { "o", "open" },
      { "O", "open without picker" },
      { "P", "focus parent directory" },
      { "q", "close tree" },
      { "R", "refresh" },
      { "s", "run system" },
      { "S", "search node" },
      { "U", "toggle custom filter" },
      { "W", "collapse all" },
      { "y", "copy name" },
      { "Y", "copy relative path" },
      { "?", "help" },
    },
  },
}

local function codediff_panel(tabpage)
  local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
  if not ok then
    return nil, nil
  end

  local mode = lifecycle.get_mode(tabpage)
  local lines = {
    { "q", "close codediff tab" },
    { "t", "toggle inline / side-by-side" },
    { "]c / [c", "next / previous hunk" },
    { "]f / [f", "next / previous file" },
    { "do / dp", "diff get / put" },
    { "-", "stage / unstage current file" },
    { "<leader>hs", "stage hunk" },
    { "<leader>hu", "unstage hunk" },
    { "<leader>hr", "discard hunk" },
    { "gf", "open file in previous tab" },
    { "g?", "built-in codediff help" },
    { "<leader>?", "toggle this clue panel" },
  }

  if mode == "explorer" then
    vim.list_extend(lines, {
      { "<CR>", "open selected file diff" },
      { "K", "preview selected file" },
      { "R", "refresh repo status" },
      { "i", "toggle list / tree view" },
      { "gu / gs", "toggle unstaged / staged groups" },
      { "S / U / X", "stage all / unstage all / restore" },
      { "zo / zc / za", "open / close / toggle fold" },
      { "zR / zM", "open all / close all folds" },
      { "<leader>b", "toggle explorer pane" },
      { "<leader>e", "focus explorer pane" },
    })

    return {
      title = "codediff explorer",
      lines = lines,
    }, "codediff"
  end

  if mode == "history" then
    vim.list_extend(lines, {
      { "<CR>", "open selected commit / file" },
      { "R", "refresh history" },
      { "i", "toggle list / tree view" },
      { "zo / zc / za", "open / close / toggle fold" },
      { "zR / zM", "open all / close all folds" },
    })

    return {
      title = "codediff history",
      lines = lines,
    }, "codediff"
  end

  return {
    title = "codediff view",
    lines = lines,
  }, "codediff"
end

local function is_valid_buf(buf_id)
  return type(buf_id) == "number" and vim.api.nvim_buf_is_valid(buf_id)
end

local function is_valid_win(win_id)
  return type(win_id) == "number" and vim.api.nvim_win_is_valid(win_id)
end

local function current_panel()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local manual_kind = state.manual[tabpage]
  if manual_kind == "codediff" then
    return codediff_panel(tabpage)
  elseif manual_kind and panels[manual_kind] then
    return panels[manual_kind], manual_kind
  end

  local ft = vim.bo.filetype
  return panels[ft], ft
end

local function close_window()
  if is_valid_win(state.win_id) then
    pcall(vim.api.nvim_win_close, state.win_id, true)
  end

  state.win_id = nil
  state.tabpage = nil
  state.kind = nil
end

local function ensure_buffer()
  if is_valid_buf(state.buf_id) then
    return state.buf_id
  end

  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.bo[buf_id].bufhidden = "wipe"
  vim.bo[buf_id].buftype = "nofile"
  vim.bo[buf_id].filetype = "miniclue-panel"
  vim.bo[buf_id].modifiable = false
  vim.bo[buf_id].swapfile = false
  vim.api.nvim_buf_set_name(buf_id, "nvim-new://clue-panel")
  state.buf_id = buf_id
  return buf_id
end

local function buffer_width(lines)
  local width = 0

  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end

  return width
end

local function available_height()
  local has_statusline = vim.o.laststatus > 0
  local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  return math.max(vim.o.lines - vim.o.cmdheight - (has_statusline and 1 or 0) - (has_tabline and 1 or 0) - 4, 1)
end

local function render_buffer(panel, kind)
  local buf_id = ensure_buffer()
  local text = {}
  local highlights = {}
  local key_width = 0
  local item_width = 0

  for _, item in ipairs(panel.lines) do
    key_width = math.max(key_width, vim.fn.strdisplaywidth(item[1]))
    item_width = math.max(item_width, vim.fn.strdisplaywidth(item[1] .. " " .. item[2]))
  end

  local max_rows = available_height()
  local row_count = math.min(#panel.lines, max_rows)
  local col_count = math.max(math.ceil(#panel.lines / row_count), 1)
  local col_gap = 3

  for _ = 1, row_count do
    text[#text + 1] = ""
  end

  for i, item in ipairs(panel.lines) do
    local row = ((i - 1) % row_count) + 1
    local col = math.floor((i - 1) / row_count)
    local col_start = col * (item_width + col_gap)
    local segment = string.format("%-" .. key_width .. "s %s", item[1], item[2])
    local pad = col_start - vim.fn.strdisplaywidth(text[row])

    if pad > 0 then
      text[row] = text[row] .. string.rep(" ", pad)
    end

    text[row] = text[row] .. segment
    highlights[#highlights + 1] = {
      row = row - 1,
      key_start = col_start,
      key_end = col_start + vim.fn.strdisplaywidth(item[1]),
      desc_start = col_start + key_width + 1,
      desc_end = col_start + vim.fn.strdisplaywidth(segment),
    }
  end

  vim.bo[buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, text)
  vim.api.nvim_buf_clear_namespace(buf_id, -1, 0, -1)

  for _, item in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf_id, -1, "MiniClueNextKey", item.row, item.key_start, item.key_end)
    vim.api.nvim_buf_add_highlight(buf_id, -1, "MiniClueDescSingle", item.row, item.desc_start, item.desc_end)
  end

  vim.bo[buf_id].modifiable = false
  state.kind = kind
  return buf_id, buffer_width(text), #text
end

local function window_config(width, height, title)
  local has_statusline = vim.o.laststatus > 0

  return {
    anchor = "SE",
    border = (vim.fn.exists("+winborder") == 0 or vim.o.winborder == "") and "single" or nil,
    col = vim.o.columns,
    focusable = false,
    height = height,
    noautocmd = true,
    relative = "editor",
    row = vim.o.lines - vim.o.cmdheight - (has_statusline and 1 or 0),
    style = "minimal",
    title = " " .. title .. " ",
    width = math.min(width + 3, math.max(vim.o.columns - 4, 20)),
    zindex = 240,
  }
end

function M.close()
  close_window()
end

function M.toggle_codediff(tabpage)
  tabpage = tabpage or vim.api.nvim_get_current_tabpage()

  if state.manual[tabpage] == "codediff" then
    state.manual[tabpage] = nil
    if state.tabpage == tabpage then
      close_window()
    end
    return
  end

  state.manual[tabpage] = "codediff"

  if tabpage == vim.api.nvim_get_current_tabpage() then
    M.refresh()
  end
end

function M.refresh()
  if vim.bo.filetype == "miniclue-panel" then
    return
  end

  local panel, kind = current_panel()
  if not panel then
    close_window()
    return
  end

  local tabpage = vim.api.nvim_get_current_tabpage()
  local buf_id, width, height = render_buffer(panel, kind)
  local config = window_config(width, height, panel.title)

  if not is_valid_win(state.win_id) or state.tabpage ~= tabpage then
    close_window()
    state.win_id = vim.api.nvim_open_win(buf_id, false, config)
    state.tabpage = tabpage
  else
    vim.api.nvim_win_set_buf(state.win_id, buf_id)
    vim.api.nvim_win_set_config(state.win_id, config)
  end

  vim.wo[state.win_id].foldenable = false
  vim.wo[state.win_id].number = false
  vim.wo[state.win_id].relativenumber = false
  vim.wo[state.win_id].signcolumn = "no"
  vim.wo[state.win_id].wrap = false
  vim.wo[state.win_id].winhighlight = "FloatBorder:MiniClueBorder,FloatTitle:MiniClueTitle"
end

function M.setup()
  if state.augroup then
    return
  end

  state.augroup = vim.api.nvim_create_augroup("nvim_new_clue_panel", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "VimResized" }, {
    group = state.augroup,
    callback = function()
      vim.schedule(M.refresh)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = state.augroup,
    pattern = { "minifiles", "NvimTree" },
    callback = function()
      vim.schedule(M.refresh)
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    group = state.augroup,
    pattern = "CodeDiffClose",
    callback = function(event)
      local data = event.data or {}
      local tabpage = data.tabpage
      if tabpage then
        state.manual[tabpage] = nil
        if state.tabpage == tabpage then
          close_window()
        end
      end
    end,
  })
end

return M
