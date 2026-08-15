-- ### FIXI MAPPINGS ###

local opts = { noremap = true, silent = true }

-- Make 'c' (change) not copy
map("n", "c", '"_c', opts)
map("n", "<S-c>", '"_C', opts)

-- Save file and quit
map({ "n", "i" }, "<C-s>", "<Esc>:w<Return>", opts)
map("n", "<leader>w", "<Esc>:w<Return>", opts)
map("n", "<Leader>q", "<Esc>:q<Return>", opts)

map("n", "J", ":m .+1<CR>==", { desc = "Move current line down" })
map("n", "K", ":m .-2<CR>==", { desc = "Move current line up" })

map("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move current line down" })
map("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move current line up" })

map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

map("n", "<", "<<", { desc = "Indent line left" })
map("n", ">", ">>", { desc = "Indent line right" })

-- Add lines
map("n", "<leader>O", "O<Esc>")
map("n", "<leader>o", "o<Esc>")

-- ctrl c as escape cuz Im lazy to reach up to the esc key
map("i", "<C-c>", "<Esc>")
map("n", "<C-c>", ":nohl<CR>", { desc = "Clear search hl", silent = true })

-- Select all
map("n", "<C-a>", "gg<S-v>G")

-- prevent x delete from registering when next paste
map("n", "x", '"_x', opts)

-- Executes shell command from in here making file executable
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "makes file executable" })

-- Split window
map("n", "ss", "<cmd>split<Return>", opts)
map("n", "sv", "<cmd>vsplit<Return>", opts)

-- Move window
map("n", "sh", "<C-w>h")
map("n", "sk", "<C-w>k")
map("n", "sj", "<C-w>j")
map("n", "sl", "<C-w>l")

-- Resize window
map("n", "<C-h>", "<C-w><")
map("n", "<c-l>", "<c-w>>")
map("n", "<c-k>", "<c-w>+")
map("n", "<c-j>", "<c-w>-")

-- Show recent files
map("n", "<C-Space>", "<cmd>Telescope oldfiles<CR>", { desc = "Show recent files", silent = true })

-- Lsp Config
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf, silent = true }

    -- set keybinds
    opts.desc = "Show LSP references"
    map("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

    opts.desc = "Show LSP definition"
    map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definition

    opts.desc = "Show LSP implementations"
    map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

    opts.desc = "Show LSP type definitions"
    map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

    opts.desc = "Show LSP document symbols"
    map("n", "gs", "<cmd>Telescope lsp_document_symbols<CR>", opts)

    opts.desc = "Show LSP workspace symbols"
    map("n", "gw", "<cmd>Telescope lsp_workspace_symbols<CR>", opts)

    opts.desc = "See available code actions"
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

    map({ "n" }, "<leader>f", function()
      vim.lsp.buf.format({
        filter = function(client)
          if vim.bo.filetype == "java" then
            return client.name == "jdtls"
          end
          return true
        end,
      })
    end, opts)

    opts.desc = "Smart rename"
    map("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    opts.desc = "Show buffer diagnostics"
    map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

    opts.desc = "Show line diagnostics"
    map("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

    opts.desc = "Go to previous diagnostic"
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts) -- jump to previous diagnostic in buffer
    --
    opts.desc = "Go to next diagnostic"
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts) -- jump to next diagnostic in buffer

    opts.desc = "Show documentation for what is under cursor"
    map("n", "H", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

    opts.desc = "Restart LSP"
    map("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
  end,
})

map("n", "<leader>th", function()
  require("nvchad.themes").open({
    border = true,
  })
end, { desc = "Theme Picker" })

vim.keymap.set("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:.")               -- Gets the file path relative to the home directory
  vim.fn.setreg("+", filePath)                        -- Copy the file path to the clipboard register
  print("File path copied to clipboard: " .. filePath) -- Optional: print message to confirm
end, { desc = "Copy file path to clipboard" })
