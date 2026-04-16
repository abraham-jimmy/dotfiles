local M = {}

function M.tooling()
	return {
		lsp = {
			bashls = {
				filetypes = { "bash", "sh" },
				root_markers = { ".git", ".shellcheckrc" },
			},
		},
		linters_by_ft = {
			sh = { "shellcheck" },
		},
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2", "-ci" },
			},
		},
		formatters_by_ft = {
			bash = { "shfmt" },
			sh = { "shfmt" },
		},
	}
end

return M
