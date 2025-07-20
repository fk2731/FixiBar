return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,      -- lua formatting
        null_ls.builtins.formatting.prettier,    -- javascript formatting
        require("none-ls.diagnostics.eslint_d"), -- javascript diagnostics
        null_ls.builtins.formatting.black,       -- python formatting
        null_ls.builtins.formatting.isort,       -- python import sorting
        null_ls.builtins.formatting.shfmt,       -- shell formatting
        null_ls.builtins.formatting.clang_format,      -- c formatting
        -- null_ls.builtins.formatting.latexindent, -- LaTeX formatting
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          -- Crear autocmd para formatear antes de guardar
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
