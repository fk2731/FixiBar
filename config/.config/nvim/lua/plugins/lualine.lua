return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin",
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" } } },
        lualine_b = { "windows", "searchcount", "branch", "diff", "diagnostics", "selectioncount" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { "encoding", "filetype", "fileformat", "filesize", "progress" },
        lualine_z = {
          { "location", separator = { right = "" } },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "filetype", "filename" },
      },
      tabline = {},
      extensions = {},
    })
  end,
}
