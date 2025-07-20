vim.g.mapleader = " "

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.winbar = "%=%m %f"
vim.o.undofile = true

vim.o.undodir = vim.fn.stdpath("data") .. "/undo"

local undodir = vim.fn.stdpath("data") .. "/undo"
if not vim.fn.isdirectory(undodir) then
	vim.fn.mkdir(undodir, "p")
end
