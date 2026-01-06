
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      local ok, nvdash = pcall(require, "nvchad.nvdash")
      if ok and nvdash.open then
        nvdash.open()
      end
    end
  end,
})
