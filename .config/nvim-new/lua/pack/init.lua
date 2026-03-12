local M = {}

function M.setup()
	if vim.fn.has("nvim-0.12") == 0 then
		vim.schedule(function()
			vim.notify("nvim-new expects Neovim 0.12 or newer", vim.log.levels.WARN, { title = "nvim-new" })
		end)
		return
	end

	if not vim.pack then
		vim.schedule(function()
			vim.notify("vim.pack is unavailable in this Neovim build", vim.log.levels.WARN, { title = "nvim-new" })
		end)
		return
	end

	vim.pack.add({
		{ src = "https://github.com/ibhagwan/fzf-lua.git" },
		{ src = "https://github.com/kevinhwang91/nvim-hlslens.git" },
		{ src = "https://github.com/esmuellert/codediff.nvim.git" },
		{ src = "https://github.com/lewis6991/gitsigns.nvim.git" },
		{ src = "https://github.com/mfussenegger/nvim-dap.git" },
		{ src = "https://github.com/theHamsta/nvim-dap-virtual-text.git" },
		{ src = "https://github.com/igorlfs/nvim-dap-view.git" },
		{ src = "https://github.com/neovim/nvim-lspconfig.git" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git" },
		{ src = "https://github.com/mfussenegger/nvim-lint.git" },
		{ src = "https://github.com/stevearc/conform.nvim.git" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter.git" },
		{ src = "https://github.com/Saghen/blink.cmp.git", version = "v1.9.1" },
		{ src = "https://github.com/nathom/tmux.nvim.git" },
		{ src = "https://github.com/folke/sidekick.nvim.git", version = "v2.1.0" },
		{ src = "https://github.com/folke/lazydev.nvim.git" },
		{ src = "https://github.com/nvim-mini/mini.ai.git" },
		{ src = "https://github.com/nvim-mini/mini.clue.git" },
		{ src = "https://github.com/nvim-mini/mini.files.git" },
		{ src = "https://github.com/nvim-mini/mini.indentscope.git" },
		{ src = "https://github.com/nvim-mini/mini.move.git" },
		{ src = "https://github.com/nvim-mini/mini.pairs.git" },
		{ src = "https://github.com/nvim-mini/mini.surround.git" },
		{ src = "https://github.com/nvim-mini/mini.trailspace.git" },
		{ src = "https://github.com/nvim-mini/mini.statusline.git" },
		{ src = "https://github.com/rebelot/kanagawa.nvim.git" },
		{ src = "https://github.com/catppuccin/nvim.git", name = "catppuccin" },
		{ src = "https://github.com/rcarriga/nvim-notify.git" },
		{ src = "https://github.com/MaximilianLloyd/ascii.nvim.git" },
		{ src = "https://github.com/nvim-tree/nvim-tree.lua.git", version = "v1" },
		{ src = "https://github.com/nvim-tree/nvim-web-devicons.git" },
		{ src = "https://github.com/nvimdev/dashboard-nvim.git" },
		{ src = "https://github.com/folke/flash.nvim.git" },
		{ src = "https://github.com/folke/todo-comments.nvim.git" },
		{ src = "https://github.com/folke/zen-mode.nvim.git" },
		{ src = "https://github.com/norcalli/nvim-colorizer.lua.git" },
	}, { confirm = false, load = true })

	require("plugins.search").setup()
	require("plugins.git").setup()
	require("plugins.explorer").setup()
	require("plugins.editor").setup()
	require("plugins.dap").setup()
	require("plugins.lsp").setup()
	require("plugins.linting").setup()
	require("plugins.formatting").setup()
	require("plugins.treesitter").setup()
	require("plugins.completion").setup()
	require("plugins.motion").setup()
	require("plugins.workflow").setup()
	require("plugins.ui").setup()
end

return M
