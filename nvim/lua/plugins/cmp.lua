return {
  "hrsh7th/nvim-cmp",
  event = "VeryLazy",
  dependencies = {
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "zbirenbaum/copilot-cmp",
  },

  config = function(_, opts)
    local cmp = require "cmp"

    -- Copilot CMP
    local ok, copilot_cmp = pcall(require, "copilot_cmp")
    if ok then
      copilot_cmp.setup()
    end

    -- Ghost text
    opts = opts or {}
    opts.experimental = opts.experimental or {}
    opts.experimental.ghost_text = { hl_group = "CmpGhostText" }

    -- Sorting
    opts.sorting = {
      priority_weight = 2,
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    }

    -- Sources
    opts.sources = opts.sources or {}
    local has_copilot = false
    for _, source in ipairs(opts.sources) do
      if source.name == "copilot" then
        has_copilot = true
      end
      source.priority = source.priority or 80
    end
    if not has_copilot then
      table.insert(opts.sources, 1, { name = "copilot", priority = 90 })
    end

    -- Mappings
    opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
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

      ["<D-Space>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.close()
        else
          cmp.complete()
        end
      end, { "i" }),

      ["<CR>"] = cmp.mapping.confirm { select = true },
      ["<C-e>"] = cmp.mapping.abort(),
    })

    cmp.setup(opts)

    -- Autocomplete in / ?
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer", priority = 80 } },
    })

    -- Autocomplete in commands
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path", priority = 80 } }, { { name = "cmdline", priority = 80 } }),
    })
  end,
}
