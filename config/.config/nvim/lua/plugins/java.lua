return{
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			local jdtls = require("jdtls")
			local config = {
				cmd = { "jdtls" },
				root_dir = require("lspconfig.util").root_pattern(".git", "gradlew", "mvnw", "pom.xml"),
				settings = {
					java = {
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" },
						hoverProvider = { enabled = true },
						import = {
							gradle = { enabled = true, wrapper = { enabled = true } },
							eclipse = { enabled = false },
						},
					},
				},
			}
			jdtls.start_or_attach(config)
		end,
	}

