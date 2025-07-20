return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
		},
		config = function()
			local config = require("nvim-treesitter.configs")
			config.setup({
				auto_install = true,
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"html",
					"javascript",
					"java",
					"jsdoc",
					"json",
					"jsonc",
					"lua",
					"luadoc",
					"luap",
					"markdown",
					"markdown_inline",
					"printf",
					"python",
					"query",
					"regex",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"vimdoc",
					"xml",
					"yaml",
					"latex",
				},
				highlight = {
					enable = true,
				},
				indent = { enable = true },
			})

			require("treesitter-context").setup({
				enable = true, -- Enable this plugin
				multiwindow = false, -- Enable multiwindow support
				max_lines = 0, -- No limit for window span
				min_window_height = 0, -- No limit for minimum window height
				line_numbers = true,
				multiline_threshold = 20, -- Max number of lines to show for a single context
				trim_scope = "outer", -- Discard outer context lines if max_lines exceeded
				mode = "cursor", -- Line used to calculate context
				separator = nil, -- No separator
				zindex = 20, -- Z-index of context window
				on_attach = nil, -- No custom attach function
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {}, -- Additional configuration if needed
	},
}
