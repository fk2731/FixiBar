return {
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        initial_mode = "normal",
        border = true,
      })
      return opts
    end,
  },
}

