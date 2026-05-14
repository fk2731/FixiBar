return {
  -- Formatter
  {
    "stevearc/conform.nvim",
    enabled = false,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config {
        underline = true,
        update_in_insert = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          header = "",
          prefix = "",
        },
        severity_sort = true,
      }
      require "configs.lspconfig"
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "java",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "latex",
        "astro",
        "css",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
