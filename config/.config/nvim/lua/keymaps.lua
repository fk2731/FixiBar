local opts = { noremap = true, silent = true }

-- Save file and quit
vim.keymap.set({ "n", "i" }, "<C-s>", "<Esc>:w<Return>", opts)
vim.keymap.set("n", "<leader>w", "<Esc>:w<Return>", opts)
vim.keymap.set("n", "<Leader>q", "<Esc>:q<Return>", opts)

vim.keymap.set("n", "J", ":m .+1<CR>==", { desc = "Move current line down" })
vim.keymap.set("n", "K", ":m .-2<CR>==", { desc = "Move current line up" })

vim.keymap.set("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move current line down" })
vim.keymap.set("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move current line up" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<", "<<", { desc = "Indent line left" })
vim.keymap.set("n", ">", ">>", { desc = "Indent line right" })

-- Add lines
vim.keymap.set("n", "<leader>O", "O<Esc>")
vim.keymap.set("n", "<leader>o", "o<Esc>")

-- Copies or Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]], opts)
vim.keymap.set("v", "<leader>y", [["+y]], opts)

-- leader d delete wont remember as yanked/clipboard when delete pasting
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- ctrl c as escape cuz Im lazy to reach up to the esc key
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- format without prettier using the built in
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- prevent x delete from registering when next paste
vim.keymap.set("n", "x", '"_x', opts)

-- Executes shell command from in here making file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "makes file executable" })

-- Tabs
vim.keymap.set("n", "te", ":tabedit")
vim.keymap.set("n", "<tab>", ":tabnext<Return>", opts)
vim.keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
vim.keymap.set("n", "tw", ":tabclose<Return>", opts)

-- Split window
vim.keymap.set("n", "ss", ":split<Return>", opts)
vim.keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

-- Resize window
vim.keymap.set("n", "<C-h>", "<C-w><")
vim.keymap.set("n", "<c-l>", "<c-w>>")
vim.keymap.set("n", "<c-k>", "<c-w>+")
vim.keymap.set("n", "<c-j>", "<c-w>-")

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
	local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
	vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
	print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy file path to clipboard" })
