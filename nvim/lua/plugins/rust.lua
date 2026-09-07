return {
  "mrcjkb/rustaceanvim",
  version = "^6",
  lazy = false, -- rustaceanvim sets up its own FileType autocmd; must be loaded upfront
  ft = { "rust" },
  config = function()
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy", -- run `cargo clippy` instead of `cargo check` for diagnostics
            },
            cargo = {
              allFeatures = true,
            },
          },
        },
      },
    }
  end,
}
