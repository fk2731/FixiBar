-- Check https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#tailwindcss
require("nvchad.configs.lspconfig").defaults()

local servers =
{ "html", "cssls", "ts_ls", "astro", "pyright", "bashls", "marksman", "grammarly-languageserver", "clangd", "biome",
  "tailwindcss" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
