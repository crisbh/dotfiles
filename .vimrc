set nocompatible
set number ruler laststatus=2 title hlsearch wildmenu
set term=screen-256color
set cursorline
hi CursorLine term=bold cterm=bold

" Powerline Theme for Vim
"python3 from powerline.vim import setup as powerline_setup
"python3 powerline_setup()
"python3 del powerline_setup
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode    " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256

call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'edkolev/tmuxline.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
Plug 'christoomey/vim-tmux-navigator'
Plug 'crusoexia/vim-monokai'
call plug#end()

" Proper indentation of new lines
filetype indent plugin on
syntax on " Syntax highlighting
colorscheme monokai

set expandtab
set tabstop=4
set shiftwidth=4

set hidden " allow me to have buffers with unsaved changes.
set autoread " when a file has changed on disk, just load it. Don't ask.

" Make search more sane
set ignorecase " case insensitive search
set smartcase " If there are uppercase letters, become case-sensitive.
set incsearch " live incremental searching
set showmatch " live match highlighting
set hlsearch " highlight matches
set gdefault " use the `g` flag by default.

" allow the cursor to go anywhere in visual block mode.
set virtualedit+=block

" leader is a key that allows you to have your own "namespace" of keybindings.
let mapleader = ","

" We don't have to press shift when we want to get into command mode.
nnoremap ; :
vnoremap ; :

" create new vsplit, and switch to it.
noremap <leader>v <C-w>v 

" Use sane regex's when searching
nnoremap / /\v
vnoremap / /\v

nnoremap <leader>l :set cursorcolumn!<CR>

" Clear match highlighting
noremap <leader><space> :noh<cr>:call clearmatches()<cr>

" Quick buffer switching - like cmd-tab'ing
nnoremap <leader><leader> <c-^>
nnoremap <buffer> <F5> :!python3.7 %<cr>   " Run python script
" Improve buffer navigation
let g:airline#extensions#tabline#enabled = 1  

" If you wrap lines, vim by default won't let you move down one line to the
" wrapped portion. This fixes that.
noremap j gj
noremap k gk
