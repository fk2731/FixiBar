return {
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {},
      })
    end,
  },

  -- 2.2: mason-null-ls (El puente mágico)
  "jay-babu/mason-null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  },
  config = function()
    require("mason-null-ls").setup({
      handlers = {},
      ensure_installed = {
        "prettier",
        "eslint_d",
        "clang_format",
        "google_java_format",
        "checkstyle",
        "stylelint",
        "shfmt",
        "shellcheck",
        "jsonlint",
        "markdownlint",
        "tailwindcss"
      }
    })
  end,
}
