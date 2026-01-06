return {
  "hrsh7th/nvim-cmp",
  event = "VeryLazy",
  dependencies = {
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "zbirenbaum/copilot-cmp",
  },

  config = function(_, opts)
    local cmp = require("cmp")

    local ok, copilot_cmp = pcall(require, "copilot_cmp")
    if ok then
      copilot_cmp.setup()
    end

    local defaults = {
      sorting = {
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
      },
      sources = {},
    }
    opts = vim.tbl_deep_extend("keep", opts or {}, defaults)


    local has_copilot = false
    local default_priority = 80
    local copilot_priority = 90

    for _, source in ipairs(opts.sources) do
      if source.name == "copilot" then
        has_copilot = true
      end
      source.priority = source.priority or (source.name == "copilot" and copilot_priority or default_priority)
    end

    if not has_copilot then
      table.insert(opts.sources, 1, { name = "copilot", priority = copilot_priority })
    end

    cmp.setup(opts)

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer", priority = 80 },
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path", priority = 80 },
      }, {
        { name = "cmdline", priority = 80 },
      }),
    })
  end,
}
