" Advanced Vim Configuration for Python Development
" ================================================

" Basic Settings
set nocompatible
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
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undofile
set undodir=~/.vim/undo//

" Create backup directories
if !isdirectory($HOME.'/.vim/backup')
    call mkdir($HOME.'/.vim/backup', 'p')
endif
if !isdirectory($HOME.'/.vim/swap')
    call mkdir($HOME.'/.vim/swap', 'p')
endif
if !isdirectory($HOME.'/.vim/undo')
    call mkdir($HOME.'/.vim/undo', 'p')
endif

" Color scheme
syntax enable
set background=dark
colorscheme desert

" Python-specific settings
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd FileType python setlocal textwidth=88
autocmd FileType python setlocal colorcolumn=89

" Key mappings
let mapleader = " "

" Basic navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" File operations
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>e :e 

" Search and replace
nnoremap <leader>/ :noh<CR>
nnoremap <leader>r :%s/

" Python development shortcuts
nnoremap <leader>py :!python3 %<CR>
nnoremap <leader>pf :!black %<CR>
nnoremap <leader>pl :!flake8 %<CR>
nnoremap <leader>pt :!python3 -m pytest<CR>

" Code folding
set foldmethod=indent
set foldlevel=20
nnoremap <space> za

" Status line
set laststatus=2
set statusline=%f\ %y\ %m\ %r\ %=\ %l,%c\ %p%%

" Auto-completion for Python
set omnifunc=pythoncomplete#Complete

" Highlight current line
set cursorline

" Show matching brackets
set showmatch

" Wild menu for command completion
set wildmenu
set wildmode=list:longest,full

" Plugin-free IDE features
" Simple file explorer
nnoremap <leader>ex :Explore<CR>

" Simple grep
nnoremap <leader>g :grep -r 
command! -nargs=+ Grep execute 'grep -r <args> .'

" Python execution in split
nnoremap <leader>run :vsplit \| terminal python3 %<CR>

" Format Python code
command! FormatPython execute '!black %' | edit

" Lint Python code  
command! LintPython execute '!flake8 %'

" Type check
command! TypeCheck execute '!mypy %'

" Run tests
command! RunTests execute '!python3 -m pytest -v'

" Git shortcuts
nnoremap <leader>gs :!git status<CR>
nnoremap <leader>ga :!git add .<CR>
nnoremap <leader>gc :!git commit -m ""<Left>
nnoremap <leader>gp :!git push<CR>

" Claude Code integration
nnoremap <leader>cc :!claude -p ""<Left>
nnoremap <leader>cd :!claude -p "Debug this Python code: " . expand('%')<CR>
nnoremap <leader>cr :!claude -p "Review this Python code: " . expand('%')<CR>

" Auto-commands for Python development
autocmd BufWritePre *.py execute ':FormatPython'
autocmd BufWritePost *.py execute ':LintPython'

" Simple snippets for Python
abbreviate defm def main():<CR>if __name__ == "__main__":<CR>main()
abbreviate pdb import pdb; pdb.set_trace()
abbreviate pprint from pprint import pprint<CR>pprint()

" Terminal mode mapping
tnoremap <Esc> <C-\><C-n>

" Quick save and run Python
nnoremap <F5> :w<CR>:!python3 %<CR>

" Toggle line numbers
nnoremap <F2> :set nu!<CR>

" Source vimrc
nnoremap <leader>sv :source ~/.vimrc<CR>

" Help for custom commands
command! DevHelp echo "Python Dev Commands: <leader>py(run) <leader>pf(format) <leader>pl(lint) <leader>pt(test) <leader>cc(claude)"
