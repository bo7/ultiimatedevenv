" Neovim Python IDE Configuration
" =================================

" Basic Settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrap
set linebreak
set scrolloff=8
set sidescrolloff=8
set mouse=a
set clipboard=unnamedplus
set updatetime=300
set timeoutlen=500
set hidden
set backup
set backupdir=~/.config/nvim/backup//
set directory=~/.config/nvim/swap//
set undofile
set undodir=~/.config/nvim/undo//
set signcolumn=yes
set termguicolors
set pumheight=10
set cmdheight=2
set splitbelow
set splitright
set cursorline
set showmatch
set wildmenu
set wildmode=list:longest,full

" Create backup directories
if !isdirectory($HOME.'/.config/nvim/backup')
    call mkdir($HOME.'/.config/nvim/backup', 'p')
endif
if !isdirectory($HOME.'/.config/nvim/swap')
    call mkdir($HOME.'/.config/nvim/swap', 'p')
endif
if !isdirectory($HOME.'/.config/nvim/undo')
    call mkdir($HOME.'/.config/nvim/undo', 'p')
endif

" Leader key
let mapleader = " "

" Plugin management with vim-plug
call plug#begin('~/.config/nvim/plugged')

" Essential plugins for Python IDE
Plug 'neovim/nvim-lspconfig'           " LSP configuration
Plug 'hrsh7th/nvim-cmp'                " Autocompletion
Plug 'hrsh7th/cmp-nvim-lsp'            " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-buffer'              " Buffer completions
Plug 'hrsh7th/cmp-path'                " Path completions
Plug 'hrsh7th/cmp-cmdline'             " Command line completions
Plug 'L3MON4D3/LuaSnip'                " Snippet engine
Plug 'saadparwaiz1/cmp_luasnip'        " Snippet completions

" Treesitter for syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" File explorer and fuzzy finder
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Git integration
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'

" Python specific
Plug 'psf/black', { 'branch': 'stable' }
Plug 'averms/black-nvim', {'do': ':UpdateRemotePlugins'}
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-python'

" Status line and themes
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Code formatting and linting
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'MunifTanjim/prettier.nvim'

" Terminal integration
Plug 'akinsho/toggleterm.nvim'

" Comment plugin
Plug 'numToStr/Comment.nvim'

" Surround plugin
Plug 'kylechui/nvim-surround'

" Indent guides
Plug 'lukas-reineke/indent-blankline.nvim'

" Auto pairs
Plug 'windwp/nvim-autopairs'

" Which-key for keybinding help
Plug 'folke/which-key.nvim'

call plug#end()

" Color scheme
colorscheme tokyonight-storm

" Key mappings
" =============

" Basic navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" File operations
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>e :NvimTreeToggle<CR>

" Search and replace
nnoremap <leader>/ :noh<CR>
nnoremap <leader>r :%s/

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Python development
nnoremap <leader>py :!python3 %<CR>
nnoremap <leader>pf :Black<CR>
nnoremap <leader>pt :!python3 -m pytest<CR>
nnoremap <leader>pl :!flake8 %<CR>

" Claude Code integration
nnoremap <leader>cc :!claude -p ""<Left>
nnoremap <leader>cd :!claude -p "Debug this Python code: " . expand('%')<CR>
nnoremap <leader>cr :!claude -p "Review this Python code: " . expand('%')<CR>
nnoremap <leader>ca :!claude -p "/analyze-project"<CR>
nnoremap <leader>ct :!claude -p "/generate-tests " . expand('%')<CR>

" Git shortcuts
nnoremap <leader>gs :!git status<CR>
nnoremap <leader>ga :!git add .<CR>
nnoremap <leader>gc :!git commit -m ""<Left>
nnoremap <leader>gp :!git push<CR>

" Terminal
nnoremap <leader>tt :ToggleTerm<CR>
nnoremap <leader>th :ToggleTerm size=10 direction=horizontal<CR>
nnoremap <leader>tv :ToggleTerm size=80 direction=vertical<CR>

" LSP mappings
nnoremap <leader>ld <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>lr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>lh <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>ls <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>lf <cmd>lua vim.lsp.buf.format()<CR>
nnoremap <leader>la <cmd>lua vim.lsp.buf.code_action()<CR>

" Quick save and run
nnoremap <F5> :w<CR>:!python3 %<CR>

" Help for custom commands
command! DevHelp echo "Python Dev: <leader>py(run) <leader>pf(format) <leader>pt(test) | Claude: <leader>cc(prompt) <leader>ca(analyze) | LSP: <leader>ld(def) <leader>lr(refs)"

" Lua configuration
lua << EOF
-- LSP Configuration
local lspconfig = require('lspconfig')
local cmp = require'cmp'

-- Python LSP (Pylsp)
lspconfig.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = {'W391'},
          maxLineLength = 88
        },
        flake8 = {
          enabled = true,
          maxLineLength = 88
        },
        black = {
          enabled = true
        },
        pylint = {
          enabled = true
        },
        mypy = {
          enabled = true
        }
      }
    }
  }
}

-- Autocompletion setup
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "lua", "vim", "javascript", "typescript", "html", "css", "json", "yaml" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
}

-- File explorer setup
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
})

-- Telescope setup
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-h>"] = "which_key"
      }
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
require('telescope').load_extension('fzf')

-- Git signs
require('gitsigns').setup()

-- Status line
require('lualine').setup {
  options = {
    theme = 'tokyonight'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}

-- Terminal
require("toggleterm").setup{
  size = 20,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "float",
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
}

-- Comments
require('Comment').setup()

-- Surround
require("nvim-surround").setup()

-- Indent guides
require("indent_blankline").setup {
    show_current_context = true,
    show_current_context_start = true,
}

-- Auto pairs
require("nvim-autopairs").setup {}

-- Which-key
require("which-key").setup {}

-- Null-ls for formatting and linting
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy,
    },
})

-- Test integration
require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
      args = {"--log-level", "DEBUG"},
      runner = "pytest",
    })
  }
})

EOF

" Python-specific settings
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd FileType python setlocal textwidth=88
autocmd FileType python setlocal colorcolumn=89

" Auto-commands for Python development
autocmd BufWritePre *.py lua vim.lsp.buf.format()

" Terminal mode mapping
tnoremap <Esc> <C-\><C-n>

" Source init.vim
nnoremap <leader>sv :source ~/.config/nvim/init.vim<CR>
