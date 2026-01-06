return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      require("null-ls").setup {}
    end,
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup {
        ensure_installed = {
          "prettier",
          "eslint_d",
          "clang-format",
          "google-java-format",
          "checkstyle",
          "stylelint",
          "shfmt",
          "shellcheck",
          "jsonlint",
          "markdownlint",
        },
        automatic_installation = true,
        handlers = {},
      }
    end,
  },
}
