-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  transparency = true, -- elige uno solo

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },

    -- -- Diferenciación explícita de tipos vs variables
    ["@type"] = { fg = "cyan" },
    ["@type.builtin"] = { fg = "cyan", italic = true },
    ["@variable"] = { fg = "sun", italic = true },
    ["@variable.member"] = { fg = "red" },
    ["@variable.builtin"] = { fg = "red", italic = true },
    ["@function"] = { fg = "yellow" },
    ["@function.builtin"] = { fg = "yellow", italic = true },
    ["@keyword"] = { fg = "purple", italic = true },
    ["@string"] = { fg = "green" },
    ["@number"] = { fg = "orange" },
    ["@constant"] = { fg = "baby_pink", bold = true },
    ["@parameter"] = { fg = "yellow" },
    ["@property"] = { fg = "blue", italic = true },

    ["@lsp.type.function"] = { fg = "yellow" },
    ["@lsp.type.variable"] = { fg = "white" },
    ["@lsp.type.parameter"] = { fg = "yellow" },
    ["@lsp.type.class"] = { fg = "blue" },
    ["@lsp.type.interface"] = { fg = "blue", italic = true },
    ["@lsp.type.namespace"] = { fg = "blue" },
    ["@lsp.type.property"] = { fg = "blue" },
    ["@lsp.type.enum"] = { fg = "orange" },
    ["@lsp.type.enumMember"] = { fg = "orange", italic = true },
    ["@lsp.type.decorator"] = { fg = "yellow" },
  },
}

M.ui = {
  telescope = { style = "bordered" },
  statusline = { theme = "minimal", separator_style = "round" },
  nvdash = { load_on_startup = true },
}

return M
