return {
	"folke/sidekick.nvim",
	opts = {
		nes = {
			enabled = false,
		},
		cli = {
			mux = {
				backend = "tmux",
				enabled = true,
			},
		},
	},
	keys = {
		{
			"<c-.>",
			function()
				require("sidekick.cli").toggle({ name = "opencode", focus = true })
			end,
			mode = { "n", "t", "i", "x" },
			desc = "OpenCode Toggle",
		},
		{
			"<leader>aa",
			function()
				require("sidekick.cli").toggle({ name = "opencode", focus = true })
			end,
			desc = "OpenCode Toggle",
		},
		{
			"<leader>ao",
			function()
				require("sidekick.cli").focus({ name = "opencode" })
			end,
			desc = "OpenCode Focus",
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select({ filter = { installed = true } })
			end,
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").send({ msg = "{diagnostics}" })
			end,
			desc = "OpenCode Send Diagnostics",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "OpenCode Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "OpenCode Send File",
		},
		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "OpenCode Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "OpenCode Select Prompt",
		},
	},
}
