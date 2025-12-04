local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier", "stylelint" },
    html = { "prettier" },
    astro = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    markdown = { "prettier" },
    python = { "black" },
    sh = { "shfmt" },
    java = { "google-java-format" },
    c = { "clang-format" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

-- require("conform").setup(options)
