local M = {}

function M.setup()
	local indentscope_ok, indentscope = pcall(require, "mini.indentscope")
	if not indentscope_ok then
		vim.schedule(function()
			vim.notify("mini.indentscope is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
	else
		indentscope.setup({
			symbol = "│",
			options = { try_as_border = true },
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("nvim_new_indentscope_disable", { clear = true }),
			pattern = {
				"dashboard",
				"help",
				"lazy",
				"lazyterm",
				"mason",
				"minifiles",
				"NvimTree",
				"notify",
				"qf",
				"toggleterm",
			},
			callback = function()
				vim.b.miniindentscope_disable = true
			end,
		})
	end

	local move_ok, move = pcall(require, "mini.move")
	if not move_ok then
		vim.schedule(function()
			vim.notify("mini.move is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
	else
		move.setup({})
	end

	local trailspace_ok, trailspace = pcall(require, "mini.trailspace")
	if not trailspace_ok then
		vim.schedule(function()
			vim.notify("mini.trailspace is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
	else
		trailspace.setup({})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("nvim_new_trailspace_disable", { clear = true }),
			pattern = {
				"dashboard",
			},
			callback = function()
				vim.b.minitrailspace_disable = true
			end,
		})
	end

	local ai_ok, ai = pcall(require, "mini.ai")
	if not ai_ok then
		vim.schedule(function()
			vim.notify("mini.ai is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
	else
		local spec_treesitter = ai.gen_spec.treesitter

		ai.setup({
			custom_textobjects = {
				f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
				c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
				i = spec_treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
			},
		})
	end

	local surround_ok, surround = pcall(require, "mini.surround")
	if not surround_ok then
		vim.schedule(function()
			vim.notify("mini.surround is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
	else
		surround.setup({
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		})
	end

	local pairs_ok, pairs = pcall(require, "mini.pairs")
	if not pairs_ok then
		vim.schedule(function()
			vim.notify("mini.pairs is unavailable", vim.log.levels.WARN, { title = "nvim-new" })
		end)
		return
	end

	pairs.setup({})
end

return M
