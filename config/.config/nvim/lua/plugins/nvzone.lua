return {
  { "nvzone/volt", lazy = true },
  {
    "nvzone/minty",
    cmd = { "Shades", "Huefy" },
    opts = {
      huefy = { border = true },
      shades = { border = true },
    },
  },
  {
    "nvzone/menu",
    lazy = true,
    keys = {
      {
        "<C-t>",
        function()
          require("menu").open("default", { border = true })
        end,
        mode = "n",
        desc = "Open Menu (nvzone/menu)",
      },

      {
        "<RightMouse>",
        function()
          require("menu.utils").delete_old_menus()
          vim.cmd.exec '"normal! \\<RightMouse>"'
          local buf = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
          local options = vim.bo[buf].ft == "NvimTree" and "nvimtree" or "default"
          require("menu").open(options, { mouse = true, border = true })
        end,
        mode = { "n", "v" },
        desc = "Open Context Menu (nvzone/menu)",
      },
    },
  },
}
