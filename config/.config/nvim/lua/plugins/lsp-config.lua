return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup({})
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      { "williamboman/mason.nvim" },
    },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSPs
          "pyright",
          "bash-language-server",
          "lua-language-server",
          "clangd",
          "typescript-language-server",
          "css-lsp",
          "marksman",

          -- Formatters / Linters
          "prettier",
          "shfmt",
          "clang-format",
          "stylua",
          "isort",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
    config = function()
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")

      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              typeCheckingMode = "basic",
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      lspconfig.clangd.setup({
        capabilities = capabilities,
      })
      lspconfig.bashls.setup({
        capabilities = capabilities,
      })
      lspconfig.marksman.setup({
        align = true,
        auto_format = true,
      })
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.solargraph.setup({
        capabilities = capabilities,
      })
      lspconfig.html.setup({
        capabilities = capabilities,
      })
      lspconfig.cssls.setup({
        capabilities = capabilities,
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
            doc = {
              privateName = { "^_" },
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      })

      -- Mapas de teclas
      vim.keymap.set("n", "H", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>rn", function()
        vim.lsp.buf.rename()
      end, {})
      vim.keymap.set(
        "n",
        "<leader>gi",
        require("telescope.builtin").lsp_implementations,
        { desc = "[C]ode Goto [I]mplementations" }
      )
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local jdtls_bin = vim.fn.expand("~/.local/share/jdtls/bin/jdtls")

      -- Obtener el nombre del proyecto dinámicamente
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = "/tmp/jdtls/workspace/" .. project_name
      vim.fn.mkdir(workspace_dir, "p") -- Crear el directorio de trabajo si no existe

      local config = {
        cmd = {
          jdtls_bin,
          "-data",
          workspace_dir,
        },
        root_dir = require("jdtls.setup").find_root({ ".git", "pom.xml", "build.gradle", "build.xml" }),
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            hoverProvider = { enable = true },
            import = {
              gradle = {
                enabled = true,
                wrapper = {
                  enabled = true,
                },
              },
            },
          },
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          require("jdtls").start_or_attach(config)
        end,
      })
    end,
  },
}
