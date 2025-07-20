return {
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },
  {
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").init({})
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
      vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#f9e2af" })

      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      luasnip.filetype_extend("java", { "javadoc" })

      cmp.setup({
        --Snippet support
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        experimental = {
          ghost_text = true,
        },
        --How completion should be displayed
        -- completion = {
        --   competeopt = "menu,menuone,preview,noselect",
        -- },
        --How looks the menu
        window = {
          completion = cmp.config.window.bordered(),
        },
        --Keymaps
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i" }),
          ["<D-Space>"] = function(fallback)
            if cmp.visible() then
              cmp.close()
            else
              cmp.complete()
            end
          end,
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        -- Where and how should cmp rank and find completions
        -- Order matters, cmp will provide lsp suggestions above all else
        sources = cmp.config.sources({
          { name = "copilot",         group_index = 2 },
          { name = "nvim_lsp",        group_index = 2 },
          { name = "luasnip",         group_index = 2 },
          { name = "buffer",          group_index = 2 },
          { name = "path",            group_index = 2 },
          { name = "render-markdown", group_index = 2 },
        }),
        --Format menu displayed
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            max_width = 50,
            symbol_map = { Copilot = "" },
          }),
        },
      })

      --For completion when you press "/ or ?"
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      --For completion when you press ":"
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })
    end,
  },
}
