return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    local jdtls = require "jdtls"
    local home = os.getenv "HOME"
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace = home .. "/.local/share/eclipse/" .. project_name
    local lombok = "/usr/share/java/lombok.jar"

    local config = {
      cmd = {
        "jdtls",
        "--jvm-arg=-javaagent:" .. lombok,
        "-data",
        workspace,
      },

      root_dir = vim.fs.root(0, { ".git", "gradlew", "mvnw", "pom.xml" }),
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

      on_attach = function(client, bufnr) end,
    }

    jdtls.start_or_attach(config)
  end,
}
