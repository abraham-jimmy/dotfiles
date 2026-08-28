vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter.git" } }, { confirm = false, load = true })

local M = {}

function M.setup()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then
    vim.schedule(function()
      vim.notify("nvim-treesitter is unavailable", vim.log.levels.WARN, { title = "nvim" })
    end)
    return
  end

  local parsers = {
    "bash",
    "c",
    "cpp",
    "c_sharp",
    "css",
    "diff",
    "hyprlang",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "nix",
    "query",
    "tmux",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
    "zsh",
  }
  local parser_set = vim.iter(parsers):fold({}, function(result, parser)
    result[parser] = true
    return result
  end)

  local function start(bufnr)
    local filetype = vim.bo[bufnr].filetype
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    if not parser_set[language] or not pcall(vim.treesitter.start, bufnr, language) then
      return
    end

    if language ~= "yaml" then
      vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end

  treesitter.setup({})

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("nvim_treesitter_start", { clear = true }),
    callback = function(args)
      start(args.buf)
    end,
  })

  treesitter.install(parsers):await(function(err)
    if err then
      vim.notify("Unable to install Treesitter parsers: " .. err, vim.log.levels.WARN, { title = "nvim" })
      return
    end

    vim.schedule(function()
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          start(bufnr)
        end
      end
    end)
  end)
end

return M
