vim.cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])
vim.cmd([[autocmd FileType spec setlocal commentstring=#\ %s]])

local function augroup(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
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

	vim.fn.system({ "tmux", "set-option", "-p", "-t", vim.env.TMUX_PANE, "-q", "@nvim_file_dir", dir })
	if vim.v.shell_error ~= 0 then
		return
	end
end

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"gitsigns-blame",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.opt.cmdheight = 1
	end,
})
vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		vim.opt.cmdheight = 0
	end,
})

-- Always update files when entering file, combined with autoread = true it will update
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	command = "checktime",
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "DirChanged", "WinEnter" }, {
	group = augroup("tmux_file_dir"),
	callback = sync_tmux_file_dir,
})
