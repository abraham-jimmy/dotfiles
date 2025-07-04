return
{
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    winopts = {
      preview = {
        hidden = 'hidden'
      },
    },
  },
  keys = {
    { "<leader>b",  "<Cmd>FzfLua buffers<CR>",                  desc = "FzfLua buffers" },
    { "<leader>ff", "<Cmd>FzfLua files<CR>",                    desc = "FzfLua files" },
    { "<leader>fp", "<Cmd>FzfLua files cwd=~/.config/nvim<CR>", desc = "FzfLua files" },
    { "<leader>fg", "<Cmd>FzfLua git_files<CR>",                desc = "FzfLua git files" },
    { "<leader>sg", "<Cmd>FzfLua grep<CR>",                     desc = "FzfLua grep" },
    { "<leader>sf", "<Cmd>FzfLua live_grep<CR>",                desc = "FzfLua live grep (fuzzy)" },
    { "<leader>/",  "<Cmd>FzfLua lgrep_curbuf<CR>",             desc = "FzfLua fuzzy grep current buffer" },
    { "<leader>sw", "<Cmd>FzfLua grep_cWORD<CR>",               desc = "FzfLua current word" },
    { "<leader>sr", "<Cmd>FzfLua resume<CR>",                   desc = "FzfLua resume" },
    { "<leader>sd", "<Cmd>FzfLua diagnostics_document<CR>",     desc = "Diagnostics document" },
    { "<leader>sk", "<Cmd>FzfLua keymaps<CR>",                  desc = "Search keymaps" },
    {
      "<leader>sG",
      function()
        local git_root = function()
          local dot_git_path = vim.fn.finddir(".git", ".;")
          return vim.fn.fnamemodify(dot_git_path, ":h")
        end
        local root = git_root()
        require('fzf-lua').grep({ cwd = root })
      end,
      desc = "FzfLua grep git repo"
    },
    { "<leader>sw", "<Cmd>FzfLua grep_cword<CR>",  mode = { "n" }, desc = "FzfLua current word" },
    { "<leader>sw", "<Cmd>FzfLua grep_visual<CR>", mode = { "x" }, desc = "FzfLua grep visual selection" },

  },
  config = function(_, opts)
    -- calling `setup` is optional for customization
    require("fzf-lua").setup({ 'telescope', opts })
  end
}
