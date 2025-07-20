return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mollerhoj/telescope-recent-files.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          multi_icon = " ",
          initial_mode = "normal",
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      -- Cargar extensiones
      telescope.load_extension("fzf")
      telescope.load_extension("recent-files")
      telescope.load_extension("ui-select")

      -- Keymaps
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>h", builtin.help_tags, {})

      -- LSP options
      vim.keymap.set("n", "<leader>gr", builtin.lsp_references, {})
      vim.keymap.set("n", "<leader>gs", builtin.lsp_document_symbols, {})
      vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, {})

      vim.keymap.set("n", "<C-Space>", function()
        require("telescope").extensions["recent-files"].recent_files({})
      end, { noremap = true, silent = true })

      vim.keymap.set("n", "<leader>fa", function()
        builtin.find_files({
          hidden = true,
        })
      end, { noremap = true, silent = true })
    end,
  },
}

