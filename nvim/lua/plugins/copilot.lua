return {
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "VeryLazy",
		config = function()
			require("copilot").setup({})
		end,
	},
}
