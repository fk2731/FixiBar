return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    local jdtls = require("jdtls")

    local function setup()
      local home = os.getenv("HOME")
      local root = vim.fs.root(0, { "pom.xml", "mvnw", "gradlew", ".git" })
      if not root then
        return
      end
      local project_name = vim.fn.fnamemodify(root, ":t")
      local workspace = home .. "/.local/share/eclipse/" .. project_name
      local lombok = "/usr/share/java/lombok/lombok.jar"

      local config = {
        cmd = {
          "jdtls",
          "--jvm-arg=-javaagent:" .. lombok,
          "-data",
          workspace,
        },

        root_dir = root,
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

        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr, silent = true }

          vim.keymap.set(
            "n",
            "<leader>jo",
            jdtls.organize_imports,
            vim.tbl_extend("force", opts, { desc = "Organize imports" })
          )
          vim.keymap.set(
            "n",
            "<leader>jv",
            jdtls.extract_variable,
            vim.tbl_extend("force", opts, { desc = "Extract variable" })
          )
          vim.keymap.set("v", "<leader>jv", function()
            jdtls.extract_variable(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
          vim.keymap.set(
            "n",
            "<leader>jc",
            jdtls.extract_constant,
            vim.tbl_extend("force", opts, { desc = "Extract constant" })
          )
          vim.keymap.set("v", "<leader>jc", function()
            jdtls.extract_constant(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
          vim.keymap.set("v", "<leader>jm", function()
            jdtls.extract_method(true)
          end, vim.tbl_extend("force", opts, { desc = "Extract method" }))
        end,
      }

      jdtls.start_or_attach(config)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = setup,
    })

    setup()
  end,
}
