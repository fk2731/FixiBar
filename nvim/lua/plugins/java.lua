return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
	config = function()
		local jdtls = require("jdtls")
		local home = os.getenv("HOME")
		local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
		local workspace = home .. "/.local/share/eclipse/" .. project_name

		local os_config = "linux"
		if vim.fn.has("mac") == 1 then
			os_config = "mac"
		end

		local config = {
			cmd = { "jdtls", "-data", workspace },

			root_dir = require("lspconfig.util").root_pattern(".git", "gradlew", "mvnw", "pom.xml"),

			capabilities = require("cmp_nvim_lsp").default_capabilities(),

			settings = {
				java = {
					signatureHelp = { enabled = true },
					contentProvider = { preferred = "fernflower" },
					hoverProvider = { enabled = true },
					import = {
						gradle = { enabled = true, wrapper = { enabled = true } },
						eclipse = { enabled = false },
					},
					referencesCodeLens = { enabled = true },
					references = { includeDecompiledSources = true },
					inlayHints = {
						parameterNames = { enabled = "all" },
					},
					format = { enabled = true },
				},
			},

			on_attach = function(_, bufnr)
				require("jdtls.setup").add_commands()
				local opts = { buffer = bufnr }
			end,
		}

		jdtls.start_or_attach(config)
	end,
}
