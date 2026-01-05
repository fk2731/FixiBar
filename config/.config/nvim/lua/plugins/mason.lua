return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason-lspconfig").setup {
      ensure_installed = {
        "html",
        "cssls",
        "ts_ls",
        "astro",
        "pyright",
        "bashls",
        "marksman",
        "grammarly-languageserver",
        "clangd",
        "biome",
        "tailwindcss",
      },
      automatic_installation = true,
    }
  end,
}
