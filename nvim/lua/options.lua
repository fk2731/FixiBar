
-- ### FIXI OPTIONS ###

vim.o.cursorlineopt ='both' -- to enable cursorline!
vim.o.undofile = true

vim.opt.relativenumber = true

vim.o.undodir = vim.fn.stdpath("data") .. "/undo"

vim.opt.winbar = "%=%m %f"

local undodir = vim.fn.stdpath("data") .. "/undo"
if not vim.fn.isdirectory(undodir) then
	vim.fn.mkdir(undodir, "p")
end

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment" })
