-- Neovim Python IDE Configuration
-- Advanced setup for Python development with Claude Code integration

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Python-specific settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.colorcolumn = "88"

-- Search settings
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Terminal colors
vim.opt.termguicolors = true

-- Basic key mappings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uicklist" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- File operations
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Python development shortcuts
vim.keymap.set("n", "<leader>py", "<cmd>!python3 %<CR>", { desc = "Run Python file" })
vim.keymap.set("n", "<leader>pf", "<cmd>!black %<CR><cmd>e<CR>", { desc = "Format with Black" })
vim.keymap.set("n", "<leader>pl", "<cmd>!flake8 %<CR>", { desc = "Lint with flake8" })
vim.keymap.set("n", "<leader>pt", "<cmd>!python3 -m pytest<CR>", { desc = "Run tests" })
vim.keymap.set("n", "<leader>pm", "<cmd>!mypy %<CR>", { desc = "Type check with mypy" })

-- Claude Code integration
vim.keymap.set("n", "<leader>cc", "<cmd>!claude -p 'Review this Python code: ' . expand('%')<CR>", { desc = "Claude Code review" })
vim.keymap.set("n", "<leader>cd", "<cmd>!claude -p '/debug-issue " .. vim.fn.expand('%') .. "'<CR>", { desc = "Claude debug" })
vim.keymap.set("n", "<leader>cr", "<cmd>!claude -p '/refactor-code " .. vim.fn.expand('%') .. "'<CR>", { desc = "Claude refactor" })
vim.keymap.set("n", "<leader>ct", "<cmd>!claude -p '/generate-tests " .. vim.fn.expand('%') .. "'<CR>", { desc = "Claude generate tests" })
vim.keymap.set("n", "<leader>co", "<cmd>!claude -p '/optimize-performance " .. vim.fn.expand('%') .. "'<CR>", { desc = "Claude optimize" })
vim.keymap.set("n", "<leader>ca", "<cmd>!claude -p '/analyze-project'<CR>", { desc = "Claude analyze project" })

-- Terminal integration
vim.keymap.set("n", "<leader>tt", "<cmd>split | terminal<CR>", { desc = "Open terminal" })
vim.keymap.set("n", "<leader>tv", "<cmd>vsplit | terminal<CR>", { desc = "Open vertical terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quick file navigation
vim.keymap.set("n", "<leader>e", "<cmd>Ex<CR>", { desc = "File explorer" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Python-specific mappings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    -- Python-specific settings
    vim.opt_local.textwidth = 88
    vim.opt_local.colorcolumn = "89"
    
    -- Python-specific keymaps
    vim.keymap.set("n", "<F5>", "<cmd>w<CR><cmd>!python3 %<CR>", { desc = "Save and run Python", buffer = true })
    vim.keymap.set("n", "<leader>db", "oimport pdb; pdb.set_trace()<Esc>", { desc = "Add breakpoint", buffer = true })
    vim.keymap.set("n", "<leader>dp", "oimport pprint<CR>pprint()<Esc>i", { desc = "Add pprint", buffer = true })
    vim.keymap.set("n", "<leader>di", "ofrom pprint import pprint<Esc>", { desc = "Import pprint", buffer = true })
  end,
})

-- Color scheme (simple built-in)
vim.cmd.colorscheme("desert")

-- Status line (simple)
vim.opt.laststatus = 2
vim.opt.statusline = "%f %y %m %r %= %l,%c %p%%"

-- Help message
vim.api.nvim_create_user_command('DevHelp', function()
  print([[
Python Development Commands:
  <leader>py - Run Python file
  <leader>pf - Format with Black
  <leader>pl - Lint with flake8
  <leader>pt - Run tests
  <leader>pm - Type check with mypy
  <F5>       - Save and run

Claude Code Commands:
  <leader>cc - Claude code review
  <leader>cd - Claude debug
  <leader>cr - Claude refactor
  <leader>ct - Claude generate tests
  <leader>co - Claude optimize
  <leader>ca - Claude analyze project

Navigation:
  <leader>e  - File explorer
  <Ctrl+h/j/k/l> - Navigate windows

Terminal:
  <leader>tt - Open terminal
  <leader>tv - Open vertical terminal
]])
end, {})

-- Welcome message
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("echo 'Welcome to Neovim Python IDE! Type :DevHelp for commands'")
    end
  end,
})
