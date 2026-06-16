return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
        "lua_ls"
				"html", -- html-lsp
				"cssls", -- css-lsp
				"ts_ls", -- typescript-language-server
				"astro", -- astro-language-server
				"pyright",
				"bashls", -- bash-language-server
				"marksman",
				"clangd",
				"tailwindcss",
			},
			automatic_installation = true,
		})
	end,
}
